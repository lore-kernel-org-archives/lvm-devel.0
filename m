From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 03:42:37 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-sysfs.c li ...
Message-ID: <20080919034237.31938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 03:42:37

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-sysfs.c filter-sysfs.h 
	lib/commands   : toolcontext.c toolcontext.h 

Log message:
	Store sysfs location in struct cmd_context.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.955&r2=1.956
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2008/09/18 19:56:50	1.955
+++ LVM2/WHATS_NEW	2008/09/19 03:42:36	1.956
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Store sysfs location in struct cmd_context.
   Avoid shuffling remaining mirror images when removing one, retaining primary.
   Add missing LV error target activation in _remove_mirror_images.
   Prevent resizing an LV while lvconvert is using it.
--- LVM2/lib/filters/filter-sysfs.c	2008/01/30 13:59:58	1.19
+++ LVM2/lib/filters/filter-sysfs.c	2008/09/19 03:42:37	1.20
@@ -20,47 +20,11 @@
 
 #include <dirent.h>
 
-static int _locate_sysfs_blocks(const char *proc, char *path, size_t len,
+static int _locate_sysfs_blocks(const char *sysfs_dir, char *path, size_t len,
 				unsigned *sysfs_depth)
 {
-	char proc_mounts[PATH_MAX];
-	FILE *fp;
-	char *split[4], buffer[PATH_MAX + 16];
-	const char *sys_mnt = NULL;
 	struct stat info;
 
-	if (!*proc) {
-		log_verbose("No proc filesystem found: skipping sysfs filter");
-		return 0;
-	}
-		
-	if (dm_snprintf(proc_mounts, sizeof(proc_mounts),
-			 "%s/mounts", proc) < 0) {
-		log_error("Failed to create /proc/mounts string");
-		return 0;
-	}
-
-	if (!(fp = fopen(proc_mounts, "r"))) {
-		log_sys_error("fopen %s", proc_mounts);
-		return 0;
-	}
-
-	while (fgets(buffer, sizeof(buffer), fp)) {
-		if (dm_split_words(buffer, 4, 0, split) == 4 &&
-		    !strcmp(split[2], "sysfs")) {
-			sys_mnt = split[1];
-			break;
-		}
-	}
-
-	if (fclose(fp))
-		log_sys_error("fclose", proc_mounts);
-
-	if (!sys_mnt) {
-		log_error("Failed to find sysfs mount point");
-		return 0;
-	}
-
 	/*
 	 * unified classification directory for all kernel subsystems
 	 *
@@ -70,7 +34,7 @@
 	 *  `-- sr0 -> ../../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
 	 *
 	 */
-	if (dm_snprintf(path, len, "%s/%s", sys_mnt,
+	if (dm_snprintf(path, len, "%s/%s", sysfs_dir,
 			"subsystem/block/devices") >= 0) {
 		if (!stat(path, &info)) {
 			*sysfs_depth = 0;
@@ -87,7 +51,7 @@
 	 *  `-- sr0 -> ../../devices/pci0000:00/0000:00:1f.2/host1/target1:0:0/1:0:0:0/block/sr0
 	 *
 	 */
-	if (dm_snprintf(path, len, "%s/%s", sys_mnt, "class/block") >= 0) {
+	if (dm_snprintf(path, len, "%s/%s", sysfs_dir, "class/block") >= 0) {
 		if (!stat(path, &info)) {
 			*sysfs_depth = 0;
 			return 1;
@@ -112,7 +76,7 @@
 	 * ...
 	 *
 	 */
-	if (dm_snprintf(path, len, "%s/%s", sys_mnt, "block") >= 0) {
+	if (dm_snprintf(path, len, "%s/%s", sysfs_dir, "block") >= 0) {
 		if (!stat(path, &info)) {
 			*sysfs_depth = 1;
 			return 1;
@@ -321,7 +285,7 @@
 	dm_pool_destroy(ds->mem);
 }
 
-struct dev_filter *sysfs_filter_create(const char *proc)
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
 {
 	char sys_block[PATH_MAX];
 	unsigned sysfs_depth;
@@ -329,7 +293,12 @@
 	struct dev_set *ds;
 	struct dev_filter *f;
 
-	if (!_locate_sysfs_blocks(proc, sys_block, sizeof(sys_block), &sysfs_depth))
+	if (!*sysfs_dir) {
+		log_verbose("No proc filesystem found: skipping sysfs filter");
+		return NULL;
+	}
+
+	if (!_locate_sysfs_blocks(sysfs_dir, sys_block, sizeof(sys_block), &sysfs_depth))
 		return NULL;
 
 	if (!(mem = dm_pool_create("sysfs", 256))) {
@@ -357,7 +326,7 @@
 
 #else
 
-struct dev_filter *sysfs_filter_create(const char *proc __attribute((unused)))
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir __attribute((unused)))
 {
 	return NULL;
 }
--- LVM2/lib/filters/filter-sysfs.h	2007/08/20 20:55:25	1.3
+++ LVM2/lib/filters/filter-sysfs.h	2008/09/19 03:42:37	1.4
@@ -18,6 +18,6 @@
 #include "config.h"
 #include "dev-cache.h"
 
-struct dev_filter *sysfs_filter_create(const char *proc);
+struct dev_filter *sysfs_filter_create(const char *sysfs_dir);
 
 #endif
--- LVM2/lib/commands/toolcontext.c	2008/06/25 16:52:26	1.60
+++ LVM2/lib/commands/toolcontext.c	2008/09/19 03:42:37	1.61
@@ -75,6 +75,49 @@
 	return 1;
 }
 
+static void _get_sysfs_dir(struct cmd_context *cmd)
+{
+	static char proc_mounts[PATH_MAX];
+	static char *split[4], buffer[PATH_MAX + 16];
+	FILE *fp;
+	char *sys_mnt = NULL;
+
+	cmd->sysfs_dir[0] = '\0';
+	if (!*cmd->proc_dir) {
+		log_debug("No proc filesystem found: skipping sysfs detection");
+		return;
+	}
+
+	if (dm_snprintf(proc_mounts, sizeof(proc_mounts),
+			 "%s/mounts", cmd->proc_dir) < 0) {
+		log_error("Failed to create /proc/mounts string for sysfs detection");
+		return;
+	}
+
+	if (!(fp = fopen(proc_mounts, "r"))) {
+		log_sys_error("_get_sysfs_dir: fopen %s", proc_mounts);
+		return;
+	}
+
+	while (fgets(buffer, sizeof(buffer), fp)) {
+		if (dm_split_words(buffer, 4, 0, split) == 4 &&
+		    !strcmp(split[2], "sysfs")) {
+			sys_mnt = split[1];
+			break;
+		}
+	}
+
+	if (fclose(fp))
+		log_sys_error("fclose", proc_mounts);
+
+	if (!sys_mnt) {
+		log_error("Failed to find sysfs mount point");
+		return;
+	}
+
+	strncpy(cmd->sysfs_dir, sys_mnt, sizeof(cmd->sysfs_dir));
+}
+
 static void _init_logging(struct cmd_context *cmd)
 {
 	int append = 1;
@@ -189,6 +232,8 @@
 		cmd->proc_dir[0] = '\0';
 	}
 
+	_get_sysfs_dir(cmd);
+
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_int(cmd,
 							   "global/activation",
@@ -534,7 +579,7 @@
 	 */
 	if (find_config_tree_bool(cmd, "devices/sysfs_scan",
 			     DEFAULT_SYSFS_SCAN)) {
-		if ((filters[nr_filt] = sysfs_filter_create(cmd->proc_dir)))
+		if ((filters[nr_filt] = sysfs_filter_create(cmd->sysfs_dir)))
 			nr_filt++;
 	}
 
--- LVM2/lib/commands/toolcontext.h	2008/04/08 12:49:20	1.23
+++ LVM2/lib/commands/toolcontext.h	2008/09/19 03:42:37	1.24
@@ -89,6 +89,7 @@
 	char sys_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
+	char sysfs_dir[PATH_MAX];
 };
 
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);


