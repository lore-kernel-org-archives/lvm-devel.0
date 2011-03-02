From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2011 00:29:59 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20110302002959.28365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-02 00:29:58

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
	Include an implicit dm_task_update_nodes() within dm_udev_wait().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.450&r2=1.451
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW_DM	2011/03/01 23:27:06	1.450
+++ LVM2/WHATS_NEW_DM	2011/03/02 00:29:57	1.451
@@ -1,5 +1,7 @@
 Version 1.02.64 - 
 ===================================
+  Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
+  Include an implicit dm_task_update_nodes() within dm_udev_wait().
   Fix _create_and_load_v4 not to lose the --addnodeoncreate setting (1.02.62).
   Add inactive table query support for kernel driver >= 4.11.6 (RHEL 5.7).
   Log debug open_count in _node_has_closed_parents().
--- LVM2/libdm/libdm-common.c	2011/02/04 22:07:44	1.110
+++ LVM2/libdm/libdm-common.c	2011/03/02 00:29:57	1.111
@@ -1044,6 +1044,8 @@
 
 int dm_udev_wait(uint32_t cookie)
 {
+	update_devs();
+
 	return 1;
 }
 
@@ -1380,7 +1382,7 @@
 	return 1;
 }
 
-int dm_udev_wait(uint32_t cookie)
+static int _udev_wait(uint32_t cookie)
 {
 	int semid;
 	struct sembuf sb = {0, 0, 0};
@@ -1420,4 +1422,11 @@
 	return _udev_notify_sem_destroy(cookie, semid);
 }
 
+int dm_udev_wait(uint32_t cookie)
+{
+	int r = _udev_wait(cookie);
+
+	update_devs();
+}
+
 #endif		/* UDEV_SYNC_SUPPORT */
--- LVM2/libdm/libdm-deptree.c	2011/02/18 16:13:56	1.90
+++ LVM2/libdm/libdm-deptree.c	2011/03/02 00:29:57	1.91
@@ -1922,7 +1922,6 @@
 		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
 			stack;
 		dm_tree_set_cookie(dnode, 0);
-		dm_task_update_nodes();
 	}
 
 	return r;
--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/01 23:27:07	1.95
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/02 00:29:57	1.96
@@ -2025,7 +2025,8 @@
 		}
 	}
 
-	if (ioctl_with_uevent && !_check_uevent_generated(dmi)) {
+	if (ioctl_with_uevent && dm_udev_get_sync_support() &&
+	    !_check_uevent_generated(dmi)) {
 		log_debug("Uevent not generated! Calling udev_complete "
 			  "internally to avoid process lock-up.");
 		_udev_complete(dmt);
--- LVM2/tools/dmsetup.c	2011/02/18 16:17:57	1.154
+++ LVM2/tools/dmsetup.c	2011/03/02 00:29:58	1.155
@@ -658,22 +658,16 @@
 
 	r = 1;
 
+      out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);
 
-	if (_switches[VERBOSE_ARG])
+	if (r && _switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
 	dm_task_destroy(dmt);
 
 	return r;
-
-      out:
-	if (!_udev_cookie)
-		(void) dm_udev_wait(cookie);
-	dm_task_destroy(dmt);
-
-	return r;
 }
 
 static int _rename(int argc, char **argv, void *data __attribute__((unused)))
@@ -721,6 +715,7 @@
       out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);
+
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1242,14 +1237,15 @@
 
 	r = dm_task_run(dmt);
 
-	if (r && display && _switches[VERBOSE_ARG])
-		r = _display_info(dmt);
-
       out:
 	if (!_udev_cookie && udev_wait_flag)
 		(void) dm_udev_wait(cookie);
 
+	if (r && display && _switches[VERBOSE_ARG])
+		r = _display_info(dmt);
+
 	dm_task_destroy(dmt);
+
 	return r;
 }
 


