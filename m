From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2009 15:47:52 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20090519154752.27013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-19 15:47:50

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Add test - lvconvert from linear (on multiple PVs) to mirror.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-mirror-lvconvert.sh	2008/11/10 12:41:52	1.7
+++ LVM2/test/t-mirror-lvconvert.sh	2009/05/19 15:47:50	1.8
@@ -312,4 +312,12 @@
 lvconvert -m0 $vg/$lv1
 lvconvert -m1 $vg/$lv1
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
+check_and_cleanup_lvs_
 
+# lvconvert from linear (on multiple PVs) to mirror
+prepare_lvs_
+lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
+lvconvert -m1 $vg/$lv1
+check_mirror_count_ $vg/$lv1 2
+check_mirror_log_ $vg/$lv1
+check_and_cleanup_lvs_


