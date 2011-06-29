From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 18:18:20 -0000
Subject: LVM2/test/lib aux.sh utils.sh
Message-ID: <20110629181820.775.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 18:18:19

Modified files:
	test/lib       : aux.sh utils.sh 

Log message:
	make udev teardown conditional on using udev

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/lib/aux.sh	2011/06/29 18:14:08	1.18
+++ LVM2/test/lib/aux.sh	2011/06/29 18:18:18	1.19
@@ -62,7 +62,7 @@
 
 teardown_devs() {
 	# Delete any remaining dm/udev semaphores
-	dmsetup udevcomplete_all -y
+	teardown_udev_cookies
 
 	test -n "$PREFIX" && {
 		rm -rf $TESTDIR/dev/$PREFIX*
--- LVM2/test/lib/utils.sh	2011/06/09 19:48:26	1.6
+++ LVM2/test/lib/utils.sh	2011/06/29 18:18:18	1.7
@@ -147,6 +147,12 @@
     fi
 }
 
+teardown_udev_cookies() {
+    if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+	dmsetup udevcomplete_all -y
+    fi
+}
+
 skip() {
     touch SKIP_THIS_TEST
     exit 200


