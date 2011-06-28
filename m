From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jun 2011 00:11:48 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110628001148.4134.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-28 00:11:46

Modified files:
	test/lib       : aux.sh 

Log message:
	Selectively enable/disable udev rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/lib/aux.sh	2011/03/04 14:19:18	1.11
+++ LVM2/test/lib/aux.sh	2011/06/28 00:11:46	1.12
@@ -313,6 +313,11 @@
 
 lvmconf() {
     if test -z "$LVM_TEST_LOCKING"; then LVM_TEST_LOCKING=1; fi
+    if test "$DM_DEV_DIR" = "/dev"; then
+	UDEV_RULES=1;
+    else
+	UDEV_RULES=0;
+    fi
     test -f CONFIG_VALUES || {
         cat > CONFIG_VALUES <<-EOF
 devices/dir = "$DM_DEV_DIR"
@@ -336,7 +341,7 @@
 global/si_unit_consistency = 1
 global/fallback_to_local_locking = 0
 activation/udev_sync = 1
-activation/udev_rules = 1
+activation/udev_rules = $UDEV_RULES
 activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50


