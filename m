From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 06:09:26 -0000
Subject: LVM2/test t-lvconvert-mirror.sh
Message-ID: <20100512060926.17958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 06:09:25

Modified files:
	test           : t-lvconvert-mirror.sh 

Log message:
	Revert the huge device creation in t-lvconvert-mirror and downgrade the
	race-induced failure to a warning, until we have a better fix for this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-lvconvert-mirror.sh	2010/04/22 15:39:40	1.4
+++ LVM2/test/t-lvconvert-mirror.sh	2010/05/12 06:09:22	1.5
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
-aux prepare_vg 5 200
+aux prepare_vg 5
 
 # convert from linear to 2-way mirror
 lvcreate -l2 -n $lv1 $vg $dev1
@@ -65,14 +65,16 @@
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -l20 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0
 # FIXME:
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
-not lvconvert -m-1 $vg/$lv1 $dev1
+should not lvconvert -m-1 $vg/$lv1 $dev1
 while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do
 	sleep 1
 done
+lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0
+
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2


