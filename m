From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 15:08:34 -0000
Subject: LVM2/lib cache/lvmcache.c format_text/archive. ...
Message-ID: <20110311150834.25831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 15:08:32

Modified files:
	lib/cache      : lvmcache.c 
	lib/format_text: archive.c archiver.c 
	lib/metadata   : metadata.c 

Log message:
	Various cleanups for fid mem and ref_count changes.
	
	Missing free_vg on error_path in lvmcache_get_vg fn. Call destroy_instance
	only if the fid is not part of the vg in backup_read_vg fn (otherwise it's
	part of the VG we're returning and we definitely don't want to destroy it!).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.446&r2=1.447

--- LVM2/lib/cache/lvmcache.c	2011/03/10 03:03:04	1.105
+++ LVM2/lib/cache/lvmcache.c	2011/03/11 15:08:31	1.106
@@ -627,7 +627,7 @@
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 
@@ -663,20 +663,21 @@
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
 	      create_config_tree_from_string(fid->fmt->cmd,
-					     vginfo->vgmetadata))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+					     vginfo->vgmetadata)))
+		goto_bad;
 
-	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
+		goto_bad;
 
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
 	return vg;
+
+bad:
+	free_vg(vg);
+	_free_cached_vgmetadata(vginfo);
+	return NULL;
 }
 
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
--- LVM2/lib/format_text/archive.c	2011/03/11 14:45:18	1.42
+++ LVM2/lib/format_text/archive.c	2011/03/11 15:08:32	1.43
@@ -333,7 +333,6 @@
 	log_print("Backup Time:\t%s", ctime(&when));
 
 	free_vg(vg);
-	tf->fmt->ops->destroy_instance(tf);
 }
 
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
--- LVM2/lib/format_text/archiver.c	2011/03/11 14:45:18	1.45
+++ LVM2/lib/format_text/archiver.c	2011/03/11 15:08:32	1.46
@@ -289,7 +289,9 @@
 		break;
 	}
 
-	tf->fmt->ops->destroy_instance(tf);
+	if (!vg)
+		tf->fmt->ops->destroy_instance(tf);
+
 	return vg;
 }
 
@@ -401,6 +403,7 @@
 
 	if (!dm_list_size(&tf->metadata_areas_in_use)) {
 		log_error(INTERNAL_ERROR "No in use metadata areas to write.");
+		tf->fmt->ops->destroy_instance(tf);
 		return 0;
 	}
 
--- LVM2/lib/metadata/metadata.c	2011/03/11 15:06:13	1.446
+++ LVM2/lib/metadata/metadata.c	2011/03/11 15:08:32	1.447
@@ -2647,7 +2647,7 @@
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct physical_volume *pv = NULL;
 
 	lvmcache_label_scan(cmd, 0);


