From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2006 03:34:11 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20061104033411.18120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-04 03:34:10

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/config     : config.c config.h 
	lib/filters    : filter-persistent.c filter-persistent.h 
	lib/format_text: import.c 
	lib/misc       : lvm-file.c lvm-file.h 

Log message:
	Protect .cache manipulations with fcntl locking.
	Change .cache timestamp comparisons to use ctime.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.489&r2=1.490
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2006/11/02 23:33:20	1.489
+++ LVM2/WHATS_NEW	2006/11/04 03:34:09	1.490
@@ -1,5 +1,7 @@
 Version 2.02.14 - 
 ===================================
+  Protect .cache manipulations with fcntl locking.
+  Change .cache timestamp comparisons to use ctime.
   Fix mirror log LV writing to set all bits in whole LV.
   Fix clustered VG detection and default runlevels in clvmd_init_rhel4.
   Fix high-level free space check for partial allocations.
--- LVM2/lib/commands/toolcontext.c	2006/08/31 22:21:00	1.42
+++ LVM2/lib/commands/toolcontext.c	2006/11/04 03:34:09	1.43
@@ -330,7 +330,7 @@
 		return 0;
 	}
 
-	if (!(cfl->cft = create_config_tree(config_file))) {
+	if (!(cfl->cft = create_config_tree(config_file, 0))) {
 		log_error("config_tree allocation failed");
 		return 0;
 	}
@@ -370,7 +370,7 @@
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
 	if (!*cmd->sys_dir) {
-		if (!(cmd->cft = create_config_tree(NULL))) {
+		if (!(cmd->cft = create_config_tree(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -408,7 +408,7 @@
 
 	/* Replace temporary duplicate copy of lvm.conf */
 	if (cmd->cft->root) {
-		if (!(cmd->cft = create_config_tree(NULL))) {
+		if (!(cmd->cft = create_config_tree(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -609,8 +609,8 @@
 		cmd->dump_filter = 0;
 
 	if (!stat(dev_cache, &st) &&
-	    (st.st_mtime > config_file_timestamp(cmd->cft)) &&
-	    !persistent_filter_load(f4))
+	    (st.st_ctime != config_file_timestamp(cmd->cft)) &&
+	    !persistent_filter_load(f4, NULL))
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
 
--- LVM2/lib/config/config.c	2006/08/17 18:23:43	1.47
+++ LVM2/lib/config/config.c	2006/11/04 03:34:09	1.48
@@ -58,6 +58,8 @@
 	time_t timestamp;
 	char *filename;
 	int exists;
+	int keep_open;
+	struct device *dev;
 };
 
 static void _get_token(struct parser *p, int tok_prev);
@@ -95,7 +97,7 @@
 /*
  * public interface
  */
-struct config_tree *create_config_tree(const char *filename)
+struct config_tree *create_config_tree(const char *filename, int keep_open)
 {
 	struct cs *c;
 	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);
@@ -115,6 +117,8 @@
 	c->cft.root = (struct config_node *) NULL;
 	c->timestamp = 0;
 	c->exists = 0;
+	c->keep_open = keep_open;
+	c->dev = 0;
 	if (filename)
 		c->filename = dm_pool_strdup(c->mem, filename);
 	return &c->cft;
@@ -122,7 +126,12 @@
 
 void destroy_config_tree(struct config_tree *cft)
 {
-	dm_pool_destroy(((struct cs *) cft)->mem);
+	struct cs *c = (struct cs *) cft;
+
+	if (c->dev)
+		dev_close(c->dev);
+
+	dm_pool_destroy(c->mem);
 }
 
 static int _parse_config_file(struct parser *p, struct config_tree *cft)
@@ -143,7 +152,7 @@
 	struct config_tree *cft;
 	struct parser *p;
 
-	if (!(cft = create_config_tree(NULL)))
+	if (!(cft = create_config_tree(NULL, 0)))
 		return_NULL;
 
 	c = (struct cs *) cft;
@@ -250,7 +259,6 @@
 {
 	struct cs *c = (struct cs *) cft;
 	struct stat info;
-	struct device *dev;
 	int r = 1;
 
 	if (stat(c->filename, &info)) {
@@ -272,22 +280,23 @@
 		return 1;
 	}
 
-	if (!(dev = dev_create_file(c->filename, NULL, NULL, 1))) {
-		stack;
-		return 0;
-	}
+	if (!c->dev) {
+		if (!(c->dev = dev_create_file(c->filename, NULL, NULL, 1)))
+			return_0;
 
-	if (!dev_open_flags(dev, O_RDONLY, 0, 0)) {
-		stack;
-		return 0;
+		if (!dev_open_flags(c->dev, O_RDONLY, 0, 0))
+			return_0;
 	}
 
-	r = read_config_fd(cft, dev, 0, (size_t) info.st_size, 0, 0,
+	r = read_config_fd(cft, c->dev, 0, (size_t) info.st_size, 0, 0,
 			   (checksum_fn_t) NULL, 0);
 
-	dev_close(dev);
+	if (!c->keep_open) {
+		dev_close(c->dev);
+		c->dev = 0;
+	}
 
-	c->timestamp = info.st_mtime;
+	c->timestamp = info.st_ctime;
 
 	return r;
 }
@@ -331,7 +340,7 @@
 	}
 
 	/* Unchanged? */
-	if (c->timestamp == info.st_mtime)
+	if (c->timestamp == info.st_ctime)
 		return 0;
 
       reload:
--- LVM2/lib/config/config.h	2006/05/16 16:48:30	1.20
+++ LVM2/lib/config/config.h	2006/11/04 03:34:09	1.21
@@ -53,7 +53,7 @@
 	struct config_tree *cft;
 };
 
-struct config_tree *create_config_tree(const char *filename);
+struct config_tree *create_config_tree(const char *filename, int keep_open);
 struct config_tree *create_config_tree_from_string(struct cmd_context *cmd,
 						   const char *config_settings);
 void destroy_config_tree(struct config_tree *cft);
--- LVM2/lib/filters/filter-persistent.c	2006/04/19 15:33:06	1.27
+++ LVM2/lib/filters/filter-persistent.c	2006/11/04 03:34:09	1.28
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,6 +17,7 @@
 #include "config.h"
 #include "dev-cache.h"
 #include "filter-persistent.h"
+#include "lvm-file.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -26,11 +27,12 @@
 	char *file;
 	struct dm_hash_table *devices;
 	struct dev_filter *real;
+	time_t ctime;
 };
 
 /*
- * entries in the table can be in one of these
- * states.
+ * The hash table holds one of these two states
+ * against each entry.
  */
 #define PF_BAD_DEVICE ((void *) 1)
 #define PF_GOOD_DEVICE ((void *) 2)
@@ -93,22 +95,26 @@
 	return 1;
 }
 
-int persistent_filter_load(struct dev_filter *f)
+int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
-
-	int r = 0;
 	struct config_tree *cft;
+        struct stat info;
+	int r = 0;
 
-	if (!(cft = create_config_tree(pf->file))) {
-		stack;
-		return 0;
+        if (!stat(pf->file, &info))
+		pf->ctime = info.st_ctime;
+	else {
+                log_very_verbose("%s: stat failed: %s", pf->file,
+				 strerror(errno));
+		return_0;
 	}
 
-	if (!read_config_file(cft)) {
-		stack;
-		goto out;
-	}
+	if (!(cft = create_config_tree(pf->file, 1)))
+		return_0;
+
+	if (!read_config_file(cft))
+		goto_out;
 
 	_read_array(pf, cft, "persistent_filter_cache/valid_devices",
 		    PF_GOOD_DEVICE);
@@ -126,7 +132,10 @@
 	log_very_verbose("Loaded persistent filter cache from %s", pf->file);
 
       out:
-	destroy_config_tree(cft);
+	if (r && cft_out)
+		*cft_out = cft;
+	else
+		destroy_config_tree(cft);
 	return r;
 }
 
@@ -163,8 +172,12 @@
 int persistent_filter_dump(struct dev_filter *f)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
-
+	char *tmp_file;
+	struct stat info, info2;
+	struct config_tree *cft = NULL;
 	FILE *fp;
+	int lockfd;
+	int r = 0;
 
 	if (!dm_hash_get_num_entries(pf->devices)) {
 		log_very_verbose("Internal persistent device cache empty "
@@ -179,11 +192,43 @@
 
 	log_very_verbose("Dumping persistent device cache to %s", pf->file);
 
-	fp = fopen(pf->file, "w");
-	if (!fp) {
-		if (errno != EROFS)
-			log_sys_error("fopen", pf->file);
-		return 0;
+	while (1) {
+		if ((lockfd = fcntl_lock_file(pf->file, F_WRLCK, 0)) < 0)
+			return_0;
+
+		/*
+		 * Ensure we locked the file we expected
+		 */
+		if (fstat(lockfd, &info)) {
+			log_sys_error("fstat", pf->file);
+			goto out;
+		}
+		if (stat(pf->file, &info2)) {
+			log_sys_error("stat", pf->file);
+			goto out;
+		}
+
+		if (!memcmp(&info.st_ino, &info2.st_ino, sizeof(ino_t)))
+			break;
+	
+		fcntl_unlock_file(lockfd);
+	}
+
+	/*
+	 * If file contents changed since we loaded it, merge new contents
+	 */
+	if (info.st_ctime != pf->ctime)
+		/* Keep cft open to avoid losing lock */
+		persistent_filter_load(f, &cft);
+
+	tmp_file = alloca(strlen(pf->file) + 5);
+	sprintf(tmp_file, "%s.tmp", pf->file);
+
+	if (!(fp = fopen(tmp_file, "w"))) {
+		/* EACCES has been reported over NFS */
+		if (errno != EROFS && errno != EACCES)
+			log_sys_error("fopen", tmp_file);
+		goto out;
 	}
 
 	fprintf(fp, "# This file is automatically maintained by lvm.\n\n");
@@ -195,7 +240,20 @@
 
 	fprintf(fp, "}\n");
 	fclose(fp);
-	return 1;
+
+	if (rename(tmp_file, pf->file))
+		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
+			  strerror(errno));
+
+	r = 1;
+
+out:
+	fcntl_unlock_file(lockfd);
+
+	if (cft)
+		destroy_config_tree(cft);
+
+	return r;
 }
 
 static int _lookup_p(struct dev_filter *f, struct device *dev)
--- LVM2/lib/filters/filter-persistent.h	2004/03/30 19:35:38	1.4
+++ LVM2/lib/filters/filter-persistent.h	2006/11/04 03:34:09	1.5
@@ -22,7 +22,7 @@
 					    const char *file);
 
 int persistent_filter_wipe(struct dev_filter *f);
-int persistent_filter_load(struct dev_filter *f);
+int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out);
 int persistent_filter_dump(struct dev_filter *f);
 
 #endif
--- LVM2/lib/format_text/import.c	2006/05/11 17:58:58	1.41
+++ LVM2/lib/format_text/import.c	2006/11/04 03:34:09	1.42
@@ -43,7 +43,7 @@
 		_text_import_initialised = 1;
 	}
 
-	if (!(cft = create_config_tree(NULL)))
+	if (!(cft = create_config_tree(NULL, 0)))
 		return_NULL;
 
 	if ((!dev && !read_config_file(cft)) ||
@@ -94,7 +94,7 @@
 	*desc = NULL;
 	*when = 0;
 
-	if (!(cft = create_config_tree(file)))
+	if (!(cft = create_config_tree(file, 0)))
 		return_NULL;
 
 	if ((!dev && !read_config_file(cft)) ||
--- LVM2/lib/misc/lvm-file.c	2006/08/21 12:54:53	1.16
+++ LVM2/lib/misc/lvm-file.c	2006/11/04 03:34:10	1.17
@@ -244,3 +244,61 @@
       out:
 	dm_free(dir);
 }
+
+/*
+ * Attempt to obtain fcntl lock on a file, if necessary creating file first
+ * or waiting.
+ * Returns file descriptor on success, else -1.
+ * mode is F_WRLCK or F_RDLCK
+ */
+int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
+{
+	int lockfd;
+	struct flock lock = {
+		.l_type = lock_type,
+		.l_whence = 0,
+		.l_start = 0,
+		.l_len = 0
+	};
+
+	log_very_verbose("Locking %s (%s, %hd)", file,
+			 (lock_type == F_WRLCK) ? "F_WRLCK" : "F_RDLCK",
+			 lock_type);
+	if ((lockfd = open(file, O_RDWR | O_CREAT, 0777)) < 0) {
+		/* EACCES has been reported on NFS */
+		if (warn_if_read_only || (errno != EROFS && errno != EACCES))
+			log_sys_error("open", file);
+		else
+			stack;
+
+		return -1;
+	}
+
+	if (fcntl(lockfd, F_SETLKW, &lock)) {
+		log_sys_error("fcntl", file);
+		return -1;
+	}
+
+	return lockfd;
+}
+
+void fcntl_unlock_file(int lockfd)
+{
+	struct flock lock = {
+		.l_type = F_UNLCK,
+		.l_whence = 0,
+		.l_start = 0,
+		.l_len = 0
+	};
+
+	log_very_verbose("Unlocking fd %d", lockfd);
+
+	if (fcntl(lockfd, F_SETLK, &lock) == -1)
+		log_error("fcntl unlock failed on fd %d: %s", lockfd,
+			  strerror(errno));
+
+	if (close(lockfd))
+		log_error("lock file close failed on fd %d: %s", lockfd,
+			  strerror(errno));
+}
+
--- LVM2/lib/misc/lvm-file.h	2006/05/09 21:23:50	1.7
+++ LVM2/lib/misc/lvm-file.h	2006/11/04 03:34:10	1.8
@@ -48,4 +48,8 @@
 /* Sync directory changes */
 void sync_dir(const char *file);
 
+/* fcntl locking wrappers */
+int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only);
+void fcntl_unlock_file(int lockfd);
+
 #endif


