From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:36 +0000 (UTC)
Subject: master - test: lvmetad-warning
Message-ID: <20160419164936.06017610F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa904a844f7129c39e15ce5e3dc310854646fb87
Commit:        fa904a844f7129c39e15ce5e3dc310854646fb87
Parent:        6b1c0a4190082728de1be2f2d19c1ef46c7f2d5c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 18 16:49:22 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:24 2016 -0500

test: lvmetad-warning

The test was a weak attempt at verifying the special
combination of lvchange/vgchange -aay --sysinit, but
was only looking for lvmetad connection warnings.

Update the warning checks, and check the LV activation
state directly which is the main point.

Rename the test to reflect its purpose of checking
the -aay --sysinit combination.
---
 test/shell/lvmetad-sysinit.sh |   91 +++++++++++++++++++++++++++++++++++++++++
 test/shell/lvmetad-warning.sh |   36 ----------------
 2 files changed, 91 insertions(+), 36 deletions(-)

diff --git a/test/shell/lvmetad-sysinit.sh b/test/shell/lvmetad-sysinit.sh
new file mode 100644
index 0000000..442f728
--- /dev/null
+++ b/test/shell/lvmetad-sysinit.sh
@@ -0,0 +1,91 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 2
+
+#
+# lvchange/vgchange -aay --sysinit should not activate LVs
+# if lvmetad is configured and running.
+#
+
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -an -l1 --zero n -n $lv1 $vg1
+
+#
+# lvmetad is configured and running
+#
+
+lvchange -ay $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+lvchange -aay --sysinit $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check inactive $vg1 $lv1
+
+lvchange -ay --sysinit $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+#
+# lvmetad is configured and not running
+#
+
+kill $(< LOCAL_LVMETAD)
+
+lvchange -ay $vg1 2>&1 | tee out
+grep "WARNING: Failed to connect" out
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+lvchange -aay --sysinit $vg1 2>&1 | tee out
+grep "WARNING: Failed to connect" out
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+#
+# lvmetad is not configured and not running
+#
+
+aux lvmconf 'global/use_lvmetad = 0'
+
+lvchange -ay $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+lvchange -aay $vg1 --sysinit 2>&1 | tee out
+not grep "WARNING: Failed to connect"
+not grep "WARNING: lvmetad is active, skipping direct activation during sysinit" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
deleted file mode 100644
index e631f9c..0000000
--- a/test/shell/lvmetad-warning.sh
+++ /dev/null
@@ -1,36 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_pvs 2
-
-vgcreate $vg1 "$dev1" "$dev2"
-lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
-
-kill $(< LOCAL_LVMETAD)
-lvchange -ay $vg1 2>&1 | grep "Failed to connect"
-lvchange -aay $vg1 --sysinit 2>&1 | tee sysinit.txt
-not grep "Failed to connect" sysinit.txt
-
-aux lvmconf 'global/use_lvmetad = 0'
-lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
-lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
-
-aux prepare_lvmetad
-lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
-lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
-
-vgremove -ff $vg1


