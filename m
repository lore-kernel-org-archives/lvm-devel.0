From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Jul 2007 10:45:50 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20070723104550.7325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-07-23 10:45:49

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/device     : dev-cache.c 

Log message:
	Fix loading of persistent cache if cache_dir is used. (2.02.23)
	Move lstat warning in _compare_paths to verbose output only.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.666&r2=1.667
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2007/07/20 15:48:39	1.666
+++ LVM2/WHATS_NEW	2007/07/23 10:45:49	1.667
@@ -1,4 +1,6 @@
 Version 2.02.28 -
+================================
+  Fix loading of persistent cache if cache_dir is used. (2.02.23)
   Eliminate uses of strdup+basename.  Use last_path_component instead.
   Use gcc's printf attribute wherever possible.
   In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
--- LVM2/lib/commands/toolcontext.c	2007/06/28 17:33:44	1.51
+++ LVM2/lib/commands/toolcontext.c	2007/07/23 10:45:49	1.52
@@ -611,7 +611,10 @@
 		return 0;
 	}
 
-	if (!(f4 = persistent_filter_create(f3, dev_cache ? : cache_file))) {
+	if (!dev_cache)
+		dev_cache = cache_file;
+
+	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
 		log_error("Failed to create persistent device filter");
 		return 0;
 	}
--- LVM2/lib/device/dev-cache.c	2007/04/27 18:52:05	1.48
+++ LVM2/lib/device/dev-cache.c	2007/07/23 10:45:49	1.49
@@ -205,11 +205,11 @@
 			*s1 = '\0';
 		}
 		if (lstat(p0, &stat0)) {
-			log_sys_error("lstat", p0);
+			log_sys_very_verbose("lstat", p0);
 			return 1;
 		}
 		if (lstat(p1, &stat1)) {
-			log_sys_error("lstat", p1);
+			log_sys_very_verbose("lstat", p1);
 			return 0;
 		}
 		if (S_ISLNK(stat0.st_mode) && !S_ISLNK(stat1.st_mode))


