From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Apr 2019 06:58:21 -0400
Subject: stable-2.02 - tests: check vgsplit works with cache
Message-ID: <201904161058.x3GAwLIg016916@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ead62e24b6b616c4bde093db37dc770a38669ae
Commit:        3ead62e24b6b616c4bde093db37dc770a38669ae
Parent:        fa025cdd9a7453c86e34bf550235a00537d059de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 1 23:45:12 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 16 12:57:18 2019 +0200

tests: check vgsplit works with cache

---
 test/shell/vgsplit-cache.sh |   71 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgsplit-cache.sh b/test/shell/vgsplit-cache.sh
new file mode 100644
index 0000000..3bbcc2d
--- /dev/null
+++ b/test/shell/vgsplit-cache.sh
@@ -0,0 +1,71 @@
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
+# Test vgsplit command options with cached volumes
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 7
+
+lvcreate -L5 -n $lv2 $vg "$dev2"
+lvcreate -L5 -n $lv3 $vg "$dev3"
+lvconvert -y --type cache-pool --poolmetadata $vg/$lv2 $vg/$lv3
+
+# Cannot split data and metadata from cache-pool
+fail vgsplit $vg $vg1 "$dev2" 2>&1 | tee err
+grep "Cannot split cache pool data" err
+
+fail vgsplit $vg $vg1 "$dev3" 2>&1 | tee err
+grep "Cannot split cache pool data" err
+
+# Cache $lv1
+lvcreate -L1 -n $lv1 $vg "$dev1"
+lvconvert -y --cache --cachepool $vg/$lv3  $vg/$lv1
+
+
+
+# Cannot move active cache
+fail vgsplit $vg $vg1 "$dev1" "$dev2" "$dev3" 2>&1 | tee err
+grep "must be inactive" err
+
+vgchange -an $vg
+
+
+# Try spliting component into separe VG
+fail vgsplit $vg $vg1 "$dev1" 2>&1 | tee err
+grep "Cannot split cache origin" err
+
+fail vgsplit $vg $vg1 "$dev2" 2>&1 | tee err
+grep "Cannot split cache origin" err
+
+fail vgsplit $vg $vg1 "$dev3" 2>&1 | tee err
+grep "Cannot split cache origin" err
+
+fail vgsplit $vg $vg1 "$dev1" "$dev2" 2>&1 | tee err
+grep "Cannot split cache origin" err
+
+fail vgsplit $vg $vg1 "$dev2" "$dev3" 2>&1 | tee err
+
+# Finaly something that should pass
+vgsplit $vg $vg1 "$dev1" "$dev2" "$dev3"
+
+vgs $vg $vg1
+
+test 4 -eq "$(get vg_field $vg pv_count)"
+test 3 -eq "$(get vg_field $vg1 pv_count)"
+
+vgremove -ff $vg $vg1


