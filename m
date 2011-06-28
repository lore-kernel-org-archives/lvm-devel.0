From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jun 2011 00:38:27 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110628003827.4608.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-28 00:38:26

Modified files:
	test/lib       : aux.sh 

Log message:
	Change to still sync with udev (to test waiting for rules) then to verify udev
	operations like it used to (which will perform them on systems with
	non-std dev dirs where test udev rules aren't installed).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/lib/aux.sh	2011/06/28 00:11:46	1.12
+++ LVM2/test/lib/aux.sh	2011/06/28 00:38:26	1.13
@@ -314,9 +314,9 @@
 lvmconf() {
     if test -z "$LVM_TEST_LOCKING"; then LVM_TEST_LOCKING=1; fi
     if test "$DM_DEV_DIR" = "/dev"; then
-	UDEV_RULES=1;
+	VERIFY_UDEV=0;
     else
-	UDEV_RULES=0;
+	VERIFY_UDEV=1;
     fi
     test -f CONFIG_VALUES || {
         cat > CONFIG_VALUES <<-EOF
@@ -341,7 +341,8 @@
 global/si_unit_consistency = 1
 global/fallback_to_local_locking = 0
 activation/udev_sync = 1
-activation/udev_rules = $UDEV_RULES
+activation/udev_rules = 1
+activation/verify_udev_operations = $VERIFY_UDEV
 activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50


