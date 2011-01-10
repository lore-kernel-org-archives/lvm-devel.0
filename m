From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:13:46 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20110110131346.20792.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:13:43

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format_text: import.c 
	lib/metadata   : metadata.h 

Log message:
	Change import_vg_from_buffer to use config_tree
	
	Change function import_vg_from_buffer() to import_vg_from_config_tree().
	Instead of creating config tree inside the function allow config tree to
	be passed as parameter - usable later for caching.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1866&r2=1.1867
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.227&r2=1.228

--- LVM2/WHATS_NEW	2011/01/10 13:07:58	1.1866
+++ LVM2/WHATS_NEW	2011/01/10 13:13:42	1.1867
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Pass config_tree to renamed function import_vg_from_config_tree().
   Detect NULL handle in get_property().
   Fix superfluous /usr in ocf_scriptdir instalation path.
   Add --with-ocfdir configurable option.
--- LVM2/lib/cache/lvmcache.c	2010/12/10 22:39:54	1.100
+++ LVM2/lib/cache/lvmcache.c	2011/01/10 13:13:42	1.101
@@ -26,6 +26,7 @@
 #include "format-text.h"
 #include "format_pool.h"
 #include "format1.h"
+#include "config.h"
 
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
@@ -650,12 +651,20 @@
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
+	if (!(vginfo->cft =
+	      create_config_tree_from_string(fid->fmt->cmd,
+					     vginfo->vgmetadata))) {
 		_free_cached_vgmetadata(vginfo);
-		free_vg(vg);
 		return_NULL;
 	}
 
+	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
+		_free_cached_vgmetadata(vginfo);
+		destroy_config_tree(vginfo->cft);
+		return_NULL;
+	}
+	destroy_config_tree(vginfo->cft);
+
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
--- LVM2/lib/cache/lvmcache.h	2010/12/10 22:39:54	1.35
+++ LVM2/lib/cache/lvmcache.h	2011/01/10 13:13:42	1.36
@@ -33,6 +33,7 @@
 struct cmd_context;
 struct format_type;
 struct volume_group;
+struct config_tree;
 
 /* One per VG */
 struct lvmcache_vginfo {
@@ -46,6 +47,7 @@
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
+	struct config_tree *cft; /* Config tree created from vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
--- LVM2/lib/format_text/import.c	2010/12/20 13:19:14	1.52
+++ LVM2/lib/format_text/import.c	2011/01/10 13:13:42	1.53
@@ -131,18 +131,14 @@
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_buffer(const char *buf,
-                                           struct format_instance *fid)
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid)
 {
 	struct volume_group *vg = NULL;
-	struct config_tree *cft;
 	struct text_vg_version_ops **vsn;
 
 	_init_text_import();
 
-	if (!(cft = create_config_tree_from_string(fid->fmt->cmd, buf)))
-		return_NULL;
-
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
 		if (!(*vsn)->check_version(cft))
 			continue;
@@ -155,6 +151,5 @@
 		break;
 	}
 
-	destroy_config_tree(cft);
 	return vg;
 }
--- LVM2/lib/metadata/metadata.h	2010/12/20 13:32:49	1.227
+++ LVM2/lib/metadata/metadata.h	2011/01/10 13:13:43	1.228
@@ -100,6 +100,7 @@
 //#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 //#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
+struct config_tree;
 struct metadata_area;
 
 /* Per-format per-metadata area operations */
@@ -388,6 +389,8 @@
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
 struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid);
 
 /*
  * Mirroring functions


