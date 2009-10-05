From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:53:42 -0000
Subject: LVM2/test t-vgextend-usage.sh
Message-ID: <20091005205342.11080.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:53:41

Added files:
	test           : t-vgextend-usage.sh 

Log message:
	Add --pvmetadatacopies as a synonym for --metadatacopies in various commands.
	
	Going forward, we would like to allow users to specify the total
	number of metadatacopies in a VG rather than on a per-PV basis.  In
	order to facilitate that, introduce --pvmetadatacopes to replace
	--metadatacopies everywhere.  We still allow --metadatacopies for
	pv commands, but require --pvmetadatacopies for vg commands.
	Eventually we will introduce --vgmetadatacopies.  Once we do that,
	we should either deprecate --metadatacopies or make it a synonym based
	on the command (pvmetadatacopies for pv commands, and vgmetadatacopies
	for vg commands).  The latter option would likely just require a simple
	'strncpy' check against cmd->command->name to qualify the merge_synonym
	call.
	
	Update nightly tests to cover the pvmetadatacopies synonym.
	
	Note that this patch is the result of an eariler review comment for
	the implicit pvcreate patches.  Should apply cleanly on top of the
	implicit pvcreate patches (I applied after patch 10/10 in that series).
	
	NOTE: This patch will require --pvmetadatacopies for vgconvert as
	--metadatacopies is no longer accepted.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-vgextend-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgextend-usage.sh
+++ -	2009-10-05 20:53:42.159932000 +0000
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


