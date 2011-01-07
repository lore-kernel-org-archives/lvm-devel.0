From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 15:04:52 -0000
Subject: LVM2/test api/percent.sh lib/aux.sh lib/utils.sh
Message-ID: <20110107150452.31492.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 15:04:52

Modified files:
	test/api       : percent.sh 
	test/lib       : aux.sh utils.sh 

Log message:
	Skip the api/percent test on kernels <= 2.6.32.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/api/percent.sh	2011/01/05 00:16:21	1.3
+++ LVM2/test/api/percent.sh	2011/01/07 15:04:52	1.4
@@ -13,6 +13,9 @@
 
 . lib/test
 
+linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
+test $linux_minor -le 32 && skip
+
 aux prepare_devs 2
 vgcreate -c n -s 4k $vg $(cat DEVICES)
 lvcreate -n foo $vg -l 5
--- LVM2/test/lib/aux.sh	2011/01/07 13:04:17	1.4
+++ LVM2/test/lib/aux.sh	2011/01/07 15:04:52	1.5
@@ -10,11 +10,6 @@
 
 . lib/utils
 
-skip() {
-    touch SKIP_THIS_TEST
-    exit 1
-}
-
 prepare_clvmd() {
 	if test -z "$LVM_TEST_LOCKING" || test "$LVM_TEST_LOCKING" -ne 3 ; then
 		return 0 # not needed
--- LVM2/test/lib/utils.sh	2011/01/05 00:26:19	1.2
+++ LVM2/test/lib/utils.sh	2011/01/07 15:04:52	1.3
@@ -146,6 +146,11 @@
     fi
 }
 
+skip() {
+    touch SKIP_THIS_TEST
+    exit 200
+}
+
 . lib/paths || { echo >&2 you must run make first; exit 1; }
 
 PATH=$abs_top_builddir/test/lib:$PATH


