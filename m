From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:37:55 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100628203755.18705.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:37:54

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Implement _vg_adjust_ignored_mdas and call from vg_write() path.
	
	Compare the value of the newly added vg_mda_copies field
	(--vgmetadatacopies parameter) with the current count of
	in-use mdas and ignoring or unignoring mdas as necessary to
	get to the target count.  Also, as a safety check before
	returning, ensure we have at least one mda enabled.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.359&r2=1.360

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:36:56	1.359
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:37:54	1.360
@@ -58,6 +58,8 @@
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
+static int _vg_adjust_ignored_mdas(struct volume_group *vg);
+
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
@@ -989,6 +991,93 @@
 	return 1;
 }
 
+static int _vg_ignore_mdas(struct volume_group *vg, uint32_t num_to_ignore)
+{
+	struct metadata_area *mda;
+
+	if (!num_to_ignore)
+		return 1;
+	/* FIXME: flip bits on random mdas */
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (!mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 1);
+			num_to_ignore--;
+		}
+		if (!num_to_ignore)
+			return 1;
+	}
+	log_error("Unable to find %"PRIu32" metadata areas to ignore "
+		  "on volume group %s", num_to_ignore, vg->name);
+	return 0;
+}
+
+static int _vg_unignore_mdas(struct volume_group *vg, uint32_t num_to_unignore)
+{
+	struct metadata_area *mda, *tmda;
+
+	if (!num_to_unignore)
+		return 1;
+	/* FIXME: flip bits on random mdas */
+	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored) {
+		if (mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 0);
+			dm_list_move(&vg->fid->metadata_areas_in_use,
+				     &mda->list);
+			num_to_unignore--;
+		}
+		if (!num_to_unignore)
+			return 1;
+	}
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (mda_is_ignored(mda)) {
+			mda_set_ignored(mda, 0);
+			num_to_unignore--;
+		}
+		if (!num_to_unignore)
+			return 1;
+	}
+	log_error("Unable to find %"PRIu32" metadata areas to un-ignore "
+		  "on volume group %s", num_to_unignore, vg->name);
+	return 0;
+}
+
+static int _vg_adjust_ignored_mdas(struct volume_group *vg)
+{
+	uint32_t mda_copies, count;
+	int ret = 1;
+
+	mda_copies = vg_mda_used_count(vg);
+	if (!vg->mda_copies)
+		goto skip_adjust;
+
+	if (mda_copies > vg->mda_copies) {
+		ret = _vg_ignore_mdas(vg, mda_copies - vg->mda_copies);
+	} else if (mda_copies < vg->mda_copies) {
+		/* not an error to have vg_mda_count larger than total mdas */
+		if (vg->mda_copies >= vg_mda_count(vg))
+			count = vg_mda_count(vg) - vg_mda_used_count(vg);
+		else
+			count = vg->mda_copies - mda_copies;
+		ret = _vg_unignore_mdas(vg, count);
+	}
+	if (!ret)
+		return ret;
+
+skip_adjust:
+	/*
+	 * Ensure at least one mda in use.
+	 * FIXME: check size of fid->metadata_areas_in_use; reason is because
+	 * of how pv_setup works in the case of a pv with 2 mdas, one ignored
+	 * and another not ignored; function needs refactoring to simplify the
+	 * below check and retain correctness.
+	 */
+	if (!dm_list_size(&vg->fid->metadata_areas_in_use) ||
+	    !vg_mda_used_count(vg)) {
+		ret = _vg_unignore_mdas(vg, 1);
+	}
+	return ret;
+}
+
 uint32_t vg_mda_copies(const struct volume_group *vg)
 {
 	return vg->mda_copies;
@@ -2378,6 +2467,7 @@
 		return 0;
 	}
 
+	_vg_adjust_ignored_mdas(vg);
 
 	if (dm_list_empty(&vg->fid->metadata_areas_in_use)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");


