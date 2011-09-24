From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:15:14 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110924211514.3746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:15:14

Modified files:
	test/lib       : aux.sh 

Log message:
	Allow overwrite for VERIFY_UDEV
	
	When running tests it might be useful to have an override option when
	testing on real /dev  and some broken system (i.e. Debian and its rules).
	
	So one can use:
	
	LVM_TEST_DEVDIR=/dev LVM_VERIFY_UDEV=1 make check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/test/lib/aux.sh	2011/09/24 20:54:36	1.30
+++ LVM2/test/lib/aux.sh	2011/09/24 21:15:13	1.31
@@ -371,9 +371,9 @@
 lvmconf() {
     if test -z "$LVM_TEST_LOCKING"; then LVM_TEST_LOCKING=1; fi
     if test "$DM_DEV_DIR" = "/dev"; then
-	VERIFY_UDEV=0;
+	LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0};
     else
-	VERIFY_UDEV=1;
+	LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-1};
     fi
     test -f CONFIG_VALUES || {
         cat > CONFIG_VALUES <<-EOF
@@ -401,7 +401,7 @@
 activation/checks = 1
 activation/udev_sync = 1
 activation/udev_rules = 1
-activation/verify_udev_operations = $VERIFY_UDEV
+activation/verify_udev_operations = $LVM_VERIFY_UDEV
 activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50


