From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Dec 2010 10:44:02 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM ./configure.in ...
Message-ID: <20101213104402.29361.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-12-13 10:43:58

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM configure.in 
	daemons/clvmd  : clvmd-singlenode.c clvmd.c 
	daemons/cmirrord: clogd.c 
	daemons/dmeventd: dmeventd.c 
	lib/activate   : fs.c 
	lib/locking    : file_locking.c 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add new dm_prepare_selinux_context fn to libdevmapper and use it throughout.
	Detect existence of new SELinux selabel interface during configure.
	Use new dm_prepare_selinux_context instead of dm_set_selinux_context.
	
	We should set the SELinux context before the actual file system object creation.
	The new dm_prepare_selinux_context function sets this using the selabel_lookup
	fn in conjuction with the setfscreatecon fn. If selinux/label.h interface
	(that should be a part of the selinux library) is not found during configure,
	we fallback to the original matchpathcon function instead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1835&r2=1.1836
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.430&r2=1.431
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW	2010/12/10 22:39:52	1.1835
+++ LVM2/WHATS_NEW	2010/12/13 10:43:56	1.1836
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Use new dm_prepare_selinux_context instead of dm_set_selinux_context.
   Avoid revalidating the label cache immediately after scanning.
   Support scanning for a single VG in independent mdas.
   Don't skip full scan when independent mdas are present even if memlock is set.
--- LVM2/WHATS_NEW_DM	2010/12/06 22:13:10	1.430
+++ LVM2/WHATS_NEW_DM	2010/12/13 10:43:56	1.431
@@ -1,5 +1,7 @@
 Version 1.02.60 -
 ===================================
+  Add new dm_prepare_selinux_context fn to libdevmapper and use it throughout.
+  Detect existence of new SELinux selabel interface during configure.
 
 Version 1.02.59 - 6th December 2010
 ===================================
--- LVM2/configure.in	2010/11/05 16:18:38	1.157
+++ LVM2/configure.in	2010/12/13 10:43:56	1.158
@@ -971,6 +971,7 @@
 
 	AC_CHECK_LIB([selinux], [is_selinux_enabled], [
 		AC_CHECK_HEADERS([selinux/selinux.h],, hard_bailout)
+		AC_CHECK_HEADERS([selinux/label.h])
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
 		SELINUX_PC="libselinux"
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/19 23:26:31	1.8
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/12/13 10:43:56	1.9
@@ -43,6 +43,8 @@
 	mode_t old_mask;
 
 	close_comms();
+
+	(void) dm_prepare_selinux_context(SINGLENODE_CLVMD_SOCKNAME, S_IFSOCK);
 	old_mask = umask(0077);
 
 	listen_fd = socket(PF_UNIX, SOCK_STREAM, 0);
@@ -68,9 +70,11 @@
 	}
 
 	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 	return 0;
 error:
 	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 	close_comms();
 	return -1;
 }
--- LVM2/daemons/clvmd/clvmd.c	2010/12/01 12:41:49	1.86
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/13 10:43:56	1.87
@@ -414,10 +414,12 @@
 	}
 
 	/* Create pidfile */
+	(void) dm_prepare_selinux_context(CLVMD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(CLVMD_PIDFILE) == 0) {
 		DEBUGLOG("clvmd: unable to create lockfile\n");
 		exit(1);
 	}
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	atexit(remove_lockfile);
 
@@ -2020,6 +2022,8 @@
 	mode_t old_mask;
 
 	close_local_sock(local_socket);
+
+	(void) dm_prepare_selinux_context(CLVMD_SOCKNAME, S_IFSOCK);
 	old_mask = umask(0077);
 
 	/* Open local socket */
@@ -2037,6 +2041,7 @@
 	memset(&sockaddr, 0, sizeof(sockaddr));
 	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
 	sockaddr.sun_family = AF_UNIX;
+
 	if (bind(local_socket, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
 		log_error("can't bind local socket: %m");
 		goto error;
@@ -2047,10 +2052,12 @@
 	}
 
 	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 	return local_socket;
 error:
 	close_local_sock(local_socket);
 	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 	return -1;
 }
 
--- LVM2/daemons/cmirrord/clogd.c	2010/07/13 13:51:02	1.12
+++ LVM2/daemons/cmirrord/clogd.c	2010/12/13 10:43:57	1.13
@@ -188,8 +188,10 @@
 
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
 
+	(void) dm_prepare_selinux_context(CMIRRORD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(CMIRRORD_PIDFILE) == 0)
 		exit(EXIT_LOCKFILE);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	atexit(remove_lockfile);
 
--- LVM2/daemons/dmeventd/dmeventd.c	2010/11/29 12:15:41	1.71
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/12/13 10:43:57	1.72
@@ -1241,14 +1241,30 @@
 /* Open fifos used for client communication. */
 static int _open_fifos(struct dm_event_fifos *fifos)
 {
-	/* Create fifos */
-	if (((mkfifo(fifos->client_path, 0600) == -1) && errno != EEXIST) ||
-	    ((mkfifo(fifos->server_path, 0600) == -1) && errno != EEXIST)) {
-		syslog(LOG_ERR, "%s: Failed to create a fifo.\n", __func__);
+	int orig_errno;
+
+	/* Create client fifo. */
+	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
+	if ((mkfifo(fifos->client_path, 0600) == -1) && errno != EEXIST) {
+		syslog(LOG_ERR, "%s: Failed to create client fifo.\n", __func__);
+		orig_errno = errno;
+		(void) dm_prepare_selinux_context(NULL, 0);
 		stack;
-		return -errno;
+		return -orig_errno;
+	}
+
+	/* Create server fifo. */
+	(void) dm_prepare_selinux_context(fifos->server_path, S_IFIFO);
+	if ((mkfifo(fifos->server_path, 0600) == -1) && errno != EEXIST) {
+		syslog(LOG_ERR, "%s: Failed to create server fifo.\n", __func__);
+		orig_errno = errno;
+		(void) dm_prepare_selinux_context(NULL, 0);
+		stack;
+		return -orig_errno;
 	}
 
+	(void) dm_prepare_selinux_context(NULL, 0);
+
 	struct stat st;
 
 	/* Warn about wrong permissions if applicable */
@@ -1806,10 +1822,12 @@
 
 	openlog("dmeventd", LOG_PID, LOG_DAEMON);
 
+	(void) dm_prepare_selinux_context(DMEVENTD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
 		exit(EXIT_FAILURE);
 
 	atexit(remove_lockfile);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	/* Set the rest of the signals to cause '_exit_now' to be set */
 	signal(SIGINT, &_exit_handler);
--- LVM2/lib/activate/fs.c	2010/11/23 15:28:54	1.52
+++ LVM2/lib/activate/fs.c	2010/12/13 10:43:57	1.53
@@ -43,13 +43,16 @@
 
 	log_very_verbose("Creating directory %s", vg_path);
 
+	(void) dm_prepare_selinux_context(vg_path, S_IFDIR);
 	old_umask = umask(DM_DEV_DIR_UMASK);
 	if (mkdir(vg_path, 0777)) {
 		log_sys_error("mkdir", vg_path);
 		umask(old_umask);
+		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
 	}
 	umask(old_umask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	return 1;
 }
@@ -199,13 +202,14 @@
 			  "direct link creation.", lv_path);
 
 	log_very_verbose("Linking %s -> %s", lv_path, link_path);
+
+	(void) dm_prepare_selinux_context(lv_path, S_IFLNK);
 	if (symlink(link_path, lv_path) < 0) {
 		log_sys_error("symlink", lv_path);
+		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
 	}
-
-	if (!dm_set_selinux_context(lv_path, S_IFLNK))
-		return_0;
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	return 1;
 }
--- LVM2/lib/locking/file_locking.c	2010/08/17 19:25:05	1.50
+++ LVM2/lib/locking/file_locking.c	2010/12/13 10:43:57	1.51
@@ -234,10 +234,12 @@
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 nonblock ? ' ' : 'B');
 
+	(void) dm_prepare_selinux_context(file, S_IFREG);
 	if (_prioritise_write_locks)
 		r = _do_write_priority_flock(file, &ll->lf, operation, nonblock);
 	else 
 		r = _do_flock(file, &ll->lf, operation, nonblock);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);
@@ -325,6 +327,7 @@
 	locking->reset_locking = _reset_file_locking;
 	locking->fin_locking = _fin_file_locking;
 	locking->flags = 0;
+	int r;
 
 	/* Get lockfile directory from config file */
 	strncpy(_lock_dir, find_config_tree_str(cmd, "global/locking_dir",
@@ -335,7 +338,11 @@
 	    find_config_tree_bool(cmd, "global/prioritise_write_locks",
 				  DEFAULT_PRIORITISE_WRITE_LOCKS);
 
-	if (!dm_create_dir(_lock_dir))
+	(void) dm_prepare_selinux_context(_lock_dir, S_IFDIR);
+	r = dm_create_dir(_lock_dir);
+	(void) dm_prepare_selinux_context(NULL, 0);
+
+	if (!r)
 		return 0;
 
 	/* Trap a read-only file system */
--- LVM2/libdm/libdevmapper.h	2010/10/25 13:13:53	1.128
+++ LVM2/libdm/libdevmapper.h	2010/12/13 10:43:58	1.129
@@ -923,6 +923,17 @@
 /*********
  * selinux
  *********/
+
+/*
+ * Obtain SELinux security context assigned for the path and set this
+ * context for creating a new file system object. This security context
+ * is global and it is used until reset to default policy behaviour
+ * by calling 'dm_prepare_selinux_context(NULL, 0)'.
+ */
+int dm_prepare_selinux_context(const char *path, mode_t mode);
+/*
+ * Set SELinux context for existing file system object.
+ */
 int dm_set_selinux_context(const char *path, mode_t mode);
 
 /*********************
--- LVM2/libdm/libdm-common.c	2010/11/29 10:11:50	1.102
+++ LVM2/libdm/libdm-common.c	2010/12/13 10:43:58	1.103
@@ -40,6 +40,9 @@
 #ifdef HAVE_SELINUX
 #  include <selinux/selinux.h>
 #endif
+#ifdef HAVE_SELINUX_LABEL_H
+#  include <selinux/label.h>
+#endif
 
 #define DEV_DIR "/dev/"
 
@@ -59,6 +62,10 @@
 
 static int _verbose = 0;
 
+#ifdef HAVE_SELINUX_LABEL_H
+static struct selabel_handle *_selabel_handle = NULL;
+#endif
+
 #ifdef UDEV_SYNC_SUPPORT
 static int _semaphore_supported = -1;
 static int _udev_running = -1;
@@ -380,20 +387,68 @@
 	return 1;
 }
 
-int dm_set_selinux_context(const char *path, mode_t mode)
+static int _selabel_lookup(const char *path, mode_t mode,
+			   security_context_t *scontext)
+{
+#ifdef HAVE_SELINUX_LABEL_H
+	if (!_selabel_handle &&
+	    !(_selabel_handle = selabel_open(SELABEL_CTX_FILE, NULL, 0))) {
+		log_error("selabel_open failed: %s", strerror(errno));
+		return 0;
+	}
+
+	if (selabel_lookup(_selabel_handle, scontext, path, mode)) {
+		log_error("selabel_lookup failed: %s", strerror(errno));
+		return 0;
+	}
+#else
+	if (matchpathcon(path, mode, scontext)) {
+		log_error("matchpathcon failed: %s", strerror(errno));
+		return 0;
+	}
+#endif
+	return 1;
+}
+
+int dm_prepare_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext;
+	security_context_t scontext = NULL;
 
 	if (is_selinux_enabled() <= 0)
 		return 1;
 
-	if (matchpathcon(path, mode, &scontext) < 0) {
-		log_error("%s: matchpathcon %07o failed: %s", path, mode,
-			  strerror(errno));
+	if (path) {
+		if (!_selabel_lookup(path, mode, &scontext))
+			return_0;
+
+		log_debug("Preparing SELinux context for %s to %s.", path, scontext);
+	}
+	else
+		log_debug("Resetting SELinux context to default value.");
+
+	if (setfscreatecon(scontext) < 0) {
+		log_sys_error("setfscreatecon", path);
+		freecon(scontext);
 		return 0;
 	}
 
+	freecon(scontext);
+#endif
+	return 1;
+}
+
+int dm_set_selinux_context(const char *path, mode_t mode)
+{
+#ifdef HAVE_SELINUX
+	security_context_t scontext;
+
+	if (is_selinux_enabled() <= 0)
+		return 1;
+
+	if (!_selabel_lookup(path, mode, &scontext))
+		return_0;
+
 	log_debug("Setting SELinux context for %s to %s.", path, scontext);
 
 	if ((lsetfilecon(path, scontext) < 0) && (errno != ENOTSUP)) {
@@ -407,6 +462,15 @@
 	return 1;
 }
 
+void selinux_release(void)
+{
+#ifdef HAVE_SELINUX_LABEL_H
+	if (_selabel_handle)
+		selabel_close(_selabel_handle);
+	_selabel_handle = NULL;
+#endif
+}
+
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			 uid_t uid, gid_t gid, mode_t mode, int check_udev)
 {
@@ -438,13 +502,16 @@
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
+	(void) dm_prepare_selinux_context(path, S_IFBLK);
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
-		umask(old_mask);
 		log_error("Unable to make device node for '%s'", dev_name);
+		umask(old_mask);
+		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
 	}
 	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (chown(path, uid, gid) < 0) {
 		log_sys_error("chown", path);
@@ -453,9 +520,6 @@
 
 	log_debug("Created %s", path);
 
-	if (!dm_set_selinux_context(path, S_IFBLK))
-		return 0;
-
 	return 1;
 }
 
--- LVM2/libdm/libdm-common.h	2009/10/26 14:29:34	1.6
+++ LVM2/libdm/libdm-common.h	2010/12/13 10:43:58	1.7
@@ -31,5 +31,6 @@
 int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
 			    uint32_t read_ahead_flags);
 void update_devs(void);
+void selinux_release(void);
 
 #endif
--- LVM2/libdm/ioctl/libdm-iface.c	2010/11/30 22:40:20	1.85
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/12/13 10:43:58	1.86
@@ -270,27 +270,25 @@
 	if (!major)
 		return 0;
 
+	(void) dm_prepare_selinux_context(dm_dir(), S_IFDIR);
 	old_umask = umask(DM_DEV_DIR_UMASK);
 	ret = dm_create_dir(dm_dir());
 	umask(old_umask);
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (!ret)
 		return 0;
 
 	log_verbose("Creating device %s (%u, %u)", control, major, minor);
 
+	(void) dm_prepare_selinux_context(control, S_IFCHR);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
 		  MKDEV(major, minor)) < 0)  {
 		log_sys_error("mknod", control);
+		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
 	}
-
-#ifdef HAVE_SELINUX
-	if (!dm_set_selinux_context(control, S_IFCHR)) {
-		stack;
-		return 0;
-	}
-#endif
+	(void) dm_prepare_selinux_context(NULL, 0);
 
 	return 1;
 }
@@ -2132,6 +2130,7 @@
 void dm_lib_exit(void)
 {
 	dm_lib_release();
+	selinux_release();
 	if (_dm_bitset)
 		dm_bitset_destroy(_dm_bitset);
 	_dm_bitset = NULL;


