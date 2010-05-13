From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2010 13:04:06 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20100513130406.11244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-13 13:04:06

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/filters    : filter-persistent.c filter-persistent.h 

Log message:
	Currently if clvmd is running and user issues vgscan,
	the device cache file is dumped both in vgscan and clvmd process.
	
	Unfortunately, clvmd calls lvmcache_label_scan,
	it properly destroys persistent filter, but during
	persistent_filter_dump it merges old cache content back!
	
	This causes that change in filters is not properly propagated
	into device cache after vgscan on cluster.
	(Only new devices are added.)
	
	https://bugzilla.redhat.com/show_bug.cgi?id=591861

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1555&r2=1.1556
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/05/11 08:57:02	1.1555
+++ LVM2/WHATS_NEW	2010/05/13 13:04:03	1.1556
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Do not merge old device cache after we run full scan. (2.02.56)
   Add pkgconfigdir Makefile variable for make install override.
   Switch usage of Libs.private: to Requires.private: in devmapper.pc, lvm2app.pc.
   Use field Requires.private: for devmapper-event.pc.
--- LVM2/lib/cache/lvmcache.c	2010/04/30 12:54:31	1.85
+++ LVM2/lib/cache/lvmcache.c	2010/05/13 13:04:05	1.86
@@ -567,7 +567,7 @@
 	 * device cache for the benefit of short-lived processes.
 	 */
 	if (full_scan == 2 && cmd->is_long_lived && cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
+		persistent_filter_dump(cmd->filter, 0);
 
 	r = 1;
 
--- LVM2/lib/commands/toolcontext.c	2010/05/05 22:37:52	1.96
+++ LVM2/lib/commands/toolcontext.c	2010/05/13 13:04:05	1.97
@@ -1341,7 +1341,7 @@
 void destroy_toolcontext(struct cmd_context *cmd)
 {
 	if (cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
+		persistent_filter_dump(cmd->filter, 1);
 
 	archive_exit(cmd);
 	backup_exit(cmd);
--- LVM2/lib/filters/filter-persistent.c	2010/01/06 13:25:36	1.40
+++ LVM2/lib/filters/filter-persistent.c	2010/05/13 13:04:05	1.41
@@ -168,7 +168,7 @@
 		fprintf(fp, "\n\t]\n");
 }
 
-int persistent_filter_dump(struct dev_filter *f)
+int persistent_filter_dump(struct dev_filter *f, int merge_existing)
 {
 	struct pfilter *pf;
 	char *tmp_file;
@@ -220,7 +220,7 @@
 	/*
 	 * If file contents changed since we loaded it, merge new contents
 	 */
-	if (info.st_ctime != pf->ctime)
+	if (merge_existing && info.st_ctime != pf->ctime)
 		/* Keep cft open to avoid losing lock */
 		persistent_filter_load(f, &cft);
 
--- LVM2/lib/filters/filter-persistent.h	2007/08/20 20:55:25	1.6
+++ LVM2/lib/filters/filter-persistent.h	2010/05/13 13:04:05	1.7
@@ -23,6 +23,6 @@
 
 int persistent_filter_wipe(struct dev_filter *f);
 int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out);
-int persistent_filter_dump(struct dev_filter *f);
+int persistent_filter_dump(struct dev_filter *f, int merge_existing);
 
 #endif


