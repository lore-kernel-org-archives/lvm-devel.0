From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:32:00 -0000
Subject: LVM2/lib format_text/format-text.c metadata/me ...
Message-ID: <20100628203200.14575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:31:59

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add mda location specific mda_copy constructor.
	
	Because of the way mdas are handled internally, where a PV in a VG
	has mdas on both info->mdas and vg->fid->metadata_areas list, we
	need a location independent copy constructor for struct
	metadata_area.  Break up the existing format-text specific copy
	constructor into a format independent piece and a format dependent
	piece.
	
	This function is necessary to properly implement pv_set_mda_ignored().
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.348&r2=1.349
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.207&r2=1.208

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:31:38	1.129
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:31:59	1.130
@@ -1622,32 +1622,20 @@
 }
 
 /*
- * Copy constructor for a metadata_area.
+ * Copy constructor for a metadata_locn.
  */
-static struct metadata_area *_mda_copy(struct dm_pool *mem,
-				       struct metadata_area *mda)
+static void *_metadata_locn_copy_raw(struct dm_pool *mem, void *metadata_locn)
 {
-	struct metadata_area *mda_new;
 	struct mda_context *mdac, *mdac_new;
 
-	if (!(mda_new = dm_pool_alloc(mem, sizeof(*mda_new)))) {
-		log_error("metadata_area allocation failed");
-		return NULL;
-	}
-	/* FIXME: Should have a per-format constructor here */
-	mdac = (struct mda_context *) mda->metadata_locn;
+	mdac = (struct mda_context *) metadata_locn;
 	if (!(mdac_new = dm_pool_alloc(mem, sizeof(*mdac_new)))) {
 		log_error("mda_context allocation failed");
-		dm_pool_free(mem, mda_new);
 		return NULL;
 	}
-	memcpy(mda_new, mda, sizeof(*mda));
 	memcpy(mdac_new, mdac, sizeof(*mdac));
-	mda_new->metadata_locn = mdac_new;
-
-	/* FIXME mda 'list' left invalid here */
 
-	return mda_new;
+	return mdac_new;
 }
 
 
@@ -1675,7 +1663,7 @@
 
 	/* Add copy of mdas to supplied list */
 	dm_list_iterate_items(mda, &info->mdas) {
-		mda_new = _mda_copy(fmt->cmd->mem, mda);
+		mda_new = mda_copy(fmt->cmd->mem, mda);
 		if (!mda_new)
 			return 0;
 		dm_list_add(mdas, &mda_new->list);
@@ -1742,6 +1730,7 @@
 	.vg_precommit = _vg_precommit_raw,
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
+	.mda_metadata_locn_copy = _metadata_locn_copy_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
@@ -1812,7 +1801,7 @@
 				if (found)
 					continue;
 
-				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				mda_new = mda_copy(fmt->cmd->mem, mda);
 				if (!mda_new)
 					return_0;
 				dm_list_add(mdas, &mda_new->list);
@@ -1980,7 +1969,7 @@
 			mdas = &info->mdas;
 			dm_list_iterate_items(mda, mdas) {
 				/* FIXME Check it holds this VG */
-				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				mda_new = mda_copy(fmt->cmd->mem, mda);
 				if (!mda_new)
 					return_NULL;
 				dm_list_add(&fid->metadata_areas, &mda_new->list);
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:31:38	1.348
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:31:59	1.349
@@ -3856,6 +3856,32 @@
 }
 
 /*
+ * Copy constructor for a metadata_area.
+ */
+struct metadata_area *mda_copy(struct dm_pool *mem,
+			       struct metadata_area *mda)
+{
+	struct metadata_area *mda_new;
+
+	if (!(mda_new = dm_pool_alloc(mem, sizeof(*mda_new)))) {
+		log_error("metadata_area allocation failed");
+		return NULL;
+	}
+	memcpy(mda_new, mda, sizeof(*mda));
+	if (mda->ops->mda_metadata_locn_copy && mda->metadata_locn) {
+		mda_new->metadata_locn =
+			mda->ops->mda_metadata_locn_copy(mem, mda->metadata_locn);
+		if (!mda_new->metadata_locn) {
+			dm_pool_free(mem, mda_new);
+			return NULL;
+		}
+	}
+
+	/* FIXME mda 'list' left invalid here */
+
+	return mda_new;
+}
+/*
  * This function provides a way to answer the question on a format specific
  * basis - does the format specfic context of these two metadata areas
  * match?
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:31:38	1.207
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:31:59	1.208
@@ -136,6 +136,11 @@
 			  struct metadata_area * mda);
 
 	/*
+	 * Per location copy constructor.
+	 */
+	void *(*mda_metadata_locn_copy) (struct dm_pool *mem, void *metadata_locn);
+
+	/*
 	 * Returns number of free sectors in given metadata area.
 	 */
 	uint64_t (*mda_free_sectors) (struct metadata_area *mda);
@@ -172,6 +177,8 @@
 	void *metadata_locn;
 	uint32_t flags;
 };
+struct metadata_area *mda_copy(struct dm_pool *mem,
+			       struct metadata_area *mda);
 
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);


