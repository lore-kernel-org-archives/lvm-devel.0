From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Mar 2010 14:47:36 -0000
Subject: LVM2 ./WHATS_NEW test/test-utils.sh
Message-ID: <20100323144736.5035.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-03-23 14:47:36

Modified files:
	.              : WHATS_NEW 
	test           : test-utils.sh 

Log message:
	Export and use only valid cookie value in test suite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1473&r2=1.1474
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2010/03/23 14:24:04	1.1473
+++ LVM2/WHATS_NEW	2010/03/23 14:47:35	1.1474
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Export and use only valid cookie value in test suite.
   Remove const modifier for struct volume_group* from process_each_lv_in_vg().
   Don't allow resizing of internal logical volumes.
   Fix libdevmapper-event pkgconfig version string to match libdevmapper.
--- LVM2/test/test-utils.sh	2010/03/18 09:27:39	1.24
+++ LVM2/test/test-utils.sh	2010/03/23 14:47:35	1.25
@@ -43,12 +43,16 @@
 
 init_udev_transaction() {
 	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
-		export DM_UDEV_COOKIE=$(dmsetup udevcreatecookie)
+		COOKIE=$(dmsetup udevcreatecookie)
+		# Cookie is not generated if udev is not running!
+		if test -n "$COOKIE"; then
+			export DM_UDEV_COOKIE=$COOKIE
+		fi
 	fi
 }
 
 finish_udev_transaction() {
-	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+	if test "$DM_UDEV_SYNCHRONISATION" = 1 -a -n "$DM_UDEV_COOKIE"; then
 		dmsetup udevreleasecookie
 		unset DM_UDEV_COOKIE
 	fi


