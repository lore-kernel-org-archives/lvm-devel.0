From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 29 May 2012 08:09:19 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/commands/toolcontext.c ...
Message-ID: <20120529080919.4906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-29 08:09:13

Modified files:
	.              : WHATS_NEW_DM 
	lib/commands   : toolcontext.c 
	lib/misc       : lvm-wrappers.c lvm-wrappers.h 
	libdm          : libdevmapper.h 
	tools          : dmsetup.c 

Log message:
	Remove unsupported udev_get_dev_path libudev call used for checking udev dir.
	
	With latest changes in the udev, some deprecated functions were removed
	from libudev amongst which there was the "udev_get_dev_path" function
	we used to compare a device directory used in udev and directore set in
	libdevmapper. The "/dev" is hardcoded in udev now (udev version >= 183).
	
	Amongst other changes and from packager's point of view, it's also
	important to note that the libudev development library ("libudev-devel")
	could now be a part of the systemd development library ("systemd-devel")
	because of the udev + systemd merge.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.602&r2=1.603
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/WHATS_NEW_DM	2012/05/15 21:27:24	1.602
+++ LVM2/WHATS_NEW_DM	2012/05/29 08:09:10	1.603
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Remove unsupported udev_get_dev_path libudev call used for checking udev dir.
   Set delay_resume_if_new on deptree snapshot origin.
   Log value chosen in _find_config_bool like other variable types do.
   Synchronize with dead of dmeventd.
--- LVM2/lib/commands/toolcontext.c	2012/05/23 13:02:37	1.157
+++ LVM2/lib/commands/toolcontext.c	2012/05/29 08:09:10	1.158
@@ -650,9 +650,9 @@
 {
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
-	size_t uninitialized_var(udev_dir_len), len;
+	size_t len, udev_dir_len = strlen(DM_UDEV_DEV_DIR);
+	int len_diff;
 	int device_list_from_udev;
-	const char *uninitialized_var(udev_dir);
 
 	init_dev_disable_after_error_count(
 		find_config_tree_int(cmd, "devices/disable_after_error_count",
@@ -661,13 +661,9 @@
 	if (!dev_cache_init(cmd))
 		return_0;
 
-	if ((device_list_from_udev = udev_is_running() ?
+	device_list_from_udev = udev_is_running() ?
 		find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
-				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0)) {
-		if (!(udev_dir = udev_get_dev_dir()))
-			stack;
-		udev_dir_len = (udev_dir) ? strlen(udev_dir) : 0;
-	}
+				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0;
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
 	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
@@ -688,11 +684,19 @@
 			return 0;
 		}
 
-		if (device_list_from_udev && udev_dir) {
+		if (device_list_from_udev) {
 			len = strlen(cv->v.str);
-			len = udev_dir_len > len ? len : udev_dir_len;
-			if (strncmp(udev_dir, cv->v.str, len) ||
-			    udev_dir[len] != cv->v.str[len]) {
+
+			/*
+			 * DM_UDEV_DEV_DIR always has '/' at its end.
+			 * If the item in the conf does not have it, be sure
+			 * to make the right comparison without the '/' char!
+			 */
+			len_diff = len && cv->v.str[len - 1] != '/' ?
+					udev_dir_len - 1 != len :
+					udev_dir_len != len;
+
+			if (len_diff || strncmp(DM_UDEV_DEV_DIR, cv->v.str, len)) {
 				device_list_from_udev = 0;
 				init_obtain_device_list_from_udev(0);
 			}
--- LVM2/lib/misc/lvm-wrappers.c	2011/04/22 12:00:00	1.4
+++ LVM2/lib/misc/lvm-wrappers.c	2012/05/29 08:09:11	1.5
@@ -65,16 +65,6 @@
 	return 0;
 }
 
-const char *udev_get_dev_dir(void)
-{
-	if (!_udev) {
-		log_debug(_no_context_msg);
-		return NULL;
-	}
-
-	return udev_get_dev_path(_udev);
-}
-
 struct udev* udev_get_library_context(void)
 {
 	return _udev;
@@ -96,10 +86,6 @@
 	return 0;
 }
 
-const char *udev_get_dev_dir(void)
-{
-	return NULL;
-}
 #endif
 
 int lvm_getpagesize(void)
--- LVM2/lib/misc/lvm-wrappers.h	2011/04/22 12:00:00	1.5
+++ LVM2/lib/misc/lvm-wrappers.h	2012/05/29 08:09:11	1.6
@@ -24,7 +24,6 @@
 int udev_init_library_context(void);
 void udev_fin_library_context(void);
 int udev_is_running(void);
-const char *udev_get_dev_dir(void);
 
 int lvm_getpagesize(void);
 
--- LVM2/libdm/libdevmapper.h	2012/03/02 17:31:22	1.187
+++ LVM2/libdm/libdevmapper.h	2012/05/29 08:09:11	1.188
@@ -1500,6 +1500,9 @@
 
 struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
 
+/* Udev device directory. */
+#define DM_UDEV_DEV_DIR "/dev/"
+
 /* Cookie prefixes.
  *
  * The cookie value consists of a prefix (16 bits) and a base (16 bits).
--- LVM2/tools/dmsetup.c	2012/04/24 08:24:36	1.189
+++ LVM2/tools/dmsetup.c	2012/05/29 08:09:12	1.190
@@ -1008,11 +1008,9 @@
 #else	/* UDEV_SYNC_SUPPORT */
 static int _set_up_udev_support(const char *dev_dir)
 {
-	struct udev *udev;
-	const char *udev_dev_dir;
-	size_t udev_dev_dir_len;
 	int dirs_diff;
 	const char *env;
+	size_t len = strlen(dev_dir), udev_dir_len = strlen(DM_UDEV_DEV_DIR);
 
 	if (_switches[NOUDEVSYNC_ARG])
 		dm_udev_set_sync_support(0);
@@ -1030,14 +1028,6 @@
 			  " defined by --udevcookie option.",
 			  _udev_cookie);
 
-	if (!(udev = udev_new()) ||
-	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
-	    !*udev_dev_dir) {
-		log_error("Could not get udev dev path.");
-		return 0;
-	}
-	udev_dev_dir_len = strlen(udev_dev_dir);
-
 	/*
 	 * Normally, there's always a fallback action by libdevmapper if udev
 	 * has not done its job correctly, e.g. the nodes were not created.
@@ -1049,12 +1039,17 @@
 	 * is the same as "dev path" used by libdevmapper.
 	 */
 
-	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
-	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
-		dirs_diff = strncmp(dev_dir, udev_dev_dir, udev_dev_dir_len);
-	else
-		dirs_diff = strcmp(dev_dir, udev_dev_dir);
 
+	/*
+	 * DM_UDEV_DEV_DIR always has '/' at its end.
+	 * If the dev_dir does not have it, be sure
+	 * to make the right comparison without the '/' char!
+	 */
+	if (dev_dir[len - 1] != '/')
+		udev_dir_len--;
+
+	dirs_diff = udev_dir_len != len ||
+		    strncmp(DM_UDEV_DEV_DIR, dev_dir, len);
 	_udev_only = !dirs_diff && (_udev_cookie || !_switches[VERIFYUDEV_ARG]);
 
 	if (dirs_diff) {
@@ -1064,11 +1059,10 @@
 			  "about udev not working correctly while processing "
 			  "particular nodes will be suppressed. These nodes "
 			  "and symlinks will be managed in each directory "
-			  "separately.", dev_dir, udev_dev_dir);
+			  "separately.", dev_dir, DM_UDEV_DEV_DIR);
 		dm_udev_set_checking(0);
 	}
 
-	udev_unref(udev);
 	return 1;
 }
 


