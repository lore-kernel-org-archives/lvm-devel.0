From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:40:01 +0000 (GMT)
Subject: main - tests: idm: Add testing for the fabric failure
Message-ID: <20210603144001.E12033838032@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc0495ea04a96c0990726db98c80bd2732d3695a
Commit:        fc0495ea04a96c0990726db98c80bd2732d3695a
Parent:        874001ee6e0e7812e4e8d19994a1fd7de43d3249
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:18 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: idm: Add testing for the fabric failure

When the fabric failure occurs, it will lose the connection with hosts
instantly, and after a while it can recovery back so that the hosts can
continue to access the drives.

For this case, the locking manager should be reliable for this case and
can dynamically handle this case and allows user to continue to use the
VG/LV with associated locking scheme.

This patch adds a testing to emulate the fabric faliure, verify LVM
commands for this case.  The testing usage is:

  # make check_lvmlockd_idm \
	LVM_TEST_BACKING_DEVICE=/dev/sdo3,/dev/sdp3,/dev/sdp4 \
	LVM_TEST_FAILURE=1 T=idm_fabric_failure.sh

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/idm_fabric_failure.sh | 58 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/test/shell/idm_fabric_failure.sh b/test/shell/idm_fabric_failure.sh
new file mode 100644
index 000000000..e68d6ad07
--- /dev/null
+++ b/test/shell/idm_fabric_failure.sh
@@ -0,0 +1,58 @@
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
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+[ -z "$LVM_TEST_FAILURE" ] && skip;
+
+aux prepare_devs 3
+aux extend_filter_LVMTEST
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+# Create new logic volume
+lvcreate -a ey --zero n -l 50%FREE -n $lv1 $vg
+
+DRIVE1=`dmsetup deps -o devname $dev1 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE2=`dmsetup deps -o devname $dev2 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE3=`dmsetup deps -o devname $dev3 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+
+HOST1=`readlink /sys/block/$DRIVE1 | awk -F'/' '{print $6}'`
+HOST2=`readlink /sys/block/$DRIVE2 | awk -F'/' '{print $6}'`
+HOST3=`readlink /sys/block/$DRIVE3 | awk -F'/' '{print $6}'`
+
+# Emulate fabric failure
+echo 1 > /sys/block/$DRIVE1/device/delete
+[ -f /sys/block/$DRIVE2/device/delete ] && echo 1 > /sys/block/$DRIVE2/device/delete
+[ -f /sys/block/$DRIVE3/device/delete ] && echo 1 > /sys/block/$DRIVE3/device/delete
+
+# Wait for 10s and will not lead to timeout
+sleep 10
+
+# Rescan drives so can probe the deleted drives and join back them
+echo "- - -" > /sys/class/scsi_host/${HOST1}/scan
+echo "- - -" > /sys/class/scsi_host/${HOST2}/scan
+echo "- - -" > /sys/class/scsi_host/${HOST3}/scan
+
+not check grep_lvmlockd_dump "S lvm_$vg kill_vg"
+
+# The previous device-mapper are removed, but LVM still can directly
+# access VGs from the specified physical drives.  So enable drives
+# for these drives.
+aux extend_filter_LVMTEST "a|/dev/$DRIVE1*|" "a|/dev/$DRIVE2*|" "a|/dev/$DRIVE3*|"
+aux lvmconf "devices/allow_changes_with_duplicate_pvs = 1"
+
+lvcreate -a n --zero n -l 10 -n $lv2 $vg
+
+vgremove -ff $vg


