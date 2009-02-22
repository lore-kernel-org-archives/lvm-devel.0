From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2009 21:14:39 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090222211439.24990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-22 21:14:38

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c toolcontext.h 
	tools          : lvmcmdline.c 

Log message:
	Add system_dir parameter to create_toolcontext() and call it system_dir
	everywhere for consistency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1048&r2=1.1049
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2009/02/22 19:00:26	1.1048
+++ LVM2/WHATS_NEW	2009/02/22 21:14:37	1.1049
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add system_dir parameter to create_toolcontext().
   Add --dataalignment to pvcreate to specify alignment of data area.
   Exclude LCK_CACHE locks from _vg_lock_count, fixing interrupt unblocking.
   Provide da and mda locations in debug message when writing text format label.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/01/26 19:01:32	1.56
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/02/22 21:14:38	1.57
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -724,7 +724,7 @@
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(1))) {
+	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
--- LVM2/lib/commands/toolcontext.c	2008/12/18 05:27:18	1.72
+++ LVM2/lib/commands/toolcontext.c	2009/02/22 21:14:38	1.73
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -64,7 +64,7 @@
 
 	/* Set to "" to avoid using any system directory */
 	if ((e = getenv("LVM_SYSTEM_DIR"))) {
-		if (dm_snprintf(cmd->sys_dir, sizeof(cmd->sys_dir),
+		if (dm_snprintf(cmd->system_dir, sizeof(cmd->system_dir),
 				 "%s", e) < 0) {
 			log_error("LVM_SYSTEM_DIR environment variable "
 				  "is too long.");
@@ -393,7 +393,7 @@
 		filler = "_";
 
 	if (dm_snprintf(config_file, sizeof(config_file), "%s/lvm%s%s.conf",
-			 cmd->sys_dir, filler, tag) < 0) {
+			 cmd->system_dir, filler, tag) < 0) {
 		log_error("LVM_SYSTEM_DIR or tag was too long");
 		return 0;
 	}
@@ -442,7 +442,7 @@
 static int _init_lvm_conf(struct cmd_context *cmd)
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
-	if (!*cmd->sys_dir) {
+	if (!*cmd->system_dir) {
 		if (!(cmd->cft = create_config_tree(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
@@ -663,7 +663,7 @@
 	if (cache_dir || cache_file_prefix) {
 		if (dm_snprintf(cache_file, sizeof(cache_file),
 		    "%s%s%s/%s.cache",
-		    cache_dir ? "" : cmd->sys_dir,
+		    cache_dir ? "" : cmd->system_dir,
 		    cache_dir ? "" : "/",
 		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
 		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
@@ -673,7 +673,7 @@
 	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
 		   (dm_snprintf(cache_file, sizeof(cache_file),
 				"%s/%s/%s.cache",
-				cmd->sys_dir, DEFAULT_CACHE_SUBDIR,
+				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
 				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
 		log_error("Persistent cache filename too long.");
 		return 0;
@@ -691,7 +691,7 @@
 	if (find_config_tree_int(cmd, "devices/write_cache_state", 1))
 		cmd->dump_filter = 1;
 
-	if (!*cmd->sys_dir)
+	if (!*cmd->system_dir)
 		cmd->dump_filter = 0;
 
 	/*
@@ -924,7 +924,7 @@
 	char default_dir[PATH_MAX];
 	const char *dir;
 
-	if (!cmd->sys_dir) {
+	if (!cmd->system_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
@@ -943,10 +943,10 @@
 					 DEFAULT_ARCHIVE_NUMBER);
 
 	if (dm_snprintf
-	    (default_dir, sizeof(default_dir), "%s/%s", cmd->sys_dir,
+	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_ARCHIVE_SUBDIR) == -1) {
 		log_err("Couldn't create default archive path '%s/%s'.",
-			cmd->sys_dir, DEFAULT_ARCHIVE_SUBDIR);
+			cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
 		return 0;
 	}
 
@@ -965,10 +965,10 @@
 			     DEFAULT_BACKUP_ENABLED);
 
 	if (dm_snprintf
-	    (default_dir, sizeof(default_dir), "%s/%s", cmd->sys_dir,
+	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_BACKUP_SUBDIR) == -1) {
 		log_err("Couldn't create default backup path '%s/%s'.",
-			cmd->sys_dir, DEFAULT_BACKUP_SUBDIR);
+			cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
 		return 0;
 	}
 
@@ -998,7 +998,8 @@
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_long_lived)
+struct cmd_context *create_toolcontext(unsigned is_long_lived,
+				       const char *system_dir)
 {
 	struct cmd_context *cmd;
 
@@ -1028,13 +1029,19 @@
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
-	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
+	/*
+	 * Environment variable LVM_SYSTEM_DIR overrides this below.
+	 */
+        if (system_dir)
+		strncpy(cmd->system_dir, system_dir, sizeof(cmd->system_dir) - 1);
+	else
+		strcpy(cmd->system_dir, DEFAULT_SYS_DIR);
 
 	if (!_get_env_vars(cmd))
 		goto error;
 
 	/* Create system directory if it doesn't already exist */
-	if (*cmd->sys_dir && !dm_create_dir(cmd->sys_dir)) {
+	if (*cmd->system_dir && !dm_create_dir(cmd->system_dir)) {
 		log_error("Failed to create LVM2 system dir for metadata backups, config "
 			  "files and internal cache.");
 		log_error("Set environment variable LVM_SYSTEM_DIR to alternative location "
--- LVM2/lib/commands/toolcontext.h	2008/12/18 05:27:18	1.30
+++ LVM2/lib/commands/toolcontext.h	2009/02/22 21:14:38	1.31
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -88,13 +88,18 @@
 	struct dm_list tags;
 	int hosttags;
 
-	char sys_dir[PATH_MAX];
+	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
+/*
+ * system_dir may be NULL to use the default value.
+ * The environment variable LVM_SYSTEM_DIR always takes precedence.
+ */
+struct cmd_context *create_toolcontext(unsigned is_long_lived,
+				       const char *system_dir);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
--- LVM2/tools/lvmcmdline.c	2009/02/03 16:23:19	1.92
+++ LVM2/tools/lvmcmdline.c	2009/02/22 21:14:38	1.93
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1158,7 +1158,7 @@
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(0)))
+	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
 	return cmd;


