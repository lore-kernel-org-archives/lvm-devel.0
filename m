From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:17:08 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110922171708.26829.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:17:07

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c 

Log message:
	Add dm_set_sysfs_dir to libdevmapper to set sysfs location.
	Add dm_sysfs_dir to libdevmapper to retrieve sysfs location thas is set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.501&r2=1.502
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW_DM	2011/09/22 17:12:28	1.501
+++ LVM2/WHATS_NEW_DM	2011/09/22 17:17:07	1.502
@@ -1,5 +1,7 @@
 Version 1.02.68 -
 ==================================
+  Add dm_sysfs_dir to libdevmapper to retrieve sysfs location thas is set.
+  Add dm_set_sysfs_dir to libdevmapper to set sysfs location.
   Add --retry option for dmsetup remove to retry removal if not successful.
   Add dm_task_retry_remove fn to use retry logic for device removal.
   Remove unused passed parameters for _mirror_emit_segment_line().
--- LVM2/libdm/libdevmapper.h	2011/09/22 17:09:48	1.150
+++ LVM2/libdm/libdevmapper.h	2011/09/22 17:17:07	1.151
@@ -256,6 +256,12 @@
 const char *dm_dir(void);
 
 /*
+ * Configure sysfs directory, /sys by default
+ */
+int dm_set_sysfs_dir(const char *dir);
+const char *dm_sysfs_dir(void);
+
+/*
  * Determine whether a major number belongs to device-mapper or not.
  */
 int dm_is_dm_major(uint32_t major);
--- LVM2/libdm/libdm-common.c	2011/07/08 15:34:47	1.124
+++ LVM2/libdm/libdm-common.c	2011/09/22 17:17:07	1.125
@@ -58,6 +58,7 @@
 #endif
 
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
+static char _sysfs_dir[PATH_MAX] = "/sys/";
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
@@ -1008,32 +1009,53 @@
 	_pop_node_ops();
 }
 
-int dm_set_dev_dir(const char *dev_dir)
+static int _canonicalize_and_set_dir(const char *src, const char *suffix, size_t max_len, char *dir)
 {
 	size_t len;
 	const char *slash;
-	if (*dev_dir != '/') {
-		log_debug("Invalid dev_dir value, %s: "
-			  "not an absolute name.", dev_dir);
+
+	if (*src != '/') {
+		log_debug("Invalid directory value, %s: "
+			  "not an absolute name.", src);
 		return 0;
 	}
 
-	len = strlen(dev_dir);
-	slash = dev_dir[len-1] == '/' ? "" : "/";
+	len = strlen(src);
+	slash = src[len-1] == '/' ? "" : "/";
 
-	if (dm_snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR) < 0) {
-		log_debug("Invalid dev_dir value, %s: name too long.", dev_dir);
+	if (dm_snprintf(dir, max_len, "%s%s%s", src, slash, suffix ? suffix : "") < 0) {
+		log_debug("Invalid directory value, %s: name too long.", src);
 		return 0;
 	}
 
 	return 1;
 }
 
+int dm_set_dev_dir(const char *dev_dir)
+{
+	return _canonicalize_and_set_dir(dev_dir, DM_DIR, sizeof _dm_dir, _dm_dir);
+}
+
 const char *dm_dir(void)
 {
 	return _dm_dir;
 }
 
+int dm_set_sysfs_dir(const char *sysfs_dir)
+{
+	if (!sysfs_dir || !*sysfs_dir) {
+		_sysfs_dir[0] = '\0';
+		return 1;
+	}
+	else
+		return _canonicalize_and_set_dir(sysfs_dir, NULL, sizeof _sysfs_dir, _sysfs_dir);
+}
+
+const char *dm_sysfs_dir(void)
+{
+	return _sysfs_dir;
+}
+
 int dm_mknodes(const char *name)
 {
 	struct dm_task *dmt;


