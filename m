From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Mar 2011 23:44:08 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110301234408.9014.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-01 23:44:08

Modified files:
	test/lib       : aux.sh 

Log message:
	Rather return success if skipping udev wait.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/lib/aux.sh	2011/03/01 22:28:27	1.9
+++ LVM2/test/lib/aux.sh	2011/03/01 23:44:07	1.10
@@ -370,8 +370,8 @@
 }
 
 udev_wait() {
-	pgrep udev >/dev/null || return
-	which udevadm >/dev/null || return
+	pgrep udev >/dev/null || return 0
+	which udevadm >/dev/null || return 0
 	if test -n "$1" ; then
 		udevadm settle --exit-if-exists=$1
 	else


