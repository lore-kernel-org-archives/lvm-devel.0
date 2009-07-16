From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jul 2009 00:37:01 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090716003701.30823.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-16 00:37:00

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c 
	lib/log        : log.c lvm-logging.h 
	liblvm         : lvm_base.c 
	tools          : lvmcmdline.c 

Log message:
	Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
	Change create_toolcontext to still return an object if it fails part-way.
	Add EUNCLASSIFIED (-1) as the default LVM errno code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1190&r2=1.1191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2009/07/15 23:57:54	1.1190
+++ LVM2/WHATS_NEW	2009/07/16 00:36:59	1.1191
@@ -1,5 +1,8 @@
 Version 2.02.50 - 
 ================================
+  Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
+  Change create_toolcontext to still return an object if it fails part-way.
+  Add EUNCLASSIFIED (-1) as the default LVM errno code.
   Store any errno and error messages issued while processing each command.
   Use log_error macro consistently throughout in place of log_err.
 
--- LVM2/daemons/clvmd/lvm-functions.c	2009/07/15 23:57:55	1.65
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/07/16 00:36:59	1.66
@@ -792,6 +792,11 @@
 		return 0;
 	}
 
+	if (stored_errno()) {
+		destroy_toolcontext(cmd);
+		return 0;
+	}
+
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
--- LVM2/lib/commands/toolcontext.c	2009/07/15 23:57:55	1.81
+++ LVM2/lib/commands/toolcontext.c	2009/07/16 00:36:59	1.82
@@ -1083,6 +1083,9 @@
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
+	/* FIXME Make this configurable? */
+	reset_lvm_errno(1);
+
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -1092,7 +1095,7 @@
 		strcpy(cmd->system_dir, DEFAULT_SYS_DIR);
 
 	if (!_get_env_vars(cmd))
-		goto error;
+		goto_out;
 
 	/* Create system directory if it doesn't already exist */
 	if (*cmd->system_dir && !dm_create_dir(cmd->system_dir)) {
@@ -1100,58 +1103,58 @@
 			  "files and internal cache.");
 		log_error("Set environment variable LVM_SYSTEM_DIR to alternative location "
 			  "or empty string.");
-		goto error;
+		goto out;
 	}
 
 	if (!(cmd->libmem = dm_pool_create("library", 4 * 1024))) {
 		log_error("Library memory pool creation failed");
-		goto error;
+		goto out;
 	}
 
 	if (!_init_lvm_conf(cmd))
-		goto error;
+		goto_out;
 
 	_init_logging(cmd);
 
 	if (!_init_hostname(cmd))
-		goto error;
+		goto_out;
 
 	if (!_init_tags(cmd, cmd->cft))
-		goto error;
+		goto_out;
 
 	if (!_init_tag_configs(cmd))
-		goto error;
+		goto_out;
 
 	if (!_merge_config_files(cmd))
-		goto error;
+		goto_out;
 
 	if (!_process_config(cmd))
-		goto error;
+		goto_out;
 
 	if (!_init_dev_cache(cmd))
-		goto error;
+		goto_out;
 
 	if (!_init_filters(cmd, 1))
-		goto error;
+		goto_out;
 
 	if (!(cmd->mem = dm_pool_create("command", 4 * 1024))) {
 		log_error("Command memory pool creation failed");
-		goto error;
+		goto out;
 	}
 
 	memlock_init(cmd);
 
 	if (!_init_formats(cmd))
-		goto error;
+		goto_out;
 
 	if (!init_lvmcache_orphans(cmd))
-		goto error;
+		goto_out;
 
 	if (!_init_segtypes(cmd))
-		goto error;
+		goto_out;
 
 	if (!_init_backup(cmd))
-		goto error;
+		goto_out;
 
 	_init_rand(cmd);
 
@@ -1161,20 +1164,8 @@
 	cmd->current_settings = cmd->default_settings;
 
 	cmd->config_valid = 1;
-	reset_lvm_errno(1);  /* FIXME Move to top when cmd returned on error */
+out:
 	return cmd;
-
-      error:
-	_destroy_tag_configs(cmd);
-	dev_cache_exit();
-	if (cmd->filter)
-		cmd->filter->destroy(cmd->filter);
-	if (cmd->mem)
-		dm_pool_destroy(cmd->mem);
-	if (cmd->libmem)
-		dm_pool_destroy(cmd->libmem);
-	dm_free(cmd);
-	return NULL;
 }
 
 static void _destroy_formats(struct dm_list *formats)
--- LVM2/lib/log/log.c	2009/07/15 23:57:55	1.50
+++ LVM2/lib/log/log.c	2009/07/16 00:36:59	1.51
@@ -152,12 +152,12 @@
 	_store_errmsg = store_errmsg;
 }
 
-int lvm_errno(void)
+int stored_errno(void)
 {
 	return _lvm_errno;
 }
 
-const char *lvm_errmsg(void)
+const char *stored_errmsg(void)
 {
 	return _lvm_errmsg ? : "";
 }
--- LVM2/lib/log/lvm-logging.h	2009/07/15 23:57:55	1.4
+++ LVM2/lib/log/lvm-logging.h	2009/07/16 00:36:59	1.5
@@ -20,7 +20,8 @@
 	       const char *format, ...)
     __attribute__ ((format(printf, 5, 6)));
 
-#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , 0, ## x)
+#define EUNCLASSIFIED -1	/* Generic error code */
+#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , EUNCLASSIFIED, ## x)
 
 #include "log.h"
 
@@ -44,8 +45,8 @@
 
 int error_message_produced(void);
 void reset_lvm_errno(int store_errmsg);
-int lvm_errno(void);
-const char *lvm_errmsg(void);
+int stored_errno(void);
+const char *stored_errmsg(void);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
 /* Returns previous setting */
--- LVM2/liblvm/lvm_base.c	2009/07/14 03:01:18	1.3
+++ LVM2/liblvm/lvm_base.c	2009/07/16 00:37:00	1.4
@@ -29,6 +29,10 @@
 	cmd = create_toolcontext(1, system_dir);
 	if (!cmd)
 		return NULL;
+
+	if (stored_errno())
+		return (lvm_t) cmd;
+
 	/*
 	 * FIXME: if an non memory error occured, return the cmd (maybe some
 	 * cleanup needed).
@@ -66,3 +70,13 @@
 	/* FIXME: re-init locking needed here? */
 	return refresh_toolcontext((struct cmd_context *)libh);
 }
+
+int lvm_errno(lvm_t libh)
+{
+	return stored_errno();
+}
+
+const char *lvm_errmsg(lvm_t libh)
+{
+	return stored_errmsg();
+}
--- LVM2/tools/lvmcmdline.c	2009/07/15 23:57:55	1.101
+++ LVM2/tools/lvmcmdline.c	2009/07/16 00:37:00	1.102
@@ -1181,6 +1181,11 @@
 	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
+	if (stored_errno()) {
+		destroy_toolcontext(cmd);
+		return_NULL;
+	}
+
 	return cmd;
 }
 


