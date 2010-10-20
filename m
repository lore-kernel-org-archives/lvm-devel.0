From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Oct 2010 16:28:21 +0200
Subject: [PATCH 2/2] Testcase for partition table scanning
In-Reply-To: <cover.1287584556.git.zkabelac@redhat.com>
References: <cover.1287584556.git.zkabelac@redhat.com>
Message-ID: <b8a47a7cd34b86d4bdd123c202eda4c921201ef5.1287584556.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-test-partition.sh |   30 ++++++++++++++++++++++++++++++
 test/test-utils.sh       |    1 +
 2 files changed, 31 insertions(+), 0 deletions(-)
 create mode 100755 test/t-test-partition.sh

diff --git a/test/t-test-partition.sh b/test/t-test-partition.sh
new file mode 100755
index 0000000..45a0aba
--- /dev/null
+++ b/test/t-test-partition.sh
@@ -0,0 +1,30 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Testcase for bugzilla #621173 
+# excercises partition table scanning code path
+#
+
+which sfdisk || exit 200
+
+LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
+
+. ./test-utils.sh
+
+aux prepare_pvs 1 30
+
+pvs
+
+# create small partition table
+echo "1 2" | sfdisk $dev1
+
+pvs
diff --git a/test/test-utils.sh b/test/test-utils.sh
index cc13fa2..c1de6ca 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -371,6 +371,7 @@ prepare_lvmconf() {
     cache_dir = "$TESTDIR/etc"
     sysfs_scan = 0
     default_data_alignment = 1
+    $LVM_TEST_CONFIG_DEVICES
   }
   log {
     syslog = 0
-- 
1.7.3.1


