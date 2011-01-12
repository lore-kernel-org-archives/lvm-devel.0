From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2011 20:42:58 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
Message-ID: <20110112204258.16799.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-12 20:42:51

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvm.h clvmd-command.c lvm-functions.c 
	lib/activate   : fs.c 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	                 locking.h no_locking.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	lib/misc       : lvm-exec.c 
	libdm          : libdm-common.c 
	tools          : polldaemon.c 

Log message:
	Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
	Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1877&r2=1.1878
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.419&r2=1.420
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2011/01/12 15:28:33	1.1877
+++ LVM2/WHATS_NEW	2011/01/12 20:42:50	1.1878
@@ -1,5 +1,7 @@
 Version 2.02.81 -
 ===================================
+  Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
+  Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.
   Accept fusion fio in device type filter.
   Add disk to mirrored log type conversion.
 
--- LVM2/daemons/clvmd/clvm.h	2010/07/28 13:55:43	1.9
+++ LVM2/daemons/clvmd/clvm.h	2011/01/12 20:42:50	1.10
@@ -71,4 +71,5 @@
 #define CLVMD_CMD_SET_DEBUG	    42
 #define CLVMD_CMD_VG_BACKUP	    43
 #define CLVMD_CMD_RESTART	    44
+#define CLVMD_CMD_SYNC_NAMES	    45
 #endif
--- LVM2/daemons/clvmd/clvmd-command.c	2011/01/10 14:02:30	1.46
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/01/12 20:42:50	1.47
@@ -139,6 +139,10 @@
 		do_refresh_cache();
 		break;
 
+	case CLVMD_CMD_SYNC_NAMES:
+		lvm_do_fs_unlock();
+		break;
+
 	case CLVMD_CMD_SET_DEBUG:
 		debug = args[0];
 		break;
@@ -275,6 +279,7 @@
 	case CLVMD_CMD_GET_CLUSTERNAME:
 	case CLVMD_CMD_SET_DEBUG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_SYNC_NAMES:
 	case CLVMD_CMD_LOCK_QUERY:
 	case CLVMD_CMD_RESTART:
 		break;
@@ -307,6 +312,7 @@
 
 	case CLVMD_CMD_LOCK_VG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_SYNC_NAMES:
 	case CLVMD_CMD_LOCK_QUERY:
 		/* Nothing to do here */
 		break;
--- LVM2/daemons/clvmd/lvm-functions.c	2011/01/10 14:02:30	1.105
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/01/12 20:42:50	1.106
@@ -897,6 +897,7 @@
 void lvm_do_fs_unlock(void)
 {
 	pthread_mutex_lock(&lvm_lock);
+	DEBUGLOG("Syncing device names\n");
 	fs_unlock();
 	pthread_mutex_unlock(&lvm_lock);
 }
--- LVM2/lib/activate/fs.c	2011/01/10 14:02:31	1.55
+++ LVM2/lib/activate/fs.c	2011/01/12 20:42:50	1.56
@@ -403,6 +403,7 @@
 void fs_unlock(void)
 {
 	if (!memlock()) {
+		log_debug("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
 			stack;
--- LVM2/lib/locking/cluster_locking.c	2011/01/05 15:10:30	1.48
+++ LVM2/lib/locking/cluster_locking.c	2011/01/12 20:42:50	1.49
@@ -345,14 +345,15 @@
 	 * locks are cluster-wide.
 	 * Also, if the lock is exclusive it makes no sense to try to
 	 * acquire it on all nodes, so just do that on the local node too.
-	 * One exception, is that P_ locks /do/ get distributed across
-	 * the cluster because they might have side-effects.
+	 * One exception, is that P_ locks (except VG_SYNC_NAMES) /do/ get 
+	 * distributed across the cluster because they might have side-effects.
 	 */
-	if (strncmp(name, "P_", 2) &&
-	    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
-	     (flags & LCK_TYPE_MASK) == LCK_EXCL ||
-	     (flags & LCK_LOCAL) ||
-	     !(flags & LCK_CLUSTER_VG)))
+	if ((strncmp(name, "P_", 2) &&
+	     (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
+	      (flags & LCK_TYPE_MASK) == LCK_EXCL ||
+	      (flags & LCK_LOCAL) ||
+	      !(flags & LCK_CLUSTER_VG))) ||
+	    (clvmd_cmd == CLVMD_CMD_SYNC_NAMES && (flags & LCK_LOCAL)))
 		node = ".";
 
 	status = _cluster_request(clvmd_cmd, node, args, len,
@@ -401,6 +402,11 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		if (!strcmp(resource, VG_SYNC_NAMES)) {
+			log_very_verbose("Requesting sync names.");
+			return _lock_for_cluster(cmd, CLVMD_CMD_SYNC_NAMES,
+						 flags & ~LCK_HOLD, resource);
+		}
 		if (flags == LCK_VG_BACKUP) {
 			log_very_verbose("Requesting backup of VG metadata for %s",
 					 resource);
--- LVM2/lib/locking/file_locking.c	2011/01/10 14:02:31	1.53
+++ LVM2/lib/locking/file_locking.c	2011/01/12 20:42:50	1.54
@@ -265,6 +265,9 @@
 		if (strcmp(resource, VG_GLOBAL))
 			lvmcache_drop_metadata(resource, 0);
 
+		if (!strcmp(resource, VG_SYNC_NAMES))
+			fs_unlock();
+
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)
 			break;
--- LVM2/lib/locking/locking.c	2010/10/25 11:20:55	1.87
+++ LVM2/lib/locking/locking.c	2011/01/12 20:42:50	1.88
@@ -325,7 +325,7 @@
 	char path[PATH_MAX];
 
 	/* We'll allow operations on orphans */
-	if (is_orphan_vg(vgname) || is_global_vg(vgname))
+	if (!is_real_vg(vgname))
 		return 1;
 
 	/* LVM1 is only present in 2.4 kernels. */
--- LVM2/lib/locking/locking.h	2010/12/08 20:50:50	1.59
+++ LVM2/lib/locking/locking.h	2011/01/12 20:42:51	1.60
@@ -109,6 +109,7 @@
  */
 #define VG_ORPHANS	"#orphans"
 #define VG_GLOBAL	"#global"
+#define VG_SYNC_NAMES	"#sync_names"
 
 /*
  * Common combinations
@@ -169,6 +170,8 @@
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
+#define sync_local_dev_names(cmd)	\
+	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
--- LVM2/lib/locking/no_locking.c	2010/08/17 19:25:05	1.24
+++ LVM2/lib/locking/no_locking.c	2011/01/12 20:42:51	1.25
@@ -38,6 +38,8 @@
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		if (!strcmp(resource, VG_SYNC_NAMES))
+			fs_unlock();
 		break;
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
--- LVM2/lib/metadata/lv_manip.c	2011/01/11 17:05:09	1.243
+++ LVM2/lib/metadata/lv_manip.c	2011/01/12 20:42:51	1.244
@@ -3021,7 +3021,7 @@
 		return 0;
 	}
 
-	fs_unlock();  /* Wait until devices are available */
+	sync_local_dev_names(cmd);  /* Wait until devices are available */
 
 	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
 
--- LVM2/lib/metadata/metadata-exported.h	2010/12/08 20:50:50	1.173
+++ LVM2/lib/metadata/metadata-exported.h	2011/01/12 20:42:51	1.174
@@ -362,6 +362,7 @@
 			const char *lv_name);
 int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
+int is_real_vg(const char *vg_name);
 int vg_missing_pv_count(const struct volume_group *vg);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
--- LVM2/lib/metadata/metadata.c	2010/12/22 15:36:41	1.419
+++ LVM2/lib/metadata/metadata.c	2011/01/12 20:42:51	1.420
@@ -3561,6 +3561,14 @@
 }
 
 /*
+ * Exclude pseudo VG names used for locking.
+ */
+int is_real_vg(const char *vg_name)
+{
+	return (vg_name && *vg_name != '#');
+}
+
+/*
  * Returns:
  *  0 - fail
  *  1 - success
--- LVM2/lib/misc/lvm-exec.c	2011/01/10 19:49:42	1.10
+++ LVM2/lib/misc/lvm-exec.c	2011/01/12 20:42:51	1.11
@@ -55,7 +55,7 @@
 
 	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
-	fs_unlock(); /* Flush oops and ensure cookie is not shared */
+	sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
--- LVM2/libdm/libdm-common.c	2010/12/13 12:44:09	1.106
+++ LVM2/libdm/libdm-common.c	2011/01/12 20:42:51	1.107
@@ -507,7 +507,7 @@
 	(void) dm_prepare_selinux_context(path, S_IFBLK);
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
-		log_error("Unable to make device node for '%s'", dev_name);
+		log_error("%s: mknod for %s failed: %s", path, dev_name, strerror(errno));
 		umask(old_mask);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
--- LVM2/tools/polldaemon.c	2011/01/10 19:31:02	1.41
+++ LVM2/tools/polldaemon.c	2011/01/12 20:42:51	1.42
@@ -42,7 +42,7 @@
 
 	sigaction(SIGCHLD, &act, NULL);
 
-	fs_unlock(); /* Flush oops and ensure cookie is not shared */
+	sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));


