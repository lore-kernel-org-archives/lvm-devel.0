From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:40:06 +0000 (GMT)
Subject: main - tests: multi-hosts: Add VG testing
Message-ID: <20210603144006.80EF1383B420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e75bd71aaea6e092b93533bdc948fd527821d297
Commit:        e75bd71aaea6e092b93533bdc948fd527821d297
Parent:        92b47d8eb8c4b717fd79d0b7c50ecac0dceb31a5
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:22 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: multi-hosts: Add VG testing

This patch is to add VG testing on multi hosts.  There have two scripts,
the script multi_hosts_vg_hosta.sh is used to create VGs on one host,
and the second script multi_hosts_vg_hostb.sh afterwards will acquire
global lock and VG lock, and remove VGs.  The testing flow verifies the
locking operations between two hosts with lvmlockd and the backend
locking manager.

  On the host A:
    make check_lvmlockd_idm \
      LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
      LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hosta.sh

  On the host B:
    make check_lvmlockd_idm \
      LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
      LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hostb.sh

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/Makefile.in                   |  1 +
 test/lib/inittest.sh               |  2 ++
 test/shell/multi_hosts_vg_hosta.sh | 45 +++++++++++++++++++++++++++++++++
 test/shell/multi_hosts_vg_hostb.sh | 52 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+)

diff --git a/test/Makefile.in b/test/Makefile.in
index 573df77a7..cd134129b 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -93,6 +93,7 @@ help:
 	@echo -e "\nSupported variables:"
 	@echo "  LVM_TEST_AUX_TRACE	Set for verbose messages for aux scripts []."
 	@echo "  LVM_TEST_BACKING_DEVICE Set device used for testing (see also LVM_TEST_DIR)."
+	@echo "  LVM_TEST_MULTI_HOST	Set multiple hosts used for testing."
 	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
 	@echo "  LVM_TEST_PREFER_BRD	Prefer using brd (ramdisk) over loop for testing [1]."
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 98a916ca6..4ca8ac59e 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -32,6 +32,7 @@ LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}
 LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
 LVM_TEST_LVM1=${LVM_TEST_LVM1-}
 LVM_TEST_FAILURE=${LVM_TEST_FAILURE-}
+LVM_TEST_MULTI_HOST=${LVM_TEST_MULTI_HOST-}
 # TODO: LVM_TEST_SHARED
 SHARED=${SHARED-}
 
@@ -65,6 +66,7 @@ test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 unset CDPATH
 
 export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG LVM_TEST_FAILURE
+export LVM_TEST_MULTI_HOST
 export LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
 export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK LVM_TEST_LOCK_TYPE_IDM
 export LVM_TEST_DEVICES_FILE
diff --git a/test/shell/multi_hosts_vg_hosta.sh b/test/shell/multi_hosts_vg_hosta.sh
new file mode 100644
index 000000000..15347490c
--- /dev/null
+++ b/test/shell/multi_hosts_vg_hosta.sh
@@ -0,0 +1,45 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Seagate, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# This testing script is for multi-hosts testing, the paired scripts
+# are: multi_hosts_vg_hosta.sh / multi_hosts_vg_hostb.sh
+#
+# On the host A:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hosta.sh
+# On the host B:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hostb.sh
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+[ -z "$LVM_TEST_MULTI_HOST" ] && skip;
+
+IFS=',' read -r -a BLKDEVS <<< "$LVM_TEST_BACKING_DEVICE"
+
+for d in "${BLKDEVS[@]}"; do
+	aux extend_filter_LVMTEST "a|$d|"
+done
+
+aux lvmconf "devices/allow_changes_with_duplicate_pvs = 1"
+
+i=0
+for d in "${BLKDEVS[@]}"; do
+	echo $i
+	i=$((i+1))
+	vgcreate $SHARED TESTVG$i $d
+	vgchange -a n TESTVG$i
+done
diff --git a/test/shell/multi_hosts_vg_hostb.sh b/test/shell/multi_hosts_vg_hostb.sh
new file mode 100644
index 000000000..bab65b68b
--- /dev/null
+++ b/test/shell/multi_hosts_vg_hostb.sh
@@ -0,0 +1,52 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Seagate, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# This testing script is for multi-hosts testing, the paired scripts
+# are: multi_hosts_vg_hosta.sh / multi_hosts_vg_hostb.sh
+#
+# On the host A:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hosta.sh
+# On the host B:
+#   make check_lvmlockd_idm \
+#     LVM_TEST_BACKING_DEVICE=/dev/sdj3,/dev/sdk3,/dev/sdl3 \
+#     LVM_TEST_MULTI_HOST=1 T=multi_hosts_vg_hostb.sh
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+[ -z "$LVM_TEST_MULTI_HOST" ] && skip;
+
+IFS=',' read -r -a BLKDEVS <<< "$LVM_TEST_BACKING_DEVICE"
+
+for d in "${BLKDEVS[@]}"; do
+	aux extend_filter_LVMTEST "a|$d|"
+done
+
+aux lvmconf "devices/allow_changes_with_duplicate_pvs = 1"
+
+vgchange --lock-start
+
+i=0
+for d in "${BLKDEVS[@]}"; do
+        i=$((i+1))
+	check vg_field TESTVG$i lv_count 0
+done
+
+i=0
+for d in "${BLKDEVS[@]}"; do
+        i=$((i+1))
+	vgchange -a ey TESTVG$i
+	vgremove -ff TESTVG$i
+done


