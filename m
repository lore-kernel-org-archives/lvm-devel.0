From: meyering@sourceware.org <meyering@sourceware.org>
Date: 28 Jul 2007 12:26:22 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20070728122622.24978.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-28 12:26:21

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/format_text: archiver.c format-text.c 
	lib/locking    : file_locking.c 
	lib/misc       : lvm-file.c lvm-file.h 

Log message:
	Remove create_dir function; use now-equivalent dm_create_dir instead.
	* lib/misc/lvm-file.c (_create_dir_recursive, create_dir): Remove functions.
	* lib/misc/lvm-file.h (create_dir): Remove declaration.
	* lib/commands/toolcontext.c (create_toolcontext): s/create_dir/dm_create_dir/
	* lib/format_text/archiver.c (archive, backup): Likewise.
	* lib/format_text/format-text.c (_add_dir): Likewise.
	* lib/locking/file_locking.c (init_file_locking): Likewise.
	Patch by Jun'ichi Nomura.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.672&r2=1.673
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2007/07/26 13:28:32	1.672
+++ LVM2/WHATS_NEW	2007/07/28 12:26:21	1.673
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Remove create_dir function; use now-equivalent dm_create_dir instead
   Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
   Fix clvmd if compiled with gulm support. (2.02.26)
   Trivial fix to lvdisplay man page.
--- LVM2/lib/commands/toolcontext.c	2007/07/23 10:45:49	1.52
+++ LVM2/lib/commands/toolcontext.c	2007/07/28 12:26:21	1.53
@@ -939,7 +939,7 @@
 		goto error;
 
 	/* Create system directory if it doesn't already exist */
-	if (*cmd->sys_dir && !create_dir(cmd->sys_dir)) {
+	if (*cmd->sys_dir && !dm_create_dir(cmd->sys_dir)) {
 		log_error("Failed to create LVM2 system dir for metadata backups, config "
 			  "files and internal cache.");
 		log_error("Set environment variable LVM_SYSTEM_DIR to alternative location "
--- LVM2/lib/format_text/archiver.c	2007/06/28 17:33:44	1.7
+++ LVM2/lib/format_text/archiver.c	2007/07/28 12:26:21	1.8
@@ -117,7 +117,7 @@
 		return 1;
 	}
 
-	if (!create_dir(vg->cmd->archive_params->dir))
+	if (!dm_create_dir(vg->cmd->archive_params->dir))
 		return 0;
 
 	/* Trap a read-only file system */
@@ -223,7 +223,7 @@
 		return 1;
 	}
 
-	if (!create_dir(vg->cmd->backup_params->dir))
+	if (!dm_create_dir(vg->cmd->backup_params->dir))
 		return 0;
 
 	/* Trap a read-only file system */
--- LVM2/lib/format_text/format-text.c	2007/07/24 17:48:08	1.78
+++ LVM2/lib/format_text/format-text.c	2007/07/28 12:26:21	1.79
@@ -1856,7 +1856,7 @@
 {
 	struct dir_list *dl;
 
-	if (create_dir(dir)) {
+	if (dm_create_dir(dir)) {
 		if (!(dl = dm_malloc(sizeof(struct list) + strlen(dir) + 1))) {
 			log_error("_add_dir allocation failed");
 			return 0;
--- LVM2/lib/locking/file_locking.c	2007/07/20 15:22:46	1.28
+++ LVM2/lib/locking/file_locking.c	2007/07/28 12:26:21	1.29
@@ -284,7 +284,7 @@
 						DEFAULT_LOCK_DIR),
 		sizeof(_lock_dir));
 
-	if (!create_dir(_lock_dir))
+	if (!dm_create_dir(_lock_dir))
 		return 0;
 
 	/* Trap a read-only file system */
--- LVM2/lib/misc/lvm-file.c	2007/07/24 17:48:08	1.21
+++ LVM2/lib/misc/lvm-file.c	2007/07/28 12:26:21	1.22
@@ -140,56 +140,6 @@
 	return 1;
 }
 
-static int _create_dir_recursive(const char *dir)
-{
-	char *orig, *s;
-	int rc;
-
-	log_verbose("Creating directory \"%s\"", dir);
-	/* Create parent directories */
-	orig = s = dm_strdup(dir);
-	while ((s = strchr(s, '/')) != NULL) {
-		*s = '\0';
-		if (*orig) {
-			rc = mkdir(orig, 0777);
-			if (rc < 0 && errno != EEXIST) {
-				if (errno != EROFS)
-					log_sys_error("mkdir", orig);
-				dm_free(orig);
-				return 0;
-			}
-		}
-		*s++ = '/';
-	}
-	dm_free(orig);
-
-	/* Create final directory */
-	rc = mkdir(dir, 0777);
-	if (rc < 0 && errno != EEXIST) {
-		if (errno != EROFS)
-			log_sys_error("mkdir", dir);
-		return 0;
-	}
-	return 1;
-}
-
-int create_dir(const char *dir)
-{
-	struct stat info;
-
-	if (!*dir)
-		return 1;
-
-	if (stat(dir, &info) < 0)
-		return _create_dir_recursive(dir);
-
-	if (S_ISDIR(info.st_mode))
-		return 1;
-
-	log_error("Directory \"%s\" not found", dir);
-	return 0;
-}
-
 int is_empty_dir(const char *dir)
 {
 	struct dirent *dirent;
@@ -273,7 +223,7 @@
 	if ((c = strrchr(dir, '/')))
 		*c = '\0';
 
-	if (!create_dir(dir)) {
+	if (!dm_create_dir(dir)) {
 		dm_free(dir);
 		return -1;
 	}
--- LVM2/lib/misc/lvm-file.h	2007/07/24 17:48:08	1.10
+++ LVM2/lib/misc/lvm-file.h	2007/07/28 12:26:21	1.11
@@ -39,12 +39,6 @@
  */
 int is_empty_dir(const char *dir);
 
-/*
- * Create directory (recursively) if necessary.  Return 1
- * if directory was successfully created (or already exists), else 0.
- */
-int create_dir(const char *dir);
-
 /* Sync directory changes */
 void sync_dir(const char *file);
 


