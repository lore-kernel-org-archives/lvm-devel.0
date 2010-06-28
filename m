From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:33:45 -0000
Subject: LVM2/lib metadata/metadata-exported.h metadata ...
Message-ID: <20100628203345.15577.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:33:44

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : columns.h report.c 

Log message:
	Define new functions and vgs/pvs fields related to mda ignore.
	
	Define a new pvs field, pv_mda_used_count, and a new vgs field,
	vg_mda_used_count to match the existing pv_mda_count and vg_mda_count.
	These new fields count the number of mdas that have the 'ignored' bit
	clear (they are in use on the PV / VG).  Also define various supporting
	functions to implement the counting as well as setting the ignored
	flag and determining if an mda is ignored.  These high level functions
	call into the lower level location independent mda ignore functions
	defined by earlier patches.
	
	Note that counting ignored mdas in a vg requires traversing both lists
	and checking for the ignored bit on the mda.  The count of 'ignored'
	mdas then is defined by having the bit set, not by which list the mda
	is on.  The list does determine whether LVM actually does read/write to
	the mda, though we must count the bits in order to return accurate numbers
	for the various counts.  Also, pv_mda_set_ignored must search both vg
	lists for ignored mda.  If the state changes and needs to be committed
	to disk, the ignored mda will be on the non-ignored list.
	
	Note also in pv_mda_set_ignored(), we must properly manage the mda lists.
	If we change the ignored state of an mda, we must change any mdas on
	vg->fid->metadata_areas that correspond to this pv.  Also, we may
	need to allocate a copy of the mda, as is done when fid->metadata_areas
	is populated from _vg_read(), if we are un-ignoring an ignored mda.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.351&r2=1.352
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:33:23	1.154
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:33:44	1.155
@@ -863,6 +863,8 @@
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
+uint32_t pv_mda_used_count(const struct physical_volume *pv);
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
 
 uint64_t lv_size(const struct logical_volume *lv);
 
@@ -878,6 +880,7 @@
 uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
+uint32_t vg_mda_used_count(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:33:23	1.351
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:33:44	1.352
@@ -3955,6 +3955,83 @@
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
+uint32_t pv_mda_used_count(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	uint32_t used_count=0;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return 0;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (!mda_is_ignored(mda))
+			used_count++;
+	}
+	return used_count;
+}
+
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *vg_mda, *tmda;
+	struct dm_list *vg_mdas_in_use, *vg_mdas_ignored;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return_0;
+
+	if (is_orphan(pv)) {
+		dm_list_iterate_items(mda, &info->mdas) {
+			mda_set_ignored(mda, ignored);
+		}
+		return 1;
+	}
+
+	/*
+	 * Do not allow disabling of the the last PV in a VG.
+	 */
+	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
+		log_error("Cannot disable metadata - volume group "
+			  "needs at least one physical volume with "
+			  "metadata areas in use.\n");
+		return 0;
+	}
+
+	/*
+	 * Non-orphan case is more complex.
+	 * If the PV's mdas are ignored, and we wish to un-ignore,
+	 * we clear the bit and move them from the ignored mda list to the
+	 * in_use list, ensuring the new state will get written to disk
+	 * in the vg_write() path.
+	 * If the PV's mdas are not ignored, and we are setting
+	 * them to ignored, we set the bit but leave them on the in_use
+	 * list, ensuring the new state will get written to disk in the
+	 * vg_write() path.
+	 */
+	vg_mdas_in_use = &pv->vg->fid->metadata_areas_in_use;
+	vg_mdas_ignored = &pv->vg->fid->metadata_areas_ignored;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (mda_is_ignored(mda) && !ignored) {
+			/* Changing an ignored mda to one in_use requires moving it */
+			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored) {
+				if (mda_locns_match(mda, vg_mda)) {
+					mda_set_ignored(vg_mda, ignored);
+					dm_list_move(vg_mdas_in_use, &vg_mda->list);
+				}
+			}
+		}
+		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use) {
+			if (mda_locns_match(mda, vg_mda)) {
+				mda_set_ignored(vg_mda, ignored);
+				/* don't move mda - needs written to disk */
+			}
+		}
+		mda_set_ignored(mda, ignored);
+	}
+	return 1;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
@@ -4007,7 +4084,30 @@
 
 uint32_t vg_mda_count(const struct volume_group *vg)
 {
-	return dm_list_size(&vg->fid->metadata_areas_in_use);
+	return dm_list_size(&vg->fid->metadata_areas_in_use) +
+		dm_list_size(&vg->fid->metadata_areas_ignored);
+}
+
+uint32_t vg_mda_used_count(const struct volume_group *vg)
+{
+       uint32_t used_count = 0;
+       struct metadata_area *mda;
+
+	/*
+	 * Ignored mdas could be on either list - the reason being the state
+	 * may have changed from ignored to un-ignored and we need to write
+	 * the state to disk.
+	 */
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+	       if (!mda_is_ignored(mda))
+		       used_count++;
+       }
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_ignored) {
+	       if (!mda_is_ignored(mda))
+		       used_count++;
+       }
+
+       return used_count;
 }
 
 uint64_t lv_size(const struct logical_volume *lv)
--- LVM2/lib/report/columns.h	2010/06/23 12:32:08	1.39
+++ LVM2/lib/report/columns.h	2010/06/28 20:33:44	1.40
@@ -93,6 +93,7 @@
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
+FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, "pv_mda_used_count", "Number of metadata areas in use on this device.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -112,6 +113,7 @@
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
+FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, "vg_mda_used_count", "Number of metadata areas in use on this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
--- LVM2/lib/report/report.c	2010/06/28 20:33:23	1.119
+++ LVM2/lib/report/report.c	2010/06/28 20:33:44	1.120
@@ -880,6 +880,19 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _pvmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	uint32_t count;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+
+	count = pv_mda_used_count(pv);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -892,6 +905,18 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_used_count(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)


