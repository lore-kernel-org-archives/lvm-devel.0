From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:09 +0000 (GMT)
Subject: master - tests: vgsplit of vdo volumes
Message-ID: <20200925210709.7D2043947C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e003320a7fed71c203ae833edce38b30a7d06fd
Commit:        3e003320a7fed71c203ae833edce38b30a7d06fd
Parent:        e2577c037da84442d5afa125772882c6d5caf8de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 21:50:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

tests: vgsplit of vdo volumes

---
 test/shell/vgsplit-vdo.sh | 56 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/test/shell/vgsplit-vdo.sh b/test/shell/vgsplit-vdo.sh
new file mode 100644
index 000000000..1d5ddf83e
--- /dev/null
+++ b/test/shell/vgsplit-vdo.sh
@@ -0,0 +1,56 @@
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
+# Test vgsplit command options with vdo volumes
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_vdo 6 2 0 || skip
+
+aux lvmconf "allocation/vdo_slab_size_mb = 128"
+
+aux prepare_vg 4 2200
+
+lvcreate --vdo -L4G -n $lv1 $vg "$dev1" "$dev2"
+lvcreate --vdo -L4G -n $lv2 $vg "$dev3" "$dev4"
+
+# Cannot move only part of VDO _vdata
+not vgsplit $vg $vg2 "$dev3" |& tee out
+grep "split" out
+
+# Cannot move active VDO
+not vgsplit $vg $vg2 "$dev3" "$dev4" |& tee out
+grep "inactive" out
+
+lvchange -an $vg/$lv2
+
+vgsplit $vg $vg2 "$dev3" "$dev4"
+
+lvchange -ay $vg2/$lv2
+lvs -ao+devices $vg $vg2
+
+# Cannot merge active VDO
+not vgmerge $vg $vg2 |& tee out
+grep "inactive" out
+
+lvchange -an $vg2/$lv2
+
+vgmerge $vg $vg2
+
+lvs -ao+devices $vg
+
+lvchange -ay $vg/$lv2
+
+vgremove -ff $vg


