From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:05:06 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/device/dev ...
Message-ID: <20120208110506.27870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:05:05

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/device     : dev-cache.c 
	lib/locking    : locking.c 
	lib/log        : log.c 
	lib/misc       : lvm-globals.c sharedlib.c 
	libdm          : libdm-common.c 
	tools          : dmsetup.c 

Log message:
	Ensure strncpy() function always ends with '\0'
	
	Since last character needs to be \0 for string,
	pass buffer size smaller by 1 byte.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2262&r2=1.2263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.538&r2=1.539
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/sharedlib.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174

--- LVM2/WHATS_NEW	2012/02/08 10:56:17	1.2262
+++ LVM2/WHATS_NEW	2012/02/08 11:05:04	1.2263
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Ensure strncpy() function always ends with '\0'.
   Set status in _fsadm_cmd() for error path.
   Add missing deps for lvm2api for rebuild when lvm-internal is changed.
   Fix resource leaks for failing allocation of formats (lvm1/2,pool).
--- LVM2/WHATS_NEW_DM	2012/02/01 18:46:57	1.538
+++ LVM2/WHATS_NEW_DM	2012/02/08 11:05:04	1.539
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Leave space for '\0' for readline() call in _sysfs_get_kernel_name().
 
 Version 1.02.69 - 1st February 2012
 ===================================
--- LVM2/lib/device/dev-cache.c	2012/01/20 11:01:56	1.70
+++ LVM2/lib/device/dev-cache.c	2012/02/08 11:05:04	1.71
@@ -254,8 +254,10 @@
 	if (slash1 < slash0)
 		return 1;
 
-	strncpy(p0, path0, PATH_MAX);
-	strncpy(p1, path1, PATH_MAX);
+	strncpy(p0, path0, sizeof(p0) - 1);
+	p0[sizeof(p0) - 1] = '\0';
+	strncpy(p1, path1, sizeof(p1) - 1);
+	p1[sizeof(p1) - 1] = '\0';
 	s0 = p0 + 1;
 	s1 = p1 + 1;
 
--- LVM2/lib/locking/locking.c	2012/01/21 05:29:52	1.102
+++ LVM2/lib/locking/locking.c	2012/02/08 11:05:04	1.103
@@ -459,7 +459,8 @@
 		return 0;
 	}
 
-	strncpy(resource, vol, sizeof(resource));
+	strncpy(resource, vol, sizeof(resource) - 1);
+	resource[sizeof(resource) - 1] = '\0';
 
 	if (!_lock_vol(cmd, resource, flags, lv_op))
 		return_0;
--- LVM2/lib/log/log.c	2011/10/22 16:52:00	1.66
+++ LVM2/lib/log/log.c	2012/02/08 11:05:04	1.67
@@ -136,7 +136,7 @@
 
 void init_msg_prefix(const char *prefix)
 {
-	strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
+	strncpy(_msg_prefix, prefix, sizeof(_msg_prefix) - 1);
 	_msg_prefix[sizeof(_msg_prefix) - 1] = '\0';
 }
 
--- LVM2/lib/misc/lvm-globals.c	2011/09/22 17:39:57	1.15
+++ LVM2/lib/misc/lvm-globals.c	2012/02/08 11:05:04	1.16
@@ -165,13 +165,13 @@
 
 void set_cmd_name(const char *cmd)
 {
-	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
+	strncpy(_cmd_name, cmd, sizeof(_cmd_name) - 1);
 	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
 }
 
 void set_sysfs_dir_path(const char *path)
 {
-	strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path));
+	strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path) - 1);
 	_sysfs_dir_path[sizeof(_sysfs_dir_path) - 1] = '\0';
 }
 
--- LVM2/lib/misc/sharedlib.c	2008/12/18 05:27:18	1.16
+++ LVM2/lib/misc/sharedlib.c	2012/02/08 11:05:04	1.17
@@ -34,8 +34,10 @@
 	if (libname[0] == '/' ||
 	    !(lib_dir = find_config_tree_str(cmd, "global/library_dir", 0)) ||
 	    (dm_snprintf(path, path_len, "%s/%s", lib_dir,
-			  libname) == -1) || stat(path, &info) == -1)
-		strncpy(path, libname, path_len);
+			 libname) == -1) || stat(path, &info) == -1) {
+		strncpy(path, libname, path_len - 1);
+		path[path_len - 1] = '\0';
+	}
 }
 
 void *load_shared_library(struct cmd_context *cmd, const char *libname,
--- LVM2/libdm/libdm-common.c	2012/01/25 21:47:18	1.134
+++ LVM2/libdm/libdm-common.c	2012/02/08 11:05:05	1.135
@@ -706,7 +706,7 @@
 
 		if ((fd = open(_path0, O_RDONLY, 0)) != -1) {
 			/* Reading from sysfs, expecting number\n */
-			if ((len = read(fd, buf, sizeof(buf))) < 1) {
+			if ((len = read(fd, buf, sizeof(buf) - 1)) < 1) {
 				log_sys_error("read", _path0);
 				r = 0;
 			} else {
@@ -1256,7 +1256,7 @@
 		goto error;
 	}
 
-	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX)) < 0) {
+	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX - 1)) < 0) {
 		if (errno != ENOENT)
 			log_sys_error("readlink", sysfs_path);
 		else
--- LVM2/tools/dmsetup.c	2012/01/20 10:58:17	1.173
+++ LVM2/tools/dmsetup.c	2012/02/08 11:05:05	1.174
@@ -3059,7 +3059,8 @@
 		    device[strlen(dev_dir)] != '/')
 			goto error;
 
-		strncpy(buf, strrchr(device, '/') + 1, (size_t) PATH_MAX);
+		strncpy(buf, strrchr(device, '/') + 1, PATH_MAX - 1);
+		buf[PATH_MAX - 1] = '\0';
 		dm_free(device);
 
 	} else {


