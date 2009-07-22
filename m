From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:53 -0400
Subject: [PATCH 8/8] Add implicit tests for implicit pvcreate during vgcreate and vgextend.
In-Reply-To: <1248235553-13519-8-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-4-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-5-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-6-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-7-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-vgcreate-usage.sh |    4 ++++
 test/t-vgextend-usage.sh |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)
 create mode 100644 test/t-vgextend-usage.sh

diff --git a/test/t-vgcreate-usage.sh b/test/t-vgcreate-usage.sh
index 1a3f834..12f9ba1 100755
--- a/test/t-vgcreate-usage.sh
+++ b/test/t-vgcreate-usage.sh
@@ -87,3 +87,7 @@ check_vg_field_ $vg max_lv 0
 check_vg_field_ $vg max_pv 0
 check_vg_field_ $vg vg_attr "wz--n-"
 vgremove -ff $vg
+
+# Test implicit pvcreate
+pvremove $dev1 $dev2
+vgcreate $vg $dev1 $dev2
diff --git a/test/t-vgextend-usage.sh b/test/t-vgextend-usage.sh
new file mode 100644
index 0000000..8fec6fd
--- /dev/null
+++ b/test/t-vgextend-usage.sh
@@ -0,0 +1,34 @@
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
+#
+# Exercise various vgextend commands
+#
+
+. ./test-utils.sh
+
+aux prepare_devs 5
+
+for mdatype in 1 2
+do
+
+# Explicit pvcreate
+pvcreate -M$mdatype $dev1 $dev2 $dev3 $dev4 $dev5
+vgcreate -M$mdatype $vg1 $dev1 $dev2
+vgextend $vg1 $dev3 $dev4 $dev5
+vgremove -ff $vg1
+
+# Implicit pvcreate
+pvremove $dev1 $dev2 $dev3 $dev4 $dev5
+vgcreate -M$mdatype $vg1 $dev1 $dev2
+vgextend -M$mdatype $vg1 $dev3 $dev4 $dev5
+vgremove -ff $vg1
+pvremove $dev1 $dev2 $dev3 $dev4 $dev5
+done
-- 
1.6.0.6


