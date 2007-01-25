From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2007 23:03:48 -0000
Subject: LVM2/lib activate/dev_manager.c filters/filter.c
Message-ID: <20070125230348.28682.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-25 23:03:48

Modified files:
	lib/activate   : dev_manager.c 
	lib/filters    : filter.c 

Log message:
	also ignore mirrors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/lib/activate/dev_manager.c	2007/01/25 21:22:30	1.119
+++ LVM2/lib/activate/dev_manager.c	2007/01/25 23:03:47	1.120
@@ -159,9 +159,14 @@
 {
 	struct dm_task *dmt;
 	struct dm_info info;
+	const char *name;
+        uint64_t start, length;
+        char *target_type = NULL;
+        char *params;
+	void *next = NULL;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
 		log_error("Failed to allocate dm_task struct to check dev status");
 		return 0;
 	}
@@ -180,7 +185,18 @@
 	if (!info.exists || info.suspended)
 		goto out;
 
+	name = dm_task_get_name(dmt);
+
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
+	/* For now, we exclude all mirrors */
+
+        do {
+                next = dm_get_next_target(dmt, next, &start, &length,
+                                          &target_type, &params);
+                /* Skip if target type doesn't match */
+                if (!strcmp(target_type, "mirror"))
+			goto out;
+        } while (next);
 
 	/* FIXME Also check dependencies? */
 
--- LVM2/lib/filters/filter.c	2007/01/25 21:22:30	1.38
+++ LVM2/lib/filters/filter.c	2007/01/25 23:03:48	1.39
@@ -94,7 +94,7 @@
 
 	/* Skip suspended devices */
 	if (MAJOR(dev->dev) == _device_mapper_major &&
-	    ignore_suspended_devices() && device_is_usable(dev->dev)) {
+	    ignore_suspended_devices() && !device_is_usable(dev->dev)) {
 		log_debug("%s: Skipping: Suspended dm device", name);
 		return 0;
 	}


