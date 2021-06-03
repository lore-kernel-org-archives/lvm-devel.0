From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:39:56 +0000 (GMT)
Subject: main - tests: stress: Add single thread stress testing
Message-ID: <20210603143956.2F3E23838032@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe660467fa4c943bb0ce928e7af65572e2ddeddc
Commit:        fe660467fa4c943bb0ce928e7af65572e2ddeddc
Parent:        5b361b197e1a3fbbc5419b9c46f19539c2b7305c
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:13 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: stress: Add single thread stress testing

This patch is to add the stress testing, which loops to create LV,
activate and deactivate LV in the single thread.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/stress_single_thread.sh | 59 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/test/shell/stress_single_thread.sh b/test/shell/stress_single_thread.sh
new file mode 100644
index 000000000..e18d4900b
--- /dev/null
+++ b/test/shell/stress_single_thread.sh
@@ -0,0 +1,59 @@
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
+aux prepare_vg 3
+
+for i in {1..1000}
+do
+	# Create new logic volume and deactivate it
+	lvcreate -a n --zero n -l 1 -n foo $vg
+
+	# Set minor number
+	lvchange $vg/foo -My --major=255 --minor=123
+
+	# Activate logic volume
+	lvchange $vg/foo -a y
+
+	# Check device mapper
+	dmsetup info $vg-foo | tee info
+	grep -E "^Major, minor: *[0-9]+, 123" info
+
+	# Extend logic volume with 10%
+	lvextend -l+10 $vg/foo
+
+	# Deactivate logic volume
+	lvchange $vg/foo -a n
+
+	# Deactivate volume group
+	vgchange $vg -a n
+
+	# Activate volume group with shareable mode
+	vgchange $vg -a sy
+
+	# lvextend fails due to mismatched lock mode
+	not lvextend -l+10 $vg/foo
+
+	# Promote volume group to exclusive mode
+	vgchange $vg -a ey
+
+	lvreduce -f -l-4 $vg/foo
+
+	lvchange -an $vg/foo
+	lvremove $vg/foo
+done
+
+vgremove -ff $vg


