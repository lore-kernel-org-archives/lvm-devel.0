From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 06 Oct 2010 13:32:43 +0200
Subject: [PATCH] Introduce MDA_IGNORABLE metadata status flag to differentiate ignorable mdas from other mdas
Message-ID: <4CAC5E5B.2080403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We don't necessarily have disk-only mdas present and when counting number of
mdas used while making decisions in metadata balance code, we have to count
only the mdas that are ignorable. Otherwise we could end up in an inconsistent
state. For example when using pvchange:

 - setting metadata/dirs in lvm.conf
 - pvcreate /dev/abc
 - vgcreate vg /dev/abc
 - pvchange --metadataignore y /dev/adc

...pvchange shoud not allow disabling the mda since the one that is on /dev/abc
is the only one used on that PV (though we have live copy of that mda in
filesystem's directory).

So we need to make a difference between mdas that are IGNORABLE and the ones
that are not. After a short discussion with Dave, we decided to store this flag
in the metadata_area's status field (previously the "flags" field).

Dave, please double-check me whether this is OK, just for sure...

...

<personal note>

Anyway, this is just one example of the situation where we need to make a
difference for mda based on its type (raw, fs dir, ...). There may be other
situations like this one throughout the mda handling code, like in
_text_pv_setup where we use something like:

         if (mda2->ops != &_metadata_text_raw_ops) ....

First I thought we could possibly store this "mda type" information in the
mda's status field, but then I realized that it would be a violation of the
abstraction that we impose by using the metadata_area structure which is
kind of polymorphic then. So I think we need some better to solve these
problems... There may be other situations in the code where the knowledge
of the metadata type used is needed. Either the code needs a little inspection
whether we can avoid that or the metadata abstractions/interface used needs
a little improvement... (For example, very similar situation is the use of
mda_metadata_locn_offset function that is part of the abstract mda handling
interface - e.g. the "dirs" metadata type does not have any "offset". It's
metadata type specific functionality that belongs to "raw" metadata type
only.)

</personoal note>

Peter
---
 lib/format_text/format-text.c |    2 +-
 lib/format_text/text_label.c  |    1 +
 lib/metadata/metadata.c       |   29 +++++++++++++++++++----------
 lib/metadata/metadata.h       |    3 ++-
 lib/metadata/pv.c             |    6 ++++--
 lib/metadata/pv.h             |    2 +-
 lib/metadata/vg.c             |   11 +++++++----
 lib/metadata/vg.h             |    2 +-
 lib/report/properties.c       |    4 ++--
 lib/report/report.c           |    4 ++--
 tools/vgextend.c              |    6 +++---
 11 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index eee0114..087cc8d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1985,7 +1985,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 			/* FIXME Allow multiple dev_areas inside area */
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
-			mda->status = 0;
+			mda->status = MDA_IGNORABLE;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
 			fid_add_mda(fid, mda);
 		}
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e459cde..97b0b9b 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -311,6 +311,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 			stack;
 			goto close_dev;
 		}
+		mda->status |= MDA_IGNORABLE;
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if (mda_is_ignored(mda)) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a073e82..73244e2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -248,7 +248,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	 * metadata_areas_ignored list if all mdas in the PV are ignored;
 	 * otherwise, we use the non-ignored list.
 	 */
-	if (!pv_mda_used_count(pv))
+	if (!pv_mda_used_count(pv, 0))
 		mdas = &fid->metadata_areas_ignored;
 	else
 		mdas = &fid->metadata_areas_in_use;
@@ -1070,7 +1070,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
 static int _vg_ignore_mdas(struct volume_group *vg, uint32_t num_to_ignore)
 {
 	struct metadata_area *mda;
-	uint32_t mda_used_count = vg_mda_used_count(vg);
+	uint32_t mda_used_count = vg_mda_used_count(vg, 1);
 	dm_bitset_t mda_to_ignore_bs;
 	int r = 1;
 
@@ -1106,7 +1106,7 @@ out:
 static int _vg_unignore_mdas(struct volume_group *vg, uint32_t num_to_unignore)
 {
 	struct metadata_area *mda, *tmda;
-	uint32_t mda_used_count = vg_mda_used_count(vg);
+	uint32_t mda_used_count = vg_mda_used_count(vg, 1);
 	uint32_t mda_count = vg_mda_count(vg);
 	uint32_t mda_free_count = mda_count - mda_used_count;
 	dm_bitset_t mda_to_unignore_bs;
@@ -1153,7 +1153,7 @@ out:
 
 static int _vg_adjust_ignored_mdas(struct volume_group *vg)
 {
-	uint32_t mda_copies_used = vg_mda_used_count(vg);
+	uint32_t mda_copies_used = vg_mda_used_count(vg, 1);
 
 	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED) {
 		/* Ensure at least one mda is in use. */
@@ -2328,7 +2328,7 @@ int vg_write(struct volume_group *vg)
 	if ((vg->fid->fmt->features & FMT_MDAS) && !_vg_adjust_ignored_mdas(vg))
 		return_0;
 
-	if (!vg_mda_used_count(vg)) {
+	if (!vg_mda_used_count(vg, 0)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
 		return 0;
 	}
@@ -3839,7 +3839,7 @@ unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2)
 
 unsigned mda_is_ignored(struct metadata_area *mda)
 {
-	return (mda->status & MDA_IGNORED);
+	return (mda->status & MDA_IGNORABLE && mda->status & MDA_IGNORED);
 }
 
 void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
@@ -3847,6 +3847,15 @@ void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
 	void *locn = mda->metadata_locn;
 	unsigned old_mda_ignored = mda_is_ignored(mda);
 
+	if (!(mda->status & MDA_IGNORABLE)) {
+		log_debug("%s ignored flag for mda %s at offset %" PRIu64
+			  " skipped. Metadata area is not ignorable.",
+			  mda_ignored ? "Setting" : "Clearing",
+			  mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
+			  mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
+		return;
+	}
+
 	if (mda_ignored && !old_mda_ignored)
 		mda->status |= MDA_IGNORED;
 	else if (!mda_ignored && old_mda_ignored)
@@ -3877,13 +3886,13 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 {
 	const char *pv_name = pv_dev_name(pv);
 
-	if (mda_ignored && !pv_mda_used_count(pv)) {
+	if (mda_ignored && !pv_mda_used_count(pv, 1)) {
 		log_error("Metadata areas on physical volume \"%s\" already "
 			  "ignored.", pv_name);
 		return 0;
 	}
 
-	if (!mda_ignored && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
+	if (!mda_ignored && (pv_mda_used_count(pv, 1) == pv_mda_count(pv))) {
 		log_error("Metadata areas on physical volume \"%s\" already "
 			  "marked as in-use.", pv_name);
 		return 0;
@@ -3914,8 +3923,8 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 	    vg_mda_copies(pv->vg) != VGMETADATACOPIES_UNMANAGED) {
 		log_warn("WARNING: Changing preferred number of copies of VG %s "
 			 "metadata from %"PRIu32" to %"PRIu32, pv_vg_name(pv),
-			 vg_mda_copies(pv->vg), vg_mda_used_count(pv->vg));
-		vg_set_mda_copies(pv->vg, vg_mda_used_count(pv->vg));
+			 vg_mda_copies(pv->vg), vg_mda_used_count(pv->vg, 1));
+		vg_set_mda_copies(pv->vg, vg_mda_used_count(pv->vg, 1));
 	}
 
 	return 1;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 8e950a9..2eceb78 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -176,7 +176,8 @@ struct metadata_area_ops {
 				    struct metadata_area *mda2);
 };
 
-#define MDA_IGNORED 0x00000001
+#define MDA_IGNORABLE	0x00000001
+#define MDA_IGNORED	0x00000002
 
 struct metadata_area {
 	struct dm_list list;
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index e5bb9f0..659fea3 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -147,7 +147,7 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
-uint32_t pv_mda_used_count(const struct physical_volume *pv)
+uint32_t pv_mda_used_count(const struct physical_volume *pv, int ignorable_only)
 {
 	struct lvmcache_info *info;
 	struct metadata_area *mda;
@@ -157,6 +157,8 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv)
 	if (!info)
 		return 0;
 	dm_list_iterate_items(mda, &info->mdas) {
+		if (ignorable_only && !(mda->status & MDA_IGNORABLE))
+			continue;
 		if (!mda_is_ignored(mda))
 			used_count++;
 	}
@@ -262,7 +264,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 	/*
 	 * Do not allow disabling of the the last PV in a VG.
 	 */
-	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
+	if (pv_mda_used_count(pv, 1) == vg_mda_used_count(pv->vg, 1)) {
 		log_error("Cannot disable all metadata areas in volume group %s.",
 			  pv->vg->name);
 		return 0;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 07a7819..0172793 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -74,7 +74,7 @@ uint64_t pv_mda_size(const struct physical_volume *pv);
 uint64_t pv_mda_free(const struct physical_volume *pv);
 uint64_t pv_used(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
-uint32_t pv_mda_used_count(const struct physical_volume *pv);
+uint32_t pv_mda_used_count(const struct physical_volume *pv, int ignorable_only);
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 2c73861..16ab882 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -125,7 +125,7 @@ uint32_t vg_mda_count(const struct volume_group *vg)
 		dm_list_size(&vg->fid->metadata_areas_ignored);
 }
 
-uint32_t vg_mda_used_count(const struct volume_group *vg)
+uint32_t vg_mda_used_count(const struct volume_group *vg, int ignorable_only)
 {
        uint32_t used_count = 0;
        struct metadata_area *mda;
@@ -135,9 +135,12 @@ uint32_t vg_mda_used_count(const struct volume_group *vg)
 	 * may have changed from ignored to un-ignored and we need to write
 	 * the state to disk.
 	 */
-       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
-	       if (!mda_is_ignored(mda))
-		       used_count++;
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (ignorable_only && !(mda->status & MDA_IGNORABLE))
+			continue;
+		if (!mda_is_ignored(mda))
+			used_count++;
+	}
 
        return used_count;
 }
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 06f92de..336594f 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -113,7 +113,7 @@ int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
 uint64_t vg_max_lv(const struct volume_group *vg);
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
 uint32_t vg_mda_count(const struct volume_group *vg);
-uint32_t vg_mda_used_count(const struct volume_group *vg);
+uint32_t vg_mda_used_count(const struct volume_group *vg, int ignorable_only);
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
 /*
diff --git a/lib/report/properties.c b/lib/report/properties.c
index bea57b5..88c1f83 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -93,7 +93,7 @@ GET_PV_STR_PROPERTY_FN(pv_tags, pv_tags_dup(pv))
 #define _pv_tags_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set _not_implemented_set
-GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
+GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv, 0))
 #define _pv_mda_used_count_set _not_implemented_set
 
 /* LV */
@@ -177,7 +177,7 @@ GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags_dup(vg))
 #define _vg_tags_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
 #define _vg_mda_count_set _not_implemented_set
-GET_VG_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg, 0)))
 #define _vg_mda_used_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
 #define _vg_mda_free_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 95f4550..2f36973 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -701,7 +701,7 @@ static int _pvmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
 
-	count = pv_mda_used_count(pv);
+	count = pv_mda_used_count(pv, 0);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -725,7 +725,7 @@ static int _vgmdasused_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = vg_mda_used_count(vg);
+	count = vg_mda_used_count(vg, 0);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 81bae18..df4d929 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -75,11 +75,11 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, metadataignore_ARG) &&
 	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
-	    (vg_mda_copies(vg) != vg_mda_used_count(vg))) {
+	    (vg_mda_copies(vg) != vg_mda_used_count(vg, 1))) {
 		log_warn("WARNING: Changing preferred number of copies of VG %s "
 			 "metadata from %"PRIu32" to %"PRIu32, vg_name,
-			 vg_mda_copies(vg), vg_mda_used_count(vg));
-		vg_set_mda_copies(vg, vg_mda_used_count(vg));
+			 vg_mda_copies(vg), vg_mda_used_count(vg, 1));
+		vg_set_mda_copies(vg, vg_mda_used_count(vg, 1));
 	}
 
 	/* ret > 0 */


