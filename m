From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:13:01 -0500
Subject: [PATCH 5/5] Add t-pv-resized nightly test, check for resized PV.
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1321305181-28158-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a check to ensure a vgextend or any operation which modifies
metadata will fail after a PV gets resized smaller than when it was
originally pvcreated.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-pv-resized.sh |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)
 create mode 100644 test/t-pv-resized.sh

diff --git a/test/t-pv-resized.sh b/test/t-pv-resized.sh
new file mode 100644
index 0000000..92f6468
--- /dev/null
+++ b/test/t-pv-resized.sh
@@ -0,0 +1,24 @@
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
+#
+# Test LVM tools when PV devices get resize (for example, on SAN).
+#
+. lib/test
+
+aux prepare_pvs 3 10
+
+vgcreate $vg $dev1 $dev2
+pvs -opv_name,pv_size,dev_size
+# Assume one PV gets sized smaller than at time of pvcreate
+aux resize_dev $dev3 5
+pvs -opv_name,pv_size,dev_size
+# Now, any operation like vgextend that writes metadata should fail
+not vgextend $vg $dev3
-- 
1.7.4.4


