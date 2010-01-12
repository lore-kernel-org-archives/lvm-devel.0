From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2010 14:19:46 -0000
Subject: LVM2/test t-snapshots-of-mirrors.sh
Message-ID: <20100112141946.15227.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-12 14:19:46

Modified files:
	test           : t-snapshots-of-mirrors.sh 

Log message:
	disable 'redundant' tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-snapshots-of-mirrors.sh	2010/01/11 21:27:49	1.2
+++ LVM2/test/t-snapshots-of-mirrors.sh	2010/01/12 14:19:46	1.3
@@ -22,10 +22,10 @@
 lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> redundant)
-lvconvert --mirrorlog redundant $vg/lv
+not lvconvert --mirrorlog redundant $vg/lv
 
 # Log conversion (redundant -> core)
-lvconvert --mirrorlog core $vg/lv
+# lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv


