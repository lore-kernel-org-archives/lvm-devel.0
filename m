From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 00:08:49 -0000
Subject: LVM2/test/shell lvconvert-mirror.sh
Message-ID: <20120302000849.8649.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 00:08:49

Modified files:
	test/shell     : lvconvert-mirror.sh 

Log message:
	Wait for mirror in sync
	
	1s could be too short

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvconvert-mirror.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/lvconvert-mirror.sh	2012/03/02 00:08:48	1.3
@@ -11,6 +11,11 @@
 
 . lib/test
 
+wait_for_mirror_in_sync_()
+{
+	while [ $(lvs --noheadings -o copy_percent $1) != "100.00" ]; do sleep 1; done
+}
+
 # convert from linear to 2-way mirror
 aux prepare_vg 5
 lvcreate -l2 -n $lv1 $vg $dev1
@@ -79,7 +84,7 @@
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0 # If the above "should" failed...
 
-sleep 1
+wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2
@@ -201,7 +206,7 @@
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
 aux prepare_vg 5
 lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
-while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
+wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m0 $vg/$lv1 $dev1
 check linear $vg $lv1
 
@@ -223,7 +228,7 @@
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
 aux prepare_vg 5
 lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
-while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
+wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
 not check mirror $vg $lv1 core


