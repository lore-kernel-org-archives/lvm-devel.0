From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Nov 2009 12:43:23 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20091113124323.29353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-11-13 12:43:22

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Support udev flags even when udev_sync is disabled or not compiled in.
	
	This provides better support for environments where udev rules are installed
	but udev_sync is not compiled in (however, using udev_sync is highly
	recommended). It also provides consistent and expected functionality even
	when '--noudevsync' option is used.
	
	There is still requirement for kernel >= 2.6.31 for the flags to work though
	(it uses DM cookies to pass the flags into the kernel and set them in udev
	event environment that we can read in udev rules).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.313&r2=1.314
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW_DM	2009/11/13 12:33:27	1.313
+++ LVM2/WHATS_NEW_DM	2009/11/13 12:43:21	1.314
@@ -1,5 +1,6 @@
 Version 1.02.40 - 
 ===================================
+  Support udev flags even when udev_sync is disabled or not compiled in.
   Remove 'last_rule' from udev rules: honor ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}.
   Add dmsetup --inactive support.
   Add dm_task_query_inactive_table to libdevmapper for kernel driver >= 4.16.
--- LVM2/libdm/libdevmapper.h	2009/11/13 12:33:27	1.102
+++ LVM2/libdm/libdevmapper.h	2009/11/13 12:43:21	1.103
@@ -1032,6 +1032,10 @@
  * of udev rules we use by decoding the cookie prefix. When doing the
  * notification, we replace the cookie prefix with DM_COOKIE_MAGIC,
  * so we notify the right semaphore.
+ * It is still possible to use cookies for passing the flags to udev
+ * rules even when udev_sync is disabled. The base part of the cookie
+ * will be zero (there's no notification semaphore) and prefix will be
+ * set then. However, having udev_sync enabled is highly recommended.
  */
 #define DM_COOKIE_MAGIC 0x0D4D
 #define DM_UDEV_FLAGS_MASK 0xFFFF0000
@@ -1076,7 +1080,7 @@
 int dm_cookie_supported(void);
 
 /*
- * Udev notification functions.
+ * Udev synchronisation functions.
  */
 void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
--- LVM2/libdm/libdm-common.c	2009/11/06 00:43:09	1.90
+++ LVM2/libdm/libdm-common.c	2009/11/13 12:43:22	1.91
@@ -886,6 +886,8 @@
 
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
+	if (dm_cookie_supported())
+		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
 	*cookie = 0;
 
 	return 1;
@@ -1141,8 +1143,11 @@
 {
 	int semid;
 
+	if (dm_cookie_supported())
+		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
+
 	if (!dm_udev_get_sync_support()) {
-		dmt->event_nr = *cookie = 0;
+		*cookie = 0;
 		return 1;
 	}
 
@@ -1159,8 +1164,7 @@
 		goto bad;
 	}
 
-	dmt->event_nr = (~DM_UDEV_FLAGS_MASK & *cookie) |
-			(flags << DM_UDEV_FLAGS_SHIFT);
+	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
 
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
--- LVM2/libdm/libdm-deptree.c	2009/10/26 14:29:34	1.61
+++ LVM2/libdm/libdm-deptree.c	2009/11/13 12:43:22	1.62
@@ -1039,7 +1039,7 @@
 			continue;
 
 		if (!_deactivate_node(name, info.major, info.minor,
-				      &dnode->dtree->cookie, dnode->udev_flags)) {
+				      &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
--- LVM2/libdm/ioctl/libdm-iface.c	2009/11/06 00:43:09	1.65
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/11/13 12:43:22	1.66
@@ -1548,6 +1548,7 @@
 	task->gid = dmt->gid;
 	task->mode = dmt->mode;
 	/* FIXME: Just for udev_check in dm_task_run. Can we avoid this? */
+	task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
 	task->cookie_set = dmt->cookie_set;
 
 	r = dm_task_run(task);
--- LVM2/tools/dmsetup.c	2009/11/06 00:43:10	1.127
+++ LVM2/tools/dmsetup.c	2009/11/13 12:43:22	1.128
@@ -843,9 +843,17 @@
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
 
-	/* strip flags from the cookie and use cookie magic instead */
-	cookie = (cookie & ~DM_UDEV_FLAGS_MASK) |
-		  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
+	/*
+	 * Strip flags from the cookie and use cookie magic instead.
+	 * If the cookie has non-zero prefix and the base is zero then
+	 * this one carries flags to control udev rules only and it is
+	 * not meant to be for notification. Return with success in this
+	 * situation.
+	 */
+	if (!(cookie &= ~DM_UDEV_FLAGS_MASK))
+		return 1;
+
+	cookie |= DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT;
 
 	return dm_udev_complete(cookie);
 }


