From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2010 19:32:59 -0000
Subject: LVM2/test t-lvconvert-mirror.sh t-mirror-lvcon ...
Message-ID: <20100412193259.3662.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-12 19:32:58

Modified files:
	test           : t-lvconvert-mirror.sh 
Removed files:
	test           : t-mirror-lvconvert-usage.sh 

Log message:
	Absorb t-mirror-lvconvert-usage into t-lvconvert-mirror.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE

--- LVM2/test/t-lvconvert-mirror.sh	2010/04/12 19:16:24	1.1
+++ LVM2/test/t-lvconvert-mirror.sh	2010/04/12 19:32:58	1.2
@@ -23,6 +23,11 @@
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
 lvremove -ff $vg
+# and now try removing a specific leg (bz453643)
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvconvert -m0 $vg/$lv1 $dev2
+check lv_on $vg/$lv1 $dev1
+lvremove -ff $vg
 
 # convert from disklog to corelog, active
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
@@ -55,3 +60,11 @@
 lvcreate -l2 -n $lv1 $vg $dev1
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
 lvremove -ff $vg
+
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+lvconvert -m-1 $vg/$lv1 $dev1
+check mirror_images_on $lv1 $dev2 $dev4
+lvconvert -m-1 $vg/$lv1 $dev2
+check linear $vg $lv1
+check lv_on $vg/$lv1 $dev4
+


