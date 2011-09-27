From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:48 +0200
Subject: [PATCH v3 15/18] test: Add test for fsadm add command
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-16-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The tests exercises the fsadm "add" functionality, by trying various
combinations of arguments and checking the desired results.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 test/t-fsadm-add.sh |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)
 create mode 100644 test/t-fsadm-add.sh

diff --git a/test/t-fsadm-add.sh b/test/t-fsadm-add.sh
new file mode 100644
index 0000000..4c4eb2e
--- /dev/null
+++ b/test/t-fsadm-add.sh
@@ -0,0 +1,53 @@
+#!/bin/bash
+# Copyright 2011 (C) Red Hat, Inc., Lukas Czerner <lczerner@redhat.com>
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise fsadm add'
+
+. lib/test
+
+DEV_COUNT=10
+aux prepare_devs $DEV_COUNT 10
+TEST_DEVS=$(cat DEVICES)
+export DEFAULT_DEVICE_POOL=$vg1
+
+pool1=$vg2
+pool2=$vg3
+
+# Create default pool with all devices at once
+fsadm add $TEST_DEVS
+check vg_field $DEFAULT_DEVICE_POOL pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+# Create default pool by adding devices one per a call
+for i in $TEST_DEVS; do
+        fsadm add $i
+done
+check vg_field $DEFAULT_DEVICE_POOL pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+# Create different groups from different devices
+fsadm add $dev1 $dev2 $dev3 $pool1
+fsadm add $dev4 $dev5 $dev6
+fsadm add $dev7 $dev8 $dev9 $pool2
+fsadm add $dev10 $pool2
+not fsadm add $dev10 $pool2 $pool1
+check vg_field $DEFAULT_DEVICE_POOL pv_count 3
+check vg_field $pool1 pv_count 3
+check vg_field $pool2 pv_count 4
+fsadm -f remove --all
+
+fsadm add --help
+
+# Some cases which should fail
+not fsadm _garbage_
+not fsadm add
+not fsadm add _somepool
+not fsadm add $dev1 $dev2 $dev3 $pool1 _otherpool
-- 
1.7.4.4


