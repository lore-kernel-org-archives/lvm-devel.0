From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:20 +0000 (GMT)
Subject: stable-2.02 - tests: check for boundary allocation sizes
Message-ID: <20201016191120.2B30D38618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7131ab4399b3dde28a97e6423622805c6b3bd00
Commit:        d7131ab4399b3dde28a97e6423622805c6b3bd00
Parent:        81538e6e50e66ba59eb39f42188b53e589dd6e7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 21:15:42 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: check for boundary allocation sizes

---
 test/shell/lvcreate-thin-limits.sh | 39 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/test/shell/lvcreate-thin-limits.sh b/test/shell/lvcreate-thin-limits.sh
new file mode 100644
index 000000000..6a9c33d82
--- /dev/null
+++ b/test/shell/lvcreate-thin-limits.sh
@@ -0,0 +1,39 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test allocation of thin-pool on limiting extents number
+
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+which mkfs.ext4 || skip
+
+aux prepare_pvs 1 16777216
+get_devs
+
+vgcreate $SHARED -s 4K "$vg" "${DEVICES[@]}"
+
+not lvcreate -T -L15.995T --poolmetadatasize 5G $vg/pool
+
+lvs -ao+seg_pe_ranges $vg
+
+vgremove -ff $vg


