From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:39:57 +0000 (GMT)
Subject: main - tests: stress: Add multi-threads stress testing for VG/LV
Message-ID: <20210603143957.4FB783835833@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=692fe7bb31b6682151601f196e6274a3e8b772d5
Commit:        692fe7bb31b6682151601f196e6274a3e8b772d5
Parent:        fe660467fa4c943bb0ce928e7af65572e2ddeddc
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:14 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: stress: Add multi-threads stress testing for VG/LV

This patch is to add the stress testing, which launches two threads,
each thread creates LV, activate and deactivate LV in the loop; so this
can test for multi-threading in lvmlockd and its backend lock manager.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/stress_multi_threads_1.sh | 111 +++++++++++++++++++++++++++++++++++
 1 file changed, 111 insertions(+)

diff --git a/test/shell/stress_multi_threads_1.sh b/test/shell/stress_multi_threads_1.sh
new file mode 100644
index 000000000..c96fa244b
--- /dev/null
+++ b/test/shell/stress_multi_threads_1.sh
@@ -0,0 +1,111 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Seagate, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 6
+get_devs
+
+pvcreate -M2 "${DEVICES[@]}"
+
+vgcreate --shared -M2 "$vg1" "$dev1" "$dev2" "$dev3"
+vgcreate --shared -M2 "$vg2" "$dev4" "$dev5" "$dev6"
+
+test_vg_thread1()
+{
+	for i in {1..1000}
+	do
+		# Create new logic volume and deactivate it
+		lvcreate -a n --zero n -l 1 -n foo $vg1
+
+		# Set minor number
+		lvchange $vg1/foo -My --major=255 --minor=123
+
+		# Activate logic volume
+		lvchange $vg1/foo -a y
+
+		# Extend logic volume with 10%
+		lvextend -l+10 $vg1/foo
+
+		# Deactivate logic volume
+		lvchange $vg1/foo -a n
+
+		# Deactivate volume group
+		vgchange $vg1 -a n
+
+		# Activate volume group with shareable mode
+		vgchange $vg1 -a sy
+
+		# lvextend fails due to mismatched lock mode
+		not lvextend -l+10 $vg1/foo
+
+		# Promote volume group to exclusive mode
+		vgchange $vg1 -a ey
+
+		lvreduce -f -l-4 $vg1/foo
+
+		lvchange -an $vg1/foo
+		lvremove $vg1/foo
+	done
+}
+
+test_vg_thread2()
+{
+	for i in {1..1000}
+	do
+		# Create new logic volume and deactivate it
+		lvcreate -a n --zero n -l 1 -n foo $vg2
+
+		# Set minor number
+		lvchange $vg2/foo -My --major=255 --minor=124
+
+		# Activate logic volume
+		lvchange $vg2/foo -a y
+
+		# Extend logic volume with 10%
+		lvextend -l+10 $vg2/foo
+
+		# Deactivate logic volume
+		lvchange $vg2/foo -a n
+
+		# Deactivate volume group
+		vgchange $vg2 -a n
+
+		# Activate volume group with shareable mode
+		vgchange $vg2 -a sy
+
+		# lvextend fails due to mismatched lock mode
+		not lvextend -l+10 $vg2/foo
+
+		# Promote volume group to exclusive mode
+		vgchange $vg2 -a ey
+
+		lvreduce -f -l-4 $vg2/foo
+
+		lvchange -an $vg2/foo
+		lvremove $vg2/foo
+	done
+}
+
+test_vg_thread1 &
+WAITPID=$!
+
+test_vg_thread2 &
+WAITPID="$WAITPID "$!
+
+wait $WAITPID
+
+vgremove -ff $vg1
+vgremove -ff $vg2


