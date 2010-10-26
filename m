From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Oct 2010 12:52:25 -0000
Subject: LVM2/test t-metadata.sh
Message-ID: <20101026125225.11493.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-26 12:52:25

Modified files:
	test           : t-metadata.sh 

Log message:
	Let's rely on the exit code and do not test for empty output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-metadata.sh	2010/08/16 23:21:20	1.5
+++ LVM2/test/t-metadata.sh	2010/10/26 12:52:25	1.6
@@ -36,13 +36,11 @@
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -n $lv2 -m2 -l 2  $vg
 	#lvchange -an $vg
-	lvchange -an $vg/$lv1 >out$mdacp 2>&1 
-	lvchange -an $vg/$lv2 >>out$mdacp 2>&1 
-	test ! -s out$mdacp
+	lvchange -an $vg/$lv1
+	lvchange -an $vg/$lv2
 	vgchange -ay $vg
 	lvchange -vvvv -an $vg/$lv1 >out$mdacp 2>&1 
 	lvchange -vvvv -an $vg/$lv2 >>out$mdacp 2>&1 
-	eval run$mdacp=$(wc -l <out$mdacp)
 	vgremove -f $vg
 done
 not grep "Cached VG .* incorrect PV list" out0


