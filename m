From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:34:58 -0000
Subject: LVM2/lib cache/lvmcache.c metadata/metadata.c
Message-ID: <20100628203458.16392.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:34:58

Modified files:
	lib/cache      : lvmcache.c 
	lib/metadata   : metadata.c 

Log message:
	Use mdas_empty_or_ignored() in place of checks for empty mda list.
	
	With the addition of ignored mdas, we replace all checks for an empty
	mda list with a new function to look for either an empty mda list or
	ignored mdas.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.353&r2=1.354

--- LVM2/lib/cache/lvmcache.c	2010/05/19 11:52:21	1.91
+++ LVM2/lib/cache/lvmcache.c	2010/06/28 20:34:58	1.92
@@ -1197,7 +1197,8 @@
 	}
 
 	/* If PV without mdas is already in a real VG, don't make it orphan */
-	if (is_orphan_vg(vgname) && info->vginfo && !dm_list_size(&info->mdas) &&
+	if (is_orphan_vg(vgname) && info->vginfo &&
+	    mdas_empty_or_ignored(&info->mdas) &&
 	    !is_orphan_vg(info->vginfo->vgname) && memlock())
 		return 1;
 
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:34:40	1.353
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:34:58	1.354
@@ -1305,7 +1305,7 @@
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv) && !dm_list_size(&mdas)) {
+	if (pv && is_orphan(pv) && mdas_empty_or_ignored(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd))
 			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
@@ -1798,7 +1798,7 @@
 		return NULL;
 	}
 
-	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&mdas)) {
+	if (is_orphan_vg(pv->vg_name) && mdas_empty_or_ignored(&mdas)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
@@ -2722,8 +2722,8 @@
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
 		/*
-		 * If the VG has PVs without mdas, they may still be
-		 * orphans in the cache: update the cache state here.
+		 * If the VG has PVs without mdas, or ignored mdas, they may
+		 * still be orphans in the cache: update the cache state here.
 		 */
 		if (!inconsistent &&
 		    dm_list_size(&correct_vg->pvs) > dm_list_size(pvids)) {
@@ -2738,11 +2738,12 @@
 
 				/*
 				 * PV not marked as belonging to this VG in cache.
-				 * Check it's an orphan without metadata area.
+				 * Check it's an orphan without metadata area
+				 * not ignored.
 				 */
 				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
 				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname) ||
-				   dm_list_size(&info->mdas)) {
+				   !mdas_empty_or_ignored(&info->mdas)) {
 					inconsistent_pvs = 1;
 					break;
 				}
@@ -3128,20 +3129,24 @@
 			return_NULL;
 		}
 		/*
-		 * If an orphan PV has no MDAs it may appear to be an
-		 * orphan until the metadata is read off another PV in
-		 * the same VG.  Detecting this means checking every VG
-		 * by scanning every PV on the system.
+		 * If an orphan PV has no MDAs, or it has MDAs but the
+		 * MDA is ignored, it may appear to be an orphan until
+		 * the metadata is read off another PV in the same VG.
+		 * Detecting this means checking every VG by scanning
+		 * every PV on the system.
 		 */
-		if (!dm_list_size(&info->mdas)) {
+		if (mdas_empty_or_ignored(&info->mdas)) {
 			if (!scan_vgs_for_pvs(cmd)) {
 				log_error("Rescan for PVs without "
 					  "metadata areas failed.");
 				return NULL;
 			}
+			/*
+			 * Ask lvmcache again - we may have a non-orphan
+			 * name now
+			 */
+			vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 		}
-		/* Ask lvmcache again - we may have a non-orphan name now */
-		vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 	}
 	return vgname;
 }


