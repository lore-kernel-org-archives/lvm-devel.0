From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  1 Apr 2010 11:56:43 -0400
Subject: [PATCH] Add blocking/non-blocking test for vgremove.
Message-ID: <1270137403-4090-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While a big ugly, this tests Milan's recent fix to take blocking orphan
locks when wait_for_locks = 1, the fix that addressed:
https://bugzilla.redhat.com/show_bug.cgi?id=578413

Other ways to test this sort of functionality are certainly welcomed.
This patch is at least a start at test coverage of such blocking/non-blocking
functionality.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-blocking-nonblocking.sh |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)
 create mode 100755 test/t-blocking-nonblocking.sh

diff --git a/test/t-blocking-nonblocking.sh b/test/t-blocking-nonblocking.sh
new file mode 100755
index 0000000..81a6c2e
--- /dev/null
+++ b/test/t-blocking-nonblocking.sh
@@ -0,0 +1,34 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='test some blocking / non-blocking multi-vg operations'
+
+. ./test-utils.sh
+
+aux prepare_devs 3
+pvcreate $dev1 $dev2
+vgcreate $vg $dev1 $dev2
+
+# if wait_for_locks set, vgremove should wait for orphan lock
+# flock process should have exited by the time first vgremove completes
+flock -w 5 $G_root_/var/lock/lvm/P_orphans -c "sleep 15"&
+flock_pid=`jobs -p`
+vgremove --config 'global { wait_for_locks = 1 }' $vg
+not vgremove --config 'global { wait_for_locks = 1 }' $vg
+not ps $flock_pid
+
+# if wait_for_locks not set, vgremove should fail on non-blocking lock
+# we must wait for flock process at the end - vgremove won't wait
+vgcreate $vg $dev1 $dev2
+flock -w 5 $G_root_/var/lock/lvm/P_orphans -c "sleep 10"&
+flock_pid=`jobs -p`
+not vgremove --config 'global { wait_for_locks = 0 }' $vg
+wait $flock_pid
-- 
1.6.0.6


