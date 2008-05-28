From: agk@sourceware.org <agk@sourceware.org>
Date: 28 May 2008 22:27:48 -0000
Subject: LVM2 lib/cache/lvmcache.c lib/device/dev-cache ...
Message-ID: <20080528222748.352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-28 22:27:47

Modified files:
	lib/cache      : lvmcache.c 
	lib/device     : dev-cache.c 
	.              : WHATS_NEW 

Log message:
	Avoid spurious duplicate VG messages referring to VGs that are gone.
	(untested)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.876&r2=1.877

--- LVM2/lib/cache/lvmcache.c	2008/05/19 19:49:56	1.51
+++ LVM2/lib/cache/lvmcache.c	2008/05/28 22:27:47	1.52
@@ -31,6 +31,7 @@
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
 static struct list _vginfos;
+static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
@@ -220,6 +221,9 @@
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
+	if (!vginfo)
+		return;
+
 	info->vginfo = vginfo;
 	list_add(&vginfo->infos, &info->list);
 }
@@ -361,6 +365,18 @@
 	return 1;
 }
 
+/* vginfo is invalid if it does not contain at least one valid info */
+static int _vginfo_is_invalid(struct lvmcache_vginfo *vginfo)
+{
+	struct lvmcache_info *info;
+
+	list_iterate_items(info, &vginfo->infos)
+		if (_info_is_valid(info))
+			return 0;
+
+	return 1;
+}
+
 /*
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
@@ -407,7 +423,6 @@
 	struct device *dev;
 	struct format_type *fmt;
 
-	static int _scanning_in_progress = 0;
 	int r = 0;
 
 	/* Avoid recursion when a PVID can't be found! */
@@ -604,12 +619,14 @@
 
 	_free_cached_vgmetadata(vginfo);
 
-	dm_hash_remove(_vgname_hash, vginfo->vgname);
-	if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
-					    vginfo->next)) {
-		log_error("_vgname_hash re-insertion for %s failed",
-			  vginfo->vgname);
-		r = 0;
+	if (vginfo_from_vgname(vginfo->vgname, NULL) == vginfo) {
+		dm_hash_remove(_vgname_hash, vginfo->vgname);
+		if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
+						    vginfo->next)) {
+			log_error("_vgname_hash re-insertion for %s failed",
+				  vginfo->vgname);
+			r = 0;
+		}
 	}
 
 	if (vginfo->vgname)
@@ -801,7 +818,8 @@
 				   uint32_t vgstatus, const char *creation_host,
 				   const struct format_type *fmt)
 {
-	struct lvmcache_vginfo *vginfo, *primary_vginfo;
+	struct lvmcache_vginfo *vginfo, *primary_vginfo, *orphan_vginfo;
+	struct lvmcache_info *info2, *info3;
 	// struct lvmcache_vginfo  *old_vginfo, *next;
 
 	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
@@ -860,7 +878,24 @@
 			return 0;
 		}
 		list_init(&vginfo->infos);
-		primary_vginfo = vginfo_from_vgname(vgname, NULL);
+
+		/*
+		 * If we're scanning and there's an invalidated entry, remove it.
+		 * Otherwise we risk bogus warnings of duplicate VGs.
+		 */
+		while ((primary_vginfo = vginfo_from_vgname(vgname, NULL)) &&
+		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
+			list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
+				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+				_drop_vginfo(info2, primary_vginfo);	
+				_vginfo_attach_info(orphan_vginfo, info2);
+				log_debug("lvmcache: %s: now in VG %s%s%s%s",
+					  dev_name(info2->dev),
+					  vgname, orphan_vginfo->vgid[0] ? " (" : "",
+					  orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
+					  orphan_vginfo->vgid[0] ? ")" : "");
+		}
+
 		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host,
 				    primary_vginfo)) {
 			dm_free(vginfo->vgname);
--- LVM2/lib/device/dev-cache.c	2008/01/30 13:59:58	1.52
+++ LVM2/lib/device/dev-cache.c	2008/05/28 22:27:47	1.53
@@ -687,7 +687,8 @@
 			continue;
 		}
 
-		log_error("Aborting - please provide new pathname for what "
+		/* Scanning issues this inappropriately sometimes. */
+		log_debug("Aborting - please provide new pathname for what "
 			  "used to be %s", name);
 		return NULL;
 	}
--- LVM2/WHATS_NEW	2008/05/21 14:10:11	1.876
+++ LVM2/WHATS_NEW	2008/05/28 22:27:47	1.877
@@ -6,6 +6,9 @@
 
 Version 2.02.37 - 
 =================================
+  Avoid spurious duplicate VG messages referring to VGs that are gone.
+  Drop dev_name_confirmed error message to debug level.
+  Fix setpriority error message to signed int.
   Temporarily disable dmeventd mirror monitoring during lvchange --resync.
   Refactor some vginfo manipulation code.
   Add assertions to trap deprecated P_ and V_ lock usage.


