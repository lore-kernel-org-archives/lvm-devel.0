From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jan 2008 02:20:48 -0000
Subject: LVM2/test t-mirror-basic.sh t-mirror-lvconvert.sh
Message-ID: <20080117022048.29442.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-17 02:20:48

Modified files:
	test           : t-mirror-basic.sh t-mirror-lvconvert.sh 

Log message:
	Fix descriptions in the newly added test cases

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-mirror-basic.sh	2008/01/16 21:21:22	1.1
+++ LVM2/test/t-mirror-basic.sh	2008/01/17 02:20:48	1.2
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure that pvmove works with basic options"
+test_description="ensure that basic operations on mirrored LV works"
 privileges_required_=1
 
 . ./test-lib.sh
--- LVM2/test/t-mirror-lvconvert.sh	2008/01/16 21:21:22	1.1
+++ LVM2/test/t-mirror-lvconvert.sh	2008/01/17 02:20:48	1.2
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="ensure that pvmove works with basic options"
+test_description="ensure that lvconvert for mirrored LV works"
 privileges_required_=1
 
 . ./test-lib.sh
@@ -44,7 +44,7 @@
 nr_pvs=5
 pvsize=$((80 * 1024 * 2))
 
-vg=mirror-basic-vg-$$
+vg=mirror-lvconvert-vg-$$
 lv1=lv1
 lv2=lv2
 lv3=lv3


