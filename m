From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:33:16 -0000
Subject: LVM2/lib/metadata pv.c
Message-ID: <20110221123316.6529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:33:16

Modified files:
	lib/metadata   : pv.c 

Log message:
	Fix metadata balance code to work with recent changes in metadata handling
	interface (with the changes in format_instance).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/metadata/pv.c	2010/09/30 20:47:18	1.8
+++ LVM2/lib/metadata/pv.c	2011/02/21 12:33:16	1.9
@@ -248,13 +248,17 @@
 {
 	struct lvmcache_info *info;
 	struct metadata_area *mda, *vg_mda, *tmda;
-	struct dm_list *vg_mdas_in_use, *vg_mdas_ignored;
+	struct dm_list *mdas_in_use, *mdas_ignored, *mdas_to_change;
 
 	if (!(info = info_from_pvid((const char *)&pv->id.uuid, 0)))
 		return_0;
 
+	mdas_in_use = &pv->fid->metadata_areas_in_use;
+	mdas_ignored = &pv->fid->metadata_areas_ignored;
+	mdas_to_change = mda_ignored ? mdas_in_use : mdas_ignored;
+
 	if (is_orphan(pv)) {
-		dm_list_iterate_items(mda, &info->mdas)
+		dm_list_iterate_items(mda, mdas_to_change)
 			mda_set_ignored(mda, mda_ignored);
 		return 1;
 	}
@@ -279,19 +283,19 @@
 	 * list, ensuring the new state will get written to disk in the
 	 * vg_write() path.
 	 */
-	vg_mdas_in_use = &pv->vg->fid->metadata_areas_in_use;
-	vg_mdas_ignored = &pv->vg->fid->metadata_areas_ignored;
-
+	/* FIXME: Try not to update the cache here! Also, try to iterate over
+	 *	  PV mdas only using the format instance's index somehow
+	 * 	  (i.e. try to avoid using mda_locn_match call). */
 	dm_list_iterate_items(mda, &info->mdas) {
 		if (mda_is_ignored(mda) && !mda_ignored)
 			/* Changing an ignored mda to one in_use requires moving it */
-			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored)
+			dm_list_iterate_items_safe(vg_mda, tmda, mdas_ignored)
 				if (mda_locns_match(mda, vg_mda)) {
 					mda_set_ignored(vg_mda, mda_ignored);
-					dm_list_move(vg_mdas_in_use, &vg_mda->list);
+					dm_list_move(mdas_in_use, &vg_mda->list);
 				}
 
-		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use)
+		dm_list_iterate_items_safe(vg_mda, tmda, mdas_in_use)
 			if (mda_locns_match(mda, vg_mda))
 				/* Don't move mda: needs writing to disk. */
 				mda_set_ignored(vg_mda, mda_ignored);


