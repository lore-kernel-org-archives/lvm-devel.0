From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:47 -0400
Subject: [PATCH 10/10] Add implicit tests for implicit pvcreate during vgcreate and vgextend.
In-Reply-To: <1254697907-16448-10-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-6-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-7-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-8-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-9-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update tests and WHATS_NEW for implicit pvcreate support.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 WHATS_NEW                |    1 +
 test/t-vgcreate-usage.sh |   57 ++++++++++++++++++++++++++++++++++
 test/t-vgextend-usage.sh |   77 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 135 insertions(+), 0 deletions(-)
 create mode 100644 test/t-vgextend-usage.sh

diff --git a/WHATS_NEW b/WHATS_NEW
index f7eb570..90eefe9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Add implict pvcreate support to vgcreate and vgextend.
   Update distclean target for rename clogd to cmirrord. (2.02.52)
   Only do lock conversions in clvmd if we are explicitly asked for one.
   Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
diff --git a/test/t-vgcreate-usage.sh b/test/t-vgcreate-usage.sh
index 625b5c4..fb9904d 100755
--- a/test/t-vgcreate-usage.sh
+++ b/test/t-vgcreate-usage.sh
@@ -87,3 +87,60 @@ check_vg_field_ $vg max_lv 0
 check_vg_field_ $vg max_pv 0
 check_vg_field_ $vg vg_attr "wz--n-"
 vgremove -ff $vg
+
+# Implicit pvcreate tests, test pvcreate options on vgcreate
+# --force, --yes, --metadata{size|copies|type}, --zero
+# --dataalignment[offset]
+pvremove $dev1 $dev2
+vgcreate --force --yes --zero y $vg $dev1 $dev2
+vgremove -f $vg
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# vgcreate (lvm2) succeeds writing LVM label at sector $i
+    vgcreate --labelsector $i $vg $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+
+# metadatacopies
+for i in 1 2
+do
+    vgcreate --metadatacopies $i $vg $dev1
+    check_pv_field_ $dev1 pv_mda_count $i
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+not vgcreate --metadatacopies 0 $vg $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate --metadatacopies 0 $vg $dev1 $dev2
+check_pv_field_ $dev1 pv_mda_count 0
+check_pv_field_ $dev2 pv_mda_count 1
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatasize, dataalignment, dataalignmentoffset
+#COMM 'pvcreate sets data offset next to mda area'
+vgcreate --metadatasize 100k --dataalignment 100k $vg $dev1
+check_pv_field_ $dev1 pe_start 200.00k
+vgremove -f $vg
+pvremove -f $dev1
+
+# data area is aligned to 64k by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="195.50k"
+vgcreate --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+check_pv_field_ $dev1 pe_start $pv_align
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatatype
+for i in 1 2
+do
+    vgcreate -M $i $vg $dev1
+    check_vg_field_ $vg vg_fmt lvm$i
+    vgremove -f $vg
+    pvremove -f $dev1
+done
diff --git a/test/t-vgextend-usage.sh b/test/t-vgextend-usage.sh
new file mode 100644
index 0000000..b47cedd
--- /dev/null
+++ b/test/t-vgextend-usage.sh
@@ -0,0 +1,77 @@
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
+
+done
+
+# Implicit pvcreate tests, test pvcreate options on vgcreate
+# --force, --yes, --metadata{size|copies|type}, --zero
+# --dataalignment[offset]
+vgcreate $vg $dev2
+vgextend --force --yes --zero y $vg $dev1
+vgreduce $vg $dev1
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# vgcreate (lvm2) succeeds writing LVM label at sector $i
+    vgextend --labelsector $i $vg $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    vgreduce $vg $dev1
+    pvremove -f $dev1
+done
+
+# metadatacopies
+for i in 0 1 2
+do
+    vgextend --metadatacopies $i $vg $dev1
+    check_pv_field_ $dev1 pv_mda_count $i
+    vgreduce $vg $dev1
+    pvremove -f $dev1
+done
+
+# metadatasize, dataalignment, dataalignmentoffset
+#COMM 'pvcreate sets data offset next to mda area'
+vgextend --metadatasize 100k --dataalignment 100k $vg $dev1
+check_pv_field_ $dev1 pe_start 200.00k
+vgreduce $vg $dev1
+pvremove -f $dev1
+
+# data area is aligned to 64k by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="195.50k"
+vgextend --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+check_pv_field_ $dev1 pe_start $pv_align
+vgremove -f $vg
+pvremove -f $dev1
+
-- 
1.6.0.6


