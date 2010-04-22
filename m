From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Apr 2010 15:39:44 -0000
Subject: LVM2/test t-lvconvert-mirror.sh t-mirror-lvcon ...
Message-ID: <20100422153944.876.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-22 15:39:43

Modified files:
	test           : t-lvconvert-mirror.sh t-mirror-lvconvert.sh 

Log message:
	The following tests in the testsuite have race conditions:
	1) Test that the primary mirror image cannot be removed while
	the mirror set is sync'ing.
	2) Test that you cannot start a second mirror up-convert while
	one is already in progress.
	
	The trouble is that if the sync/conversion finishes before the
	tests occur, the tests will fail by why of success where there
	should have been failure.  This means the sync/conversion must
	happen very quickly, but this is possible because the test
	mirrors we are creating are so small.
	
	In order to decrease the likelyhood of these test failing (or
	more correctly, failing to test the right thing), I've increase
	the size of the mirrors.  It will still be remotely possible that
	the tests will fail (by way of failing to test the right thing).
	If this continues to happen, more involved mechanisms will need
	to be put in place.  (Perhaps these will still be created, but
	this change should be a remedy until that time.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/test/t-lvconvert-mirror.sh	2010/04/21 13:55:08	1.3
+++ LVM2/test/t-lvconvert-mirror.sh	2010/04/22 15:39:40	1.4
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
-aux prepare_vg 5 80
+aux prepare_vg 5 200
 
 # convert from linear to 2-way mirror
 lvcreate -l2 -n $lv1 $vg $dev1
@@ -65,7 +65,7 @@
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -l8 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+lvcreate -l20 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0
 # FIXME:
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
--- LVM2/test/t-mirror-lvconvert.sh	2010/04/21 14:04:26	1.25
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/22 15:39:40	1.26
@@ -112,7 +112,7 @@
   ! grep tmp out
 }
 
-aux prepare_vg 5
+aux prepare_vg 5 200
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
@@ -155,7 +155,7 @@
 # add 1 mirror
 prepare_lvs_
 lvs -a -o+devices $vg
-lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l15 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1


