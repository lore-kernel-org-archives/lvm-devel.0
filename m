From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 16:00:20 -0000
Subject: LVM2/test t-mirror-basic.sh t-pvmove-basic.sh ...
Message-ID: <20100407160020.8285.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 16:00:19

Modified files:
	test           : t-mirror-basic.sh t-pvmove-basic.sh 
	                 t-mirror-lvconvert-usage.sh 
	                 t-mirror-lvconvert.sh t-mirror-names.sh 
	                 t-mirror-vgreduce-removemissing.sh 

Log message:
	Avoid spurious skips in the testsuite due to obsoleted
	dmsetup_has_dm_devdir_support_.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-mirror-basic.sh	2010/04/07 14:46:26	1.8
+++ LVM2/test/t-mirror-basic.sh	2010/04/07 16:00:19	1.9
@@ -14,8 +14,6 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 # ---------------------------------------------------------------------
 # Utilities
 
--- LVM2/test/t-pvmove-basic.sh	2010/04/07 14:46:26	1.7
+++ LVM2/test/t-pvmove-basic.sh	2010/04/07 16:00:19	1.8
@@ -14,8 +14,6 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 # ---------------------------------------------------------------------
 # Utilities
 
--- LVM2/test/t-mirror-lvconvert-usage.sh	2008/11/11 15:29:24	1.1
+++ LVM2/test/t-mirror-lvconvert-usage.sh	2010/04/07 16:00:19	1.2
@@ -10,11 +10,8 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 aux prepare_vg 5
 
-
 lv_is_on_() {
 	local lv=$1 #allready vg/lv
 	shift 1
--- LVM2/test/t-mirror-lvconvert.sh	2010/04/06 23:04:45	1.22
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/07 16:00:19	1.23
@@ -11,8 +11,6 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 mimages_are_redundant_ ()
 {
   local vg=$1
--- LVM2/test/t-mirror-names.sh	2010/01/22 21:59:42	1.5
+++ LVM2/test/t-mirror-names.sh	2010/04/07 16:00:19	1.6
@@ -14,8 +14,6 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 # ---------------------------------------------------------------------
 # Utilities
 
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/31 03:56:25	1.8
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/04/07 16:00:19	1.9
@@ -13,8 +13,6 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
-
 lv_is_on_ ()
 {
 	local lv=$vg/$1


