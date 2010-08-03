From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:13:01 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100803131301.26264.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:13:01

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1690&r2=1.1691
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197

--- LVM2/WHATS_NEW	2010/08/03 13:09:21	1.1690
+++ LVM2/WHATS_NEW	2010/08/03 13:13:01	1.1691
@@ -1,6 +1,7 @@
 Version 2.02.73 - 
 ================================
-  Fix constness warning in archive_file structure from archive.c.
+  Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().
+  Fix const warning in archive_file structure from archive.c.
   Clean generated files .exported_symbols_generated, example.conf for distclean.
   Handle failure of all mirrored log devices and all but one mirror leg. 
   Disallow 'mirrored' log type for cluster mirrors.
--- LVM2/lib/activate/dev_manager.c	2010/07/09 15:34:42	1.196
+++ LVM2/lib/activate/dev_manager.c	2010/08/03 13:13:01	1.197
@@ -220,7 +220,7 @@
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead)
 {
-	const char *dlid, *name;
+	char *dlid, *name;
 	int r;
 
 	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
@@ -236,7 +236,7 @@
 	log_debug("Getting device info for %s [%s]", name, dlid);
 	r = _info(dlid, with_open_count, with_read_ahead, info, read_ahead);
 
-	dm_pool_free(mem, (char*)name);
+	dm_pool_free(mem, name);
 	return r;
 }
 
@@ -812,7 +812,7 @@
 int dev_manager_mknodes(const struct logical_volume *lv)
 {
 	struct dm_info dminfo;
-	const char *name;
+	char *name;
 	int r = 0;
 
 	if (!(name = build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
@@ -826,7 +826,7 @@
 			r = _dev_manager_lv_rmnodes(lv);
 	}
 
-	dm_pool_free(lv->vg->cmd->mem, (char*)name);
+	dm_pool_free(lv->vg->cmd->mem, name);
 	return r;
 }
 


