From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2010 01:43:46 -0000
Subject: LVM2/test t-pvmove-basic.sh
Message-ID: <20100408014346.9191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-08 01:43:46

Modified files:
	test           : t-pvmove-basic.sh 

Log message:
	another incorrect test that should have been failing before

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-pvmove-basic.sh	2010/04/07 16:00:19	1.8
+++ LVM2/test/t-pvmove-basic.sh	2010/04/08 01:43:46	1.9
@@ -236,7 +236,7 @@
 
 #COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
 prepare_lvs_ 
-pvmove -i1 $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5 
+pvmove -i1 --alloc anywhere $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5 
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev3 $dev4 $dev5 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 


