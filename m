From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2010 11:35:32 -0000
Subject: LVM2/test t-lvconvert-mirror.sh
Message-ID: <20101130113532.21653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-30 11:35:32

Modified files:
	test           : t-lvconvert-mirror.sh 

Log message:
	Fix a failing test (it used a combination of lvconvert parameters that is no
	longer permitted.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-lvconvert-mirror.sh	2010/08/17 22:01:41	1.7
+++ LVM2/test/t-lvconvert-mirror.sh	2010/11/30 11:35:32	1.8
@@ -223,8 +223,9 @@
 aux prepare_vg 5
 lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
 while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
-lvconvert -m1 --mirrorlog disk $vg/$lv1 $dev1
-check mirror $vg $lv1 $dev1
+lvconvert -m1 --mirrorlog disk $vg/$lv1
+check mirror $vg $lv1
+not check mirror $vg $lv1 core
 
 # ---
 # add mirror and disk log


