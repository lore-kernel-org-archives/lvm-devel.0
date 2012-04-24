From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:17:50 -0000
Subject: LVM2/test/shell lvresize-rounding.sh
Message-ID: <20120424121750.31449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:17:49

Modified files:
	test/shell     : lvresize-rounding.sh 

Log message:
	Expect failure if the reduction doesn't really happen

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-rounding.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/shell/lvresize-rounding.sh	2012/04/11 12:53:46	1.3
+++ LVM2/test/shell/lvresize-rounding.sh	2012/04/24 12:17:49	1.4
@@ -83,7 +83,7 @@
 lvextend -l90%VG $vg/lv
 check vg_field $vg vg_free_count 0
 
-lvreduce -f -l-10%LV $vg/lv
+not lvreduce -f -l-10%LV $vg/lv
 check vg_field $vg vg_free_count 0
 
 lvreduce -f -l-20%LV $vg/lv


