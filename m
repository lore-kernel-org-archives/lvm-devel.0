From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 18:01:51 -0000
Subject: LVM2 lib/activate/dev_manager.c tools/dmsetup. ...
Message-ID: <20090803180151.29215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 18:01:49

Modified files:
	lib/activate   : dev_manager.c 
	tools          : dmsetup.c 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	                 libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 

Log message:
	Manage without dm_udev_cleanup?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/activate/dev_manager.c	2009/08/03 11:20:16	1.155
+++ LVM2/lib/activate/dev_manager.c	2009/08/03 18:01:45	1.156
@@ -1114,6 +1114,7 @@
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
+	int r;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -1132,12 +1133,12 @@
 			continue;
 
 		dm_tree_set_cookie(root, 0);
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid))) {
-			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
-			return_0;
-		}
+		r = dm_tree_deactivate_children(root, uuid, strlen(uuid));
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
 			stack;
+
+		if (!r)
+			return_0;
 	}
 
 	return 1;
@@ -1171,12 +1172,11 @@
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		dm_tree_set_cookie(root, 0);
-		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
-			goto_out;
-		}
+		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
 			stack;
+		if (!r)
+			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
 			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
@@ -1196,24 +1196,22 @@
 
 		/* Preload any devices required before any suspensions */
 		dm_tree_set_cookie(root, 0);
-		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-			(void) dm_udev_cleanup(dm_tree_get_cookie(root));
-			goto_out;
-		}
+		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
 			stack;
+		if (!r)
+			goto_out;
 
 		if (dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
 			dm_tree_set_cookie(root, 0);
-			if (!dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1)) {
-				(void) dm_udev_cleanup(dm_tree_get_cookie(root));
-				goto_out;
-			}
+			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 			if (!dm_udev_wait(dm_tree_get_cookie(root)))
 				stack;
+			if (!r)
+				goto_out;
 		}
 
 		if (!_create_lv_symlinks(dm, root)) {
--- LVM2/tools/dmsetup.c	2009/08/03 11:20:15	1.119
+++ LVM2/tools/dmsetup.c	2009/08/03 18:01:46	1.120
@@ -588,12 +588,8 @@
 		dm_udev_set_sync_support(0);
 
 	if (!dm_task_set_cookie(dmt, &cookie) ||
-	    !dm_task_run(dmt)) {
-		(void) dm_udev_cleanup(cookie);
+	    !dm_task_run(dmt))
 		goto out;
-	}
-
-	(void) dm_udev_wait(cookie);
 
 	r = 1;
 
@@ -601,6 +597,7 @@
 		r = _display_info(dmt);
 
       out:
+	(void) dm_udev_wait(cookie);
 	dm_task_destroy(dmt);
 
 	return r;
@@ -626,16 +623,13 @@
 		goto out;
 
 	if (!dm_task_set_cookie(dmt, &cookie) ||
-	    !dm_task_run(dmt)) {
-		(void) dm_udev_cleanup(cookie);
+	    !dm_task_run(dmt))
 		goto out;
-	}
-
-	(void) dm_udev_wait(cookie);
 
 	r = 1;
 
       out:
+	(void) dm_udev_wait(cookie);
 	dm_task_destroy(dmt);
 
 	return r;
@@ -816,24 +810,18 @@
 				    _read_ahead_flags))
 		goto out;
 
-	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie)) {
-		(void) dm_udev_cleanup(cookie);
+	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie))
 		goto out;
-	}
 
 	r = dm_task_run(dmt);
 
-	if (udev_wait_flag) {
-		if (r)
-			(void) dm_udev_wait(cookie);
-		else
-			(void) dm_udev_cleanup(cookie);
-	}
-
 	if (r && display && _switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
       out:
+	if (udev_wait_flag)
+		(void) dm_udev_wait(cookie);
+
 	dm_task_destroy(dmt);
 	return r;
 }
--- LVM2/libdm/.exported_symbols	2009/07/31 18:30:31	1.41
+++ LVM2/libdm/.exported_symbols	2009/08/03 18:01:47	1.42
@@ -161,4 +161,3 @@
 dm_udev_get_sync_support
 dm_udev_complete
 dm_udev_wait
-dm_udev_cleanup
--- LVM2/libdm/libdevmapper.h	2009/07/31 18:30:32	1.94
+++ LVM2/libdm/libdevmapper.h	2009/08/03 18:01:47	1.95
@@ -1023,6 +1023,5 @@
 int dm_udev_get_sync_support(void);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
-int dm_udev_cleanup(uint32_t cookie);
 
 #endif				/* LIB_DEVICE_MAPPER_H */
--- LVM2/libdm/libdm-common.c	2009/08/03 11:20:16	1.71
+++ LVM2/libdm/libdm-common.c	2009/08/03 18:01:47	1.72
@@ -174,6 +174,7 @@
 	dmt->no_open_count = 0;
 	dmt->read_ahead = DM_READ_AHEAD_AUTO;
 	dmt->read_ahead_flags = 0;
+	dmt->cookie_set = 0;
 
 	return dmt;
 }
@@ -799,11 +800,6 @@
 	return 1;
 }
 
-int dm_udev_cleanup(uint32_t cookie)
-{
-	return 1;
-}
-
 #else		/* UDEV_SYNC_SUPPORT */
 
 void dm_udev_set_sync_support(int sync_with_udev)
@@ -821,7 +817,8 @@
 	if (!(cookie >> 16 & COOKIE_MAGIC)) {
 		log_error("Could not continue to access notification "
 			  "semaphore identified by cookie value %"
-			  PRIu32 " (0x%x). Incorrect cookie prefix.");
+			  PRIu32 " (0x%x). Incorrect cookie prefix.",
+			  cookie, cookie);
 		return 0;
 	}
 
@@ -952,7 +949,7 @@
 		log_error("semid %d: semctl failed: %s", gen_semid, strerror(errno));
 		/* We have to destroy just created semaphore
 		 * so it won't stay in the system. */
-		_udev_notify_sem_destroy(gen_semid, gen_cookie);
+		(void) _udev_notify_sem_destroy(gen_semid, gen_cookie);
 		goto bad;
 	}
 
@@ -996,6 +993,7 @@
 	}
 
 	dmt->event_nr = *cookie;
+	dmt->cookie_set = 1;
 	return 1;
 
 bad:
@@ -1039,7 +1037,7 @@
 			  "semaphore identified by cookie value %" PRIu32 " (0x%x) "
 			  "to initialize waiting for incoming notifications.",
 			  cookie, cookie);
-		_udev_notify_sem_destroy(semid, cookie);
+		(void) _udev_notify_sem_destroy(semid, cookie);
 		return 0;
 	}
 
@@ -1050,23 +1048,11 @@
 		log_error("Could not set wait state for notification semaphore "
 			  "identified by cookie value %" PRIu32 " (0x%x): %s",
 			  cookie, cookie, strerror(errno));
-		_udev_notify_sem_destroy(semid, cookie);
+		(void) _udev_notify_sem_destroy(semid, cookie);
 		return 0;
 	}
 
 	return _udev_notify_sem_destroy(semid, cookie);
 }
 
-int dm_udev_cleanup(uint32_t cookie)
-{
-	int semid;
-
-	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
-		return 1;
-
-	if (!_get_cookie_sem(cookie, &semid))
-		return_0;
-
-	return _udev_notify_sem_destroy(semid, cookie);
-}
 #endif		/* UDEV_SYNC_SUPPORT */
--- LVM2/libdm/libdm-deptree.c	2009/07/31 18:30:32	1.54
+++ LVM2/libdm/libdm-deptree.c	2009/08/03 18:01:47	1.55
@@ -845,9 +845,6 @@
 
 	r = dm_task_run(dmt);
 
-	if (!r)
-		(void) dm_udev_complete(*cookie);
-
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
 	rm_dev_node(name);
 
@@ -888,9 +885,6 @@
 
 	r = dm_task_run(dmt);
 
-	if (!r)
-		(void) dm_udev_complete(*cookie);
-
 out:
 	dm_task_destroy(dmt);
 
@@ -934,8 +928,6 @@
 
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, newinfo);
-	else
-		(void) dm_udev_complete(*cookie);
 
 out:
 	dm_task_destroy(dmt);
--- LVM2/libdm/ioctl/libdm-iface.c	2009/07/31 15:53:12	1.59
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/08/03 18:01:48	1.60
@@ -1742,9 +1742,18 @@
 	if (!_open_control())
 		return 0;
 
+	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:
-	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor)))
+	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor))) {
+		/*
+		 * If an operation that uses a cookie fails, decrement the 
+		 * semaphore instead of udev.
+		 * FIXME Review error paths: found one where uevent fired too.
+		 */
+		if (dmt->cookie_set)
+			dm_udev_complete(dmt->event_nr);
 		return 0;
+	}
 
 	if (dmi->flags & DM_BUFFER_FULL_FLAG) {
 		switch (dmt->type) {
--- LVM2/libdm/ioctl/libdm-targets.h	2009/06/17 20:55:25	1.24
+++ LVM2/libdm/ioctl/libdm-targets.h	2009/08/03 18:01:48	1.25
@@ -60,6 +60,7 @@
 	int skip_lockfs;
 	int suppress_identical_reload;
 	uint64_t existing_table_size;
+	int cookie_set;
 
 	char *uuid;
 };


