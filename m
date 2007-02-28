From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2007 18:27:14 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/commands ...
Message-ID: <20070228182714.26052.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-28 18:27:13

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/misc       : lvm-file.c 
	man            : lvm.conf.5 

Log message:
	Move .cache file into a new /etc/lvm/cache directory by default.
	Add devices/cache_dir & devices/cache_file_prefix, deprecating devices/cache.
	Create directory in fcntl_lock_file() if required.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.576&r2=1.577
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2007/02/14 16:51:47	1.576
+++ LVM2/WHATS_NEW	2007/02/28 18:27:11	1.577
@@ -1,5 +1,8 @@
 Version 2.02.23 - 
 ====================================
+  Move .cache file into a new /etc/lvm/cache directory by default.
+  Add devices/cache_dir & devices/cache_file_prefix, deprecating devices/cache.
+  Create directory in fcntl_lock_file() if required.
   Exclude readline support from lvm.static.
   Fix a leak in a reporting error path (2.02.19).
 
--- LVM2/doc/example.conf	2007/02/13 16:04:01	1.29
+++ LVM2/doc/example.conf	2007/02/28 18:27:12	1.30
@@ -56,10 +56,14 @@
     # filter = [ "a|^/dev/hda8$|", "r/.*/" ]
 
     # The results of the filtering are cached on disk to avoid
-    # rescanning dud devices (which can take a very long time).  By
-    # default this cache file is hidden in the /etc/lvm directory.
-    # It is safe to delete this file: the tools regenerate it.
-    cache = "/etc/lvm/.cache"
+    # rescanning dud devices (which can take a very long time).
+    # By default this cache is stored in the /etc/lvm/cache directory
+    # in a file called '.cache'.
+    # It is safe to delete the contents: the tools regenerate it.
+    # (The old setting 'cache' is still respected if neither of
+    # these new ones is present.)
+    cache_dir = "/etc/lvm/cache"
+    cache_file_prefix = ""
 
     # You can turn off writing this cache file by setting this to 0.
     write_cache_state = 1
--- LVM2/lib/commands/toolcontext.c	2007/02/08 17:31:02	1.48
+++ LVM2/lib/commands/toolcontext.c	2007/02/28 18:27:12	1.49
@@ -575,7 +575,7 @@
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
-	const char *dev_cache;
+	const char *dev_cache = NULL, *cache_dir, *cache_file_prefix;
 	struct dev_filter *f3, *f4;
 	struct stat st;
 	char cache_file[PATH_MAX];
@@ -585,19 +585,35 @@
 	if (!(f3 = _init_filter_components(cmd)))
 		return 0;
 
-	if (dm_snprintf(cache_file, sizeof(cache_file),
-			 "%s/.cache", cmd->sys_dir) < 0) {
-		log_error("Persistent cache filename too long ('%s/.cache').",
-			  cmd->sys_dir);
-		return 0;
-	}
-
 	init_ignore_suspended_devices(find_config_tree_int(cmd,
 	    "devices/ignore_suspended_devices", DEFAULT_IGNORE_SUSPENDED_DEVICES));
 
-	dev_cache = find_config_tree_str(cmd, "devices/cache",
-				    cache_file);
-	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
+	/*
+	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
+	 */
+	cache_dir = find_config_tree_str(cmd, "devices/cache_dir", NULL);
+	cache_file_prefix = find_config_tree_str(cmd, "devices/cache_file_prefix", NULL);
+
+	if (cache_dir || cache_file_prefix) {
+		if (dm_snprintf(cache_file, sizeof(cache_file),
+		    "%s%s%s/%s.cache",
+		    cache_dir ? "" : cmd->sys_dir,
+		    cache_dir ? "" : "/",
+		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
+		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
+			log_error("Persistent cache filename too long.");
+			return 0;
+		}
+	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
+		   (dm_snprintf(cache_file, sizeof(cache_file),
+				"%s/%s/%s.cache",
+				cmd->sys_dir, DEFAULT_CACHE_SUBDIR,
+				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
+		log_error("Persistent cache filename too long.");
+		return 0;
+	}
+
+	if (!(f4 = persistent_filter_create(f3, dev_cache ? : cache_file))) {
 		log_error("Failed to create persistent device filter");
 		return 0;
 	}
--- LVM2/lib/config/defaults.h	2007/01/25 21:22:30	1.30
+++ LVM2/lib/config/defaults.h	2007/02/28 18:27:12	1.31
@@ -21,6 +21,8 @@
 
 #define DEFAULT_ARCHIVE_SUBDIR "archive"
 #define DEFAULT_BACKUP_SUBDIR "backup"
+#define DEFAULT_CACHE_SUBDIR "cache"
+#define DEFAULT_CACHE_FILE_PREFIX ""
 
 #define DEFAULT_ARCHIVE_DAYS 30
 #define DEFAULT_ARCHIVE_NUMBER 10
--- LVM2/lib/misc/lvm-file.c	2007/01/25 14:37:48	1.18
+++ LVM2/lib/misc/lvm-file.c	2007/02/28 18:27:12	1.19
@@ -256,6 +256,8 @@
 int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 {
 	int lockfd;
+	char *dir;
+	char *c;
 	struct flock lock = {
 		.l_type = lock_type,
 		.l_whence = 0,
@@ -263,6 +265,17 @@
 		.l_len = 0
 	};
 
+	if (!(dir = dm_strdup(file))) {
+		log_error("fcntl_lock_file failed in strdup.");
+		return -1;
+	}
+
+	if ((c = strrchr(dir, '/')))
+		*c = '\0';
+
+	if (!create_dir(dir))
+		return -1;
+
 	log_very_verbose("Locking %s (%s, %hd)", file,
 			 (lock_type == F_WRLCK) ? "F_WRLCK" : "F_RDLCK",
 			 lock_type);
--- LVM2/man/lvm.conf.5	2006/08/31 20:56:33	1.17
+++ LVM2/man/lvm.conf.5	2007/02/28 18:27:13	1.18
@@ -95,8 +95,8 @@
 As an example, to ignore /dev/cdrom you could use:
 \fBdevices { filter=["r|cdrom|"] }\fP 
 .IP
-\fBcache\fP \(em Persistent filter cache file.
-Defaults to "/etc/lvm/.cache".
+\fBcache_dir\fP \(em Persistent filter cache file directory.
+Defaults to "/etc/lvm/cache".
 .IP
 \fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the 
 persistent filter cache file when \fBlvm\fP exits.
@@ -364,9 +364,9 @@
 the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
 .SH FILES
 .I /etc/lvm/lvm.conf
-.I /etc/lvm/.cache
 .I /etc/lvm/archive
 .I /etc/lvm/backup
+.I /etc/lvm/cache/.cache
 .I /var/lock/lvm
 .SH SEE ALSO
 .BR lvm (8),


