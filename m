From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Nov 2011 15:14:07 -0000
Subject: LVM2/lib/activate activate.c activate.h
Message-ID: <20111111151407.10428.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-11-11 15:14:05

Modified files:
	lib/activate   : activate.c activate.h 

Log message:
	Fix function name in previous patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/lib/activate/activate.c	2011/11/11 15:11:10	1.221
+++ LVM2/lib/activate/activate.c	2011/11/11 15:14:05	1.222
@@ -147,7 +147,7 @@
 {
 	return 0;
 }
-int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
 {
 	return 0;
 }
@@ -443,14 +443,14 @@
 	return r;
 }
 
-int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
 {
 	struct dm_task *dmt;
 	const char *uuid;
 	int r;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
-		return 0;
+		return_0;
 
 	if (!dm_task_set_minor(dmt, minor) ||
 	    !dm_task_set_major(dmt, major) ||
@@ -463,7 +463,7 @@
 	r = strncasecmp(uuid, prefix, strlen(prefix));
 	dm_task_destroy(dmt);
 
-	return (r == 0) ? 1 : 0;
+	return r ? 0 : 1;
 }
 
 int module_present(struct cmd_context *cmd, const char *target_name)
--- LVM2/lib/activate/activate.h	2011/11/11 15:11:10	1.86
+++ LVM2/lib/activate/activate.h	2011/11/11 15:14:05	1.87
@@ -53,7 +53,7 @@
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
-int dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix);
+int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules);
 int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,


