From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Aug 2010 14:05:22 -0000
Subject: LVM2/lib activate/dev_manager.c filters/filter ...
Message-ID: <20100809140522.11854.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-08-09 14:05:20

Modified files:
	lib/activate   : dev_manager.c 
	lib/filters    : filter-persistent.c 

Log message:
	Never scan internal LVM devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/activate/dev_manager.c	2010/08/03 13:13:01	1.197
+++ LVM2/lib/activate/dev_manager.c	2010/08/09 14:05:16	1.198
@@ -153,12 +153,17 @@
 	if (!dm_task_get_info(dmt, &info))
 		goto_out;
 
-	if (!info.exists || info.suspended)
+	if (!info.exists)
 		goto out;
 
 	name = dm_task_get_name(dmt);
 	uuid = dm_task_get_uuid(dmt);
 
+	if (info.suspended && ignore_suspended_devices()) {
+		log_debug("%s: Suspended device %s not usable.", dev_name(dev), name);
+		goto out;
+	}
+
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
 	/* For now, we exclude all mirrors */
 
@@ -166,8 +171,8 @@
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 		/* Skip if target type doesn't match */
-		if (target_type && !strcmp(target_type, "mirror")) {
-			log_debug("%s: Mirror device not usable.", dev_name(dev));
+		if (target_type && !strcmp(target_type, "mirror") && ignore_suspended_devices()) {
+			log_debug("%s: Mirror device %s not usable.", dev_name(dev), name);
 			goto out;
 		}
 	} while (next);
--- LVM2/lib/filters/filter-persistent.c	2010/07/02 02:09:57	1.43
+++ LVM2/lib/filters/filter-persistent.c	2010/08/09 14:05:18	1.44
@@ -279,8 +279,8 @@
 		if (!l)
 			dm_list_iterate_items(sl, &dev->aliases)
 				dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE);
-		if (ignore_suspended_devices() && !device_is_usable(dev)) {
-                	log_debug("%s: Skipping (suspended/internal)", dev_name(dev));
+		if (!device_is_usable(dev)) {
+                	log_debug("%s: Skipping unusable device", dev_name(dev));
 			return 0;
 		}
 		return pf->real->passes_filter(pf->real, dev);


