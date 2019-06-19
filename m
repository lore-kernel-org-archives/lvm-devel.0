From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jun 2019 07:42:08 -0400
Subject: stable-2.02 - tests: check mirror with clvmd and dmeventd
Message-ID: <201906191142.x5JBg8tt017641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1727df7c98b749be90a5790d3d9858a012f687f6
Commit:        1727df7c98b749be90a5790d3d9858a012f687f6
Parent:        29ae8b8ca5935536d9ce55959022918e0343562f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 19 13:38:57 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 19 13:38:57 2019 +0200

tests: check mirror with clvmd and dmeventd

---
 test/shell/lvconvert-mirror-dmeventd.sh |   41 +++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror-dmeventd.sh b/test/shell/lvconvert-mirror-dmeventd.sh
new file mode 100644
index 0000000..3bebd64
--- /dev/null
+++ b/test/shell/lvconvert-mirror-dmeventd.sh
@@ -0,0 +1,41 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Check clustered usage with dmeventd
+
+. lib/inittest
+
+aux prepare_dmeventd
+
+aux prepare_pvs 3 100
+get_devs
+
+vgcreate $SHARED -s 64k "$vg" "${DEVICES[@]}"
+
+# Use zero devices for big mirror legs
+aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
+aux zero_dev "$dev3" $(get first_extent_sector "$dev3"):
+
+lvcreate -aey -L90 --type mirror --corelog --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2"
+
+lvconvert -m+1 -b $vg/$lv1 "$dev3"
+
+# We want here ongoing conversion
+
+lvs -a -o+seg_pe_ranges $vg
+
+# Now it should be able to drop 2nd. leg
+lvconvert -m-1 $vg/$lv1 "$dev2"
+
+lvs -a $vg
+
+vgremove -f $vg


