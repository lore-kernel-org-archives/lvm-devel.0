From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2011 16:46:50 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20110117164650.13050.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-17 16:46:50

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.268&r2=1.269
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1881&r2=1.1882

--- LVM2/VERSION	2011/01/10 14:51:33	1.268
+++ LVM2/VERSION	2011/01/17 16:46:50	1.269
@@ -1 +1 @@
-2.02.81(2)-cvs (2011-01-10)
+2.02.81(2)-cvs (2011-01-17)
--- LVM2/WHATS_NEW	2011/01/17 15:16:55	1.1881
+++ LVM2/WHATS_NEW	2011/01/17 16:46:50	1.1882
@@ -1,12 +1,13 @@
-Version 2.02.81 -
+Version 2.02.81 - 17th January 2011
 ===================================
-  Do not scan devices unnecessarily in dev_reset_error_count().
-  Skip unnecessary lock_vol() call after volume deactivation.
-  Extend exec_cmd params to specify, when device sync is needed.
+  Do not scan devices in dev_reset_error_count().
+  Skip unnecessary LOCK_NULL unlock call during volume deactivation.
+  Skip fs_unlock when calling exec_cmd within activation code (for modprobe).
+  Extend exec_cmd params to specify when device sync (fs_unlock) is needed.
   Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
   Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.
   Accept fusion fio in device type filter.
-  Add disk to mirrored log type conversion.
+  Add disk to allowed mirrored log type conversions.
 
 Version 2.02.80 - 10th January 2011
 ===================================


