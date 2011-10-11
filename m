From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:09:02 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20111011090902.1856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:09:01

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/metadata   : metadata.c 

Log message:
	Check for refresh_filter failure
	
	Properly detect if the filters were refreshed properly.
	
	(May needs few more fixes ??)
	
	Filter refresh may fail because it may be out of free file descriptors
	when clvmd gets overloaded.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2155&r2=1.2156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.468&r2=1.469

--- LVM2/WHATS_NEW	2011/10/11 09:05:20	1.2155
+++ LVM2/WHATS_NEW	2011/10/11 09:09:00	1.2156
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add check for access through NULL pointer when refresh_filter() fails.
   Use pthread condition for SINGLENODE lock implementation.
   Improve backtrace reporting for some dev_manager_ functions.
   Change message severity to log_warn when symlink creation fails.
--- LVM2/lib/cache/lvmcache.c	2011/09/01 10:25:22	1.118
+++ LVM2/lib/cache/lvmcache.c	2011/10/11 09:09:00	1.119
@@ -597,12 +597,10 @@
 		goto out;
 	}
 
-	if (full_scan == 2 && !cmd->filter->use_count && !refresh_filters(cmd)) {
-		log_error("refresh filters failed");
-		goto out;
-	}
+	if (full_scan == 2 && (cmd->filter && !cmd->filter->use_count) && !refresh_filters(cmd))
+		goto_out;
 
-	if (!(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
+	if (!cmd->filter || !(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
 		log_error("dev_iter creation failed");
 		goto out;
 	}
--- LVM2/lib/commands/toolcontext.c	2011/09/22 17:39:57	1.137
+++ LVM2/lib/commands/toolcontext.c	2011/10/11 09:09:00	1.138
@@ -786,7 +786,7 @@
 	cmd->dump_filter = 0;
 
 	if (!(f3 = _init_filter_components(cmd)))
-		return 0;
+		return_0;
 
 	init_ignore_suspended_devices(find_config_tree_int(cmd,
 	    "devices/ignore_suspended_devices", DEFAULT_IGNORE_SUSPENDED_DEVICES));
@@ -1402,7 +1402,8 @@
 		cmd->filter = NULL;
 	}
 
-	r = _init_filters(cmd, 0);
+	if (!(r = _init_filters(cmd, 0)))
+                stack;
 
 	/*
 	 * During repair code must not reset suspended flag.
--- LVM2/lib/metadata/metadata.c	2011/09/27 17:09:43	1.468
+++ LVM2/lib/metadata/metadata.c	2011/10/11 09:09:00	1.469
@@ -1373,7 +1373,9 @@
 	/* Is there an md superblock here? */
 	/* FIXME: still possible issues here - rescan cache? */
 	if (!dev && md_filtering()) {
-		refresh_filters(cmd);
+		if (!refresh_filters(cmd))
+			goto_bad;
+
 		init_md_filtering(0);
 		dev = dev_cache_get(name, cmd->filter);
 		init_md_filtering(1);


