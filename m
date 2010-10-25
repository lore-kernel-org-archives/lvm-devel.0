From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 10:37:35 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20101025103735.27121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 10:37:35

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	restrict last checkin to devs consisting entirely of error target

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1766&r2=1.1767
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205

--- LVM2/WHATS_NEW	2010/10/24 17:36:58	1.1766
+++ LVM2/WHATS_NEW	2010/10/25 10:37:34	1.1767
@@ -1,6 +1,6 @@
 Version 2.02.75 - 
 =====================================
-  Never scan a device which is using the error target.
+  Skip dm devices in scan if they contain only error targets.
   Fix strict-aliasing compile warning in partition table scanning.
   Add an option to automatically extend snapshots through dmeventd.
   Remove dependency on libm, floor() is replaced with integer algorithm.
--- LVM2/lib/activate/dev_manager.c	2010/10/24 17:36:59	1.204
+++ LVM2/lib/activate/dev_manager.c	2010/10/25 10:37:35	1.205
@@ -135,10 +135,11 @@
 	char *target_type = NULL;
 	char *params, *vgname = NULL, *lvname, *layer;
 	void *next = NULL;
+	int only_error_target = 1;
 	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		log_error("Failed to allocate dm_task struct to check dev status");
+		log_error("Failed to create dm_task struct to check dev status");
 		return 0;
 	}
 
@@ -159,6 +160,11 @@
 	name = dm_task_get_name(dmt);
 	uuid = dm_task_get_uuid(dmt);
 
+	if (!info.target_count) {
+		log_debug("%s: Empty device %s not usable.", dev_name(dev), name);
+		goto out;
+	}
+
 	if (info.suspended && ignore_suspended_devices()) {
 		log_debug("%s: Suspended device %s not usable.", dev_name(dev), name);
 		goto out;
@@ -191,13 +197,18 @@
 			goto out;
 		}
 
-		if (target_type && !strcmp(target_type, "error")) {
-			log_debug("%s: Error device %s not usable.",
-				  dev_name(dev), name);
-			goto out;
-		}
+		if (target_type && strcmp(target_type, "error"))
+			only_error_target = 0;
 	} while (next);
 
+	/* Skip devices consisting entirely of error targets. */
+	/* FIXME Deal with device stacked above error targets? */
+	if (only_error_target) {
+		log_debug("%s: Error device %s not usable.",
+			  dev_name(dev), name);
+		goto out;
+	}
+
 	/* FIXME Also check dependencies? */
 
 	/* Check internal lvm devices */


