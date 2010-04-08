From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2010 01:58:07 -0000
Subject: LVM2/test t-pvmove-basic.sh
Message-ID: <20100408015807.30715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-08 01:58:07

Modified files:
	test           : t-pvmove-basic.sh 

Log message:
	And another test that should have been failing - normal allocation policy
	does not put stripes on the same disk as each other!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/t-pvmove-basic.sh	2010/04/08 01:43:46	1.9
+++ LVM2/test/t-pvmove-basic.sh	2010/04/08 01:58:06	1.10
@@ -228,7 +228,7 @@
 
 #COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
 prepare_lvs_ 
-pvmove -i1 $dev2:0-2 $dev5:5-5 $dev4:5-6 
+pvmove -i1 --alloc anywhere $dev2:0-2 $dev5:5-5 $dev4:5-6 
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev5 $dev4 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -266,7 +266,7 @@
 prepare_lvs_ 
 pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5 
 lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
+#lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
 lv_not_changed_ $vg/$lv3 
 check_and_cleanup_lvs_
 


