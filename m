From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Jan 2011 15:29:25 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20110106152925.9121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-06 15:29:24

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/filters    : filter-persistent.c 

Log message:
	Fix memory leak in filter creation error path
	
	If some allocation for peristent filter fails its memory reference
	was lost, fix it by calling filter's destructor.
	
	Fix log_error messages for failing allocation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1862&r2=1.1863
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2011/01/05 23:18:46	1.1862
+++ LVM2/WHATS_NEW	2011/01/06 15:29:24	1.1863
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Fix memory leak in filter creation error path.
   Add missing tests in _setup_task().
   Fail poll daemon creation when lvmcache_init() fails.
   Return defined value for errors in _copy_percent() and _snap_percent().
--- LVM2/lib/commands/toolcontext.c	2010/12/20 14:34:49	1.113
+++ LVM2/lib/commands/toolcontext.c	2011/01/06 15:29:24	1.114
@@ -708,6 +708,7 @@
 		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
 		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
 			log_error("Persistent cache filename too long.");
+			f3->destroy(f3);
 			return 0;
 		}
 	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
@@ -716,6 +717,7 @@
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
 				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
 		log_error("Persistent cache filename too long.");
+		f3->destroy(f3);
 		return 0;
 	}
 
@@ -723,8 +725,9 @@
 		dev_cache = cache_file;
 
 	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
-		log_error("Failed to create persistent device filter");
-		return 0;
+		log_verbose("Failed to create persistent device filter.");
+		f3->destroy(f3);
+		return_0;
 	}
 
 	/* Should we ever dump persistent filter state? */
--- LVM2/lib/filters/filter-persistent.c	2010/12/20 13:12:56	1.47
+++ LVM2/lib/filters/filter-persistent.c	2011/01/06 15:29:24	1.48
@@ -318,13 +318,16 @@
 	struct dev_filter *f = NULL;
 	struct stat info;
 
-	if (!(pf = dm_zalloc(sizeof(*pf))))
-		return_NULL;
+	if (!(pf = dm_zalloc(sizeof(*pf)))) {
+		log_error("Allocation of persistent filter failed.");
+		return NULL;
+	}
 
-	if (!(pf->file = dm_malloc(strlen(file) + 1)))
-		goto_bad;
+	if (!(pf->file = dm_strdup(file))) {
+		log_error("Filename duplication for persistent filter failed.");
+		goto bad;
+	}
 
-	strcpy(pf->file, file);
 	pf->real = real;
 
 	if (!(_init_hash(pf))) {
@@ -332,8 +335,10 @@
 		goto bad;
 	}
 
-	if (!(f = dm_malloc(sizeof(*f))))
-		goto_bad;
+	if (!(f = dm_malloc(sizeof(*f)))) {
+		log_error("Allocation of device filter for persistent filter failed.");
+		goto bad;
+	}
 
 	/* Only merge cache file before dumping it if it changed externally. */
 	if (!stat(pf->file, &info))


