From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Nov 2011 11:36:54 -0000
Subject: LVM2/test/shell lvconvert-mirror-basic-0.sh lv ...
Message-ID: <20111121113654.30073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-21 11:36:53

Modified files:
	test/shell     : lvconvert-mirror-basic-0.sh 
	                 lvconvert-mirror-basic-1.sh 
	                 lvconvert-mirror-basic-2.sh 
	                 lvconvert-mirror-basic-3.sh 

Log message:
	Fix the last fix (t-XXX -> shell/XXX).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvconvert-mirror-basic-0.sh	2011/11/21 11:25:35	1.2
+++ LVM2/test/shell/lvconvert-mirror-basic-0.sh	2011/11/21 11:36:53	1.3
@@ -8,5 +8,5 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./lvconvert-mirror-basic.sh
+. ./shell/lvconvert-mirror-basic.sh
 test_many 0
--- LVM2/test/shell/lvconvert-mirror-basic-1.sh	2011/11/21 11:25:36	1.2
+++ LVM2/test/shell/lvconvert-mirror-basic-1.sh	2011/11/21 11:36:53	1.3
@@ -8,5 +8,5 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./lvconvert-mirror-basic.sh
+. ./shell/lvconvert-mirror-basic.sh
 test_many 1
--- LVM2/test/shell/lvconvert-mirror-basic-2.sh	2011/11/21 11:25:36	1.2
+++ LVM2/test/shell/lvconvert-mirror-basic-2.sh	2011/11/21 11:36:53	1.3
@@ -8,5 +8,5 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./lvconvert-mirror-basic.sh
+. ./shell/lvconvert-mirror-basic.sh
 test_many 2
--- LVM2/test/shell/lvconvert-mirror-basic-3.sh	2011/11/21 11:25:36	1.2
+++ LVM2/test/shell/lvconvert-mirror-basic-3.sh	2011/11/21 11:36:53	1.3
@@ -8,5 +8,5 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./lvconvert-mirror-basic.sh
+. ./shell/lvconvert-mirror-basic.sh
 test_many 3


