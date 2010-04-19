From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Apr 2010 22:44:43 -0000
Subject: LVM2/test t-snapshot-merge.sh
Message-ID: <20100419224443.31441.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-04-19 22:44:42

Modified files:
	test           : t-snapshot-merge.sh 

Log message:
	Add additional test to start the snapshot merge (which had just failed
	because an FS was mounted -- origin was still open).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-snapshot-merge.sh	2010/04/07 14:46:26	1.3
+++ LVM2/test/t-snapshot-merge.sh	2010/04/19 22:44:42	1.4
@@ -55,19 +55,24 @@
 lvremove -f $vg/$lv1
 
 
-# "onactivate merge" test -- refresh LV while FS is still mounted;
-# verify snapshot-origin target is still being used
+# "onactivate merge" test
 setup_merge $vg $lv1
 lvs -a
 mkdir test_mnt
 mount $(lvdev_ $vg $lv1) test_mnt
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-# an active merge uses the "snapshot-merge" target
 dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
-test $? = 0
+# -- refresh LV to start merge (now that FS is unmounted),
+#    an active merge uses the 'snapshot-merge' target
+lvchange --refresh $vg/$lv1
+dmsetup table ${vg}-${lv1} | grep -q " snapshot-merge "
+# -- don't care if merge is still active; lvremove at this point
+#    may test stopping an active merge
 lvremove -f $vg/$lv1
 
 


