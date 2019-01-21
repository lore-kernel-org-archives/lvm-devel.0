From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:56:17 -0500
Subject: master - tests: vdo dmeventd resize
Message-ID: <201901211156.x0LBuHYH024936@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc02343eff39b80e3b41b74475d9f2d6797062ac
Commit:        fc02343eff39b80e3b41b74475d9f2d6797062ac
Parent:        f3c52a515b7b40a76d7dfc64b712020f032cde1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 16:08:53 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

tests: vdo dmeventd resize

---
 test/shell/lvextend-vdo-dmeventd.sh |   68 +++++++++++++++++++++++++++++++++++
 1 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-vdo-dmeventd.sh b/test/shell/lvextend-vdo-dmeventd.sh
new file mode 100644
index 0000000..6dbe4c4
--- /dev/null
+++ b/test/shell/lvextend-vdo-dmeventd.sh
@@ -0,0 +1,68 @@
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
+# Test autoextension of VDO pool volume
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+percent_() {
+	get lv_field $vg/vpool data_percent | cut -d. -f1
+}
+
+wait_for_change_() {
+	# dmeventd only checks every 10 seconds :(
+	for i in $(seq 1 25) ; do
+		test "$(percent_)" != "$1" && return
+		sleep 1
+	done
+
+	return 1  # timeout
+}
+
+aux have_vdo 6 2 0 || skip
+
+aux prepare_dmeventd
+
+aux lvmconf "activation/vdo_pool_autoextend_percent = 20" \
+	    "activation/vdo_pool_autoextend_threshold = 70" \
+	    "allocation/vdo_slab_size_mb = 128"
+
+aux prepare_vg 1 9000
+lvcreate --vdo -V2G -L4G -n $lv1 $vg/vpool
+
+pre=$(percent_)
+# Check out VDO pool is bellow 70%
+test "$pre" -lt 70
+
+# Fill space to be over 70%
+dd if=/dev/urandom of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=1M count=80 conv=fdatasync
+
+# Should be now over 70%
+pre=$(percent_)
+test "$pre" -ge 70
+
+wait_for_change_ $pre
+
+pre=$(percent_)
+# Check out VDO pool gets again bellow 70%
+test "$pre" -lt 70 || die "Data percentage has not changed bellow 70%!"
+
+# 4G * 1.2   (20%) ->  4.8G
+check lv_field $vg/vpool size "4.80g"
+check lv_field $vg/$lv1 size "2.00g"
+
+lvs -a $vg
+
+vgremove -f $vg


