From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 21:07:21 -0000
Subject: LVM2/test t3000-lvcreate-pvtags.sh
Message-ID: <20070918210721.27742.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 21:07:21

Modified files:
	test           : t3000-lvcreate-pvtags.sh 

Log message:
	test/t3000-lvcreate-pvtags.sh: Use better test names.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t3000-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t3000-lvcreate-pvtags.sh	2007/09/18 14:02:22	1.2
+++ LVM2/test/t3000-lvcreate-pvtags.sh	2007/09/18 21:07:21	1.3
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
+test_description="ensure that lvcreate's select-by-tag code works"
 privileges_required_=1
 
 . ./test-lib.sh
@@ -56,24 +56,27 @@
   'pvcreate $pvs'
 
 vg=lvcreate-pvtags-vg-$$
-test_expect_success "Run this: vgcreate $vg $pvs" \
-  'vgcreate $vg $pvs'
-test_expect_success "Run this: pvchange --addtag fast $pvs" \
-  'pvchange --addtag fast $pvs'
-
-test_expect_success t 'lvcreate -l3 -i3 $vg @fast'
-test_expect_failure u 'lvcreate -l4 -i4 $vg @fast'
-test_expect_failure v 'lvcreate -l2 -i2 $vg /dev/mapper/pv1'
+test_expect_success \
+  'set up a VG with tagged PVs' \
+  'vgcreate $vg $pvs &&
+   pvchange --addtag fast $pvs'
+
+test_expect_success '3 stripes with 3 PVs (selected by tag, @fast) is fine' \
+  'lvcreate -l3 -i3 $vg @fast'
+test_expect_failure 'too many stripes(4) for 3 PVs' \
+  'lvcreate -l4 -i4 $vg @fast'
+test_expect_failure '2 stripes is too many with just one PV' \
+  'lvcreate -l2 -i2 $vg /dev/mapper/pv1'
 
-test_expect_success 'lvcreate mirror'           \
+test_expect_success 'lvcreate mirror' \
   'lvcreate -l1 -m1 $vg @fast'
-test_expect_success 'lvcreate mirror corelog'   \
+test_expect_success 'lvcreate mirror w/corelog' \
   'lvcreate -l1 -m2 --corelog $vg @fast'
-test_expect_failure 'lvcreate mirror'           \
+test_expect_failure 'lvcreate mirror w/no free PVs' \
   'lvcreate -l1 -m2 $vg @fast'
-test_expect_failure 'lvcreate mirror (corelog)' \
+test_expect_failure 'lvcreate mirror (corelog, w/no free PVs)' \
   'lvcreate -l1 -m3 --corelog $vg @fast'
-test_expect_failure 'lvcreate mirror'           \
+test_expect_failure 'lvcreate mirror with a single PV arg' \
   'lvcreate -l1 -m1 --corelog $vg /dev/mapper/pv1'
 
 test_done


