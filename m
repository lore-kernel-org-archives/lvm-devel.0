From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:37:53 -0000
Subject: LVM2/test t-mirror-basic.sh
Message-ID: <20081110123753.5404.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:37:53

Modified files:
	test           : t-mirror-basic.sh 

Log message:
	bz429342 lvcreate --nosync
	bz192865 lvconvert logtype of an inactive mirror lv
	(both by jstava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-mirror-basic.sh	2008/11/10 12:32:00	1.5
+++ LVM2/test/t-mirror-basic.sh	2008/11/10 12:37:53	1.6
@@ -168,6 +168,13 @@
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
 
+#COMM "lvcreate --nosync is in 100% sync after creation (bz429342)"
+prepare_lvs_ 
+lvcreate -l2 -m1 --nosync -n $lv1 $vg $dev1 $dev2 $dev3:0-1 2>out
+grep "New mirror won't be synchronised." out
+lvs -o copy_percent --noheadings $vg/$lv1 |grep 100.00
+check_and_cleanup_lvs_
+
 # ---
 # convert
 
@@ -186,20 +193,25 @@
 mimages_are_redundant_ $vg $lv1 
 check_and_cleanup_lvs_
 
+for status in active inactive; do 
+# bz192865 lvconvert log of an inactive mirror lv
 #COMM "convert from disklog to corelog"
 prepare_lvs_ 
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
-lvconvert --mirrorlog core $vg/$lv1 
+	test $status = "inactive" && lvchange -an $vg/$lv1
+	yes | lvconvert --mirrorlog core $vg/$lv1 
 mimages_are_redundant_ $vg $lv1 
 check_and_cleanup_lvs_
 
 #COMM "convert from corelog to disklog"
 prepare_lvs_ 
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+	test $status = "inactive" && lvchange -an $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1 
 mimages_are_redundant_ $vg $lv1 
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
+done
 
 # ---
 # resize


