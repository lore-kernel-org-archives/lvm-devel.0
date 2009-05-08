From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 May 2009 04:24:53 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20090508042453.13970.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-08 04:24:52

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	Validate chunksize and originsize for snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/t-lvcreate-usage.sh	2009/03/16 14:34:58	1.10
+++ LVM2/test/t-lvcreate-usage.sh	2009/05/08 04:24:52	1.11
@@ -67,3 +67,20 @@
 vgs $vg
 lvremove -ff $vg
 vgchange -l 0 $vg
+
+# lvcreate rejects invalid chunksize, accepts between 4K and 512K
+# validate origin_size
+vgremove -ff $vg
+vgcreate -cn $vg $devs
+lvcreate -L 32M -n $lv1 $vg
+not lvcreate -L 8M -n $lv2 -s --chunksize 3K $vg/$lv1
+not lvcreate -L 8M -n $lv2 -s --chunksize 1024K $vg/$lv1
+lvcreate -L 8M -n $lv2 -s --chunksize 4K $vg/$lv1
+check_lv_field_ $vg/$lv2 chunk_size 4.00K
+check_lv_field_ $vg/$lv2 origin_size 32.00M
+lvcreate -L 8M -n $lv3 -s --chunksize 512K $vg/$lv1
+check_lv_field_ $vg/$lv3 chunk_size 512.00K
+check_lv_field_ $vg/$lv3 origin_size 32.00M
+lvremove -ff $vg
+vgchange -l 0 $vg
+


