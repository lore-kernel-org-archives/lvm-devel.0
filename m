From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 2 Aug 2011 10:49:58 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h
Message-ID: <20110802104958.29766.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-02 10:49:57

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 

Log message:
	Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
	
	This should be set by default! Normally we have "activation/udev_sync = 1"
	in lvm.conf (example.conf.in). But if we use lvm2 without any config file
	(or without a definition within '--config' option) the DEFAULT_UDEV_SYNC
	is used instead. Together with verify_udev_operations=0 (when we rely on
	udev fully), this can cause races as the node could be missing when needed.
	
	(See also https://bugzilla.redhat.com/show_bug.cgi?id=723144)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2044&r2=1.2045
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2011/07/28 12:57:26	1.2044
+++ LVM2/WHATS_NEW	2011/08/02 10:49:57	1.2045
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
   Add systemd unit file to provide lvm2 monitoring.
   Compare also file size to detect changed config file.
 
--- LVM2/lib/config/defaults.h	2011/07/01 14:09:20	1.78
+++ LVM2/lib/config/defaults.h	2011/08/02 10:49:57	1.79
@@ -77,7 +77,7 @@
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
-#define DEFAULT_UDEV_SYNC 0
+#define DEFAULT_UDEV_SYNC 1
 #define DEFAULT_VERIFY_UDEV_OPERATIONS 0
 #define DEFAULT_ACTIVATION_CHECKS 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */


