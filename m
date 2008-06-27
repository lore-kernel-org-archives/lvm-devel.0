From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2008 15:18:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/c ...
Message-ID: <20080627151833.3951.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-27 15:18:32

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/cache      : lvmcache.c 

Log message:
	Fix up cache for PVs without mdas after consistent VG metadata is processed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.919&r2=1.920
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2008/06/26 23:05:10	1.919
+++ LVM2/WHATS_NEW	2008/06/27 15:18:29	1.920
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Fix up cache for PVs without mdas after consistent VG metadata is processed.
   Update validation of safe mirror log type conversions in lvconvert.
   Fix lvconvert to disallow snapshot and mirror combinations.
   Fix reporting of LV fields alongside unallocated PV segments.
--- LVM2/lib/metadata/metadata.c	2008/06/24 20:10:31	1.183
+++ LVM2/lib/metadata/metadata.c	2008/06/27 15:18:31	1.184
@@ -1488,8 +1488,10 @@
 	const struct format_type *fmt;
 	struct volume_group *vg, *correct_vg = NULL;
 	struct metadata_area *mda;
+	struct lvmcache_info *info;
 	int inconsistent = 0;
 	int inconsistent_vgid = 0;
+	int inconsistent_pvs = 0;
 	unsigned use_precommitted = precommitted;
 	struct list *pvids;
 	struct pv_list *pvl, *pvl2;
@@ -1564,6 +1566,44 @@
 
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
+		/*
+		 * If the VG has PVs without mdas, they may still be
+		 * orphans in the cache: update the cache state here.
+		 */
+		if (!inconsistent &&
+		    list_size(&correct_vg->pvs) > list_size(pvids)) {
+			list_iterate_items(pvl, &correct_vg->pvs) {
+				if (!pvl->pv->dev) {
+					inconsistent_pvs = 1;
+					break;
+				}
+
+				if (str_list_match_item(pvids, pvl->pv->dev->pvid))
+					continue;
+
+				/*
+				 * PV not marked as belonging to this VG in cache.
+				 * Check it's an orphan without metadata area.
+				 */
+				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
+				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname) ||
+				   list_size(&info->mdas)) {
+					inconsistent_pvs = 1;
+					break;
+				}
+			}
+
+			/* If the check passed, let's update VG and recalculate pvids */
+			if (!inconsistent_pvs) {
+				log_debug("Updating cache for PVs without mdas "
+					  "in VG %s.", vgname);
+				lvmcache_update_vg(correct_vg, use_precommitted);
+
+				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+					return_NULL;
+			}
+		}
+
 		if (list_size(&correct_vg->pvs) != list_size(pvids)) {
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
--- LVM2/lib/cache/lvmcache.c	2008/06/11 11:02:05	1.58
+++ LVM2/lib/cache/lvmcache.c	2008/06/27 15:18:31	1.59
@@ -845,6 +845,7 @@
 {
 	struct lvmcache_vginfo *vginfo, *primary_vginfo, *orphan_vginfo;
 	struct lvmcache_info *info2, *info3;
+	char mdabuf[32];
 	// struct lvmcache_vginfo  *old_vginfo, *next;
 
 	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
@@ -914,11 +915,16 @@
 				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
 				_drop_vginfo(info2, primary_vginfo);	
 				_vginfo_attach_info(orphan_vginfo, info2);
-				log_debug("lvmcache: %s: now in VG %s%s%s%s",
+				if (info2->mdas.n)
+					sprintf(mdabuf, " with %u mdas",
+						list_size(&info2->mdas));
+				else
+					mdabuf[0] = '\0';
+				log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
 					  dev_name(info2->dev),
 					  vgname, orphan_vginfo->vgid[0] ? " (" : "",
 					  orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
-					  orphan_vginfo->vgid[0] ? ")" : "");
+					  orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
 		}
 
 		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host,
@@ -947,13 +953,17 @@
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = fmt;
 
-	if (info)
-		log_debug("lvmcache: %s: now in VG %s%s%s%s",
+	if (info) {
+		if (info->mdas.n)
+			sprintf(mdabuf, " with %u mdas", list_size(&info->mdas));
+		else
+			mdabuf[0] = '\0';
+		log_debug("lvmcache: %s: now in VG %s%s%s%s%s",
 			  dev_name(info->dev),
 			  vgname, vginfo->vgid[0] ? " (" : "",
 			  vginfo->vgid[0] ? vginfo->vgid : "",
-			  vginfo->vgid[0] ? ")" : "");
-	else
+			  vginfo->vgid[0] ? ")" : "", mdabuf);
+	} else
 		log_debug("lvmcache: initialised VG %s", vgname);
 
 	return 1;


