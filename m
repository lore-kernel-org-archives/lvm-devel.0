From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:40:00 +0000 (GMT)
Subject: main - tests: Add testing for lvmlockd failure
Message-ID: <20210603144000.BB8B43839C7C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=874001ee6e0e7812e4e8d19994a1fd7de43d3249
Commit:        874001ee6e0e7812e4e8d19994a1fd7de43d3249
Parent:        8c7b2df41fdddcd1b1c504522ab79300882eb72f
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:17 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: Add testing for lvmlockd failure

After the lvmlockd abnormally exits and relaunch the daemon, if LVM
commands continue to run, lvmlockd and the backend lock manager (e.g.
sanlock lock manager or IDM lock manager) should can continue to serve
the requests from LVM commands.

This patch adds a test to emulate lvmlockd failure, and verify the LVM
commands after lvmlockd recovers back.  Below is an example for testing
the case:

  # make check_lvmlockd_idm \
	LVM_TEST_BACKING_DEVICE=/dev/sdo3,/dev/sdp3,/dev/sdp4 \
	LVM_TEST_FAILURE=1 T=lvmlockd_failure.sh

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/lib/inittest.sh           |  3 ++-
 test/shell/lvmlockd_failure.sh | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 6b4bcb348..98a916ca6 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -31,6 +31,7 @@ LVM_TEST_BACKING_DEVICE=${LVM_TEST_BACKING_DEVICE-}
 LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}
 LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
 LVM_TEST_LVM1=${LVM_TEST_LVM1-}
+LVM_TEST_FAILURE=${LVM_TEST_FAILURE-}
 # TODO: LVM_TEST_SHARED
 SHARED=${SHARED-}
 
@@ -63,7 +64,7 @@ test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 
 unset CDPATH
 
-export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG
+export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG LVM_TEST_FAILURE
 export LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
 export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK LVM_TEST_LOCK_TYPE_IDM
 export LVM_TEST_DEVICES_FILE
diff --git a/test/shell/lvmlockd_failure.sh b/test/shell/lvmlockd_failure.sh
new file mode 100644
index 000000000..e0fccfb83
--- /dev/null
+++ b/test/shell/lvmlockd_failure.sh
@@ -0,0 +1,37 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020~2021 Seagate, Inc.  All rights reserved.
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
+[ -z "$LVM_TEST_FAILURE" ] && skip;
+
+aux prepare_vg 3
+
+# Create new logic volume
+lvcreate -a ey --zero n -l 1 -n $lv1 $vg
+
+# Emulate lvmlockd abnormally exiting
+killall -9 lvmlockd
+
+systemctl start lvm2-lvmlockd
+
+vgchange --lock-start $vg
+
+lvchange -a n $vg/$lv1
+lvchange -a sy $vg/$lv1
+
+lvcreate -a ey --zero n -l 1 -n $lv2 $vg
+lvchange -a n $vg/$lv2
+
+vgremove -ff $vg


