From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:40 -0400
Subject: [PATCH 09/38] Add mda location specific mda_copy constructor.
In-Reply-To: <1277520789-6808-9-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Because of the way mdas are handled internally, where a PV in a VG
has mdas on both info->mdas and vg->fid->metadata_areas list, we
need a location independent copy constructor for struct
metadata_area.  Break up the existing format-text specific copy
constructor into a format independent piece and a format dependent
piece.

This function is necessary to properly implement pv_set_mda_ignored().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   28 ++++++++++------------------
 lib/metadata/metadata.c       |   25 +++++++++++++++++++++++++
 lib/metadata/metadata.h       |    7 +++++++
 3 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 901fa2d..a3a43ab 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1620,32 +1620,23 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 }
 
 /*
- * Copy constructor for a metadata_area.
+ * Copy constructor for a metadata_locn.
  */
-static struct metadata_area *_mda_copy(struct dm_pool *mem,
-				       struct metadata_area *mda)
+static void *_mda_copy_raw(struct dm_pool *mem,
+			   struct metadata_area *mda)
 {
-	struct metadata_area *mda_new;
 	struct mda_context *mdac, *mdac_new;
 
-	if (!(mda_new = dm_pool_alloc(mem, sizeof(*mda_new)))) {
-		log_error("metadata_area allocation failed");
-		return NULL;
-	}
-	/* FIXME: Should have a per-format constructor here */
 	mdac = (struct mda_context *) mda->metadata_locn;
+	if (!mdac)
+		return NULL;
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
 
 
@@ -1673,7 +1664,7 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 
 	/* Add copy of mdas to supplied list */
 	dm_list_iterate_items(mda, &info->mdas) {
-		mda_new = _mda_copy(fmt->cmd->mem, mda);
+		mda_new = mda_copy(fmt->cmd->mem, mda);
 		if (!mda_new)
 			return 0;
 		dm_list_add(mdas, &mda_new->list);
@@ -1740,6 +1731,7 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.vg_precommit = _vg_precommit_raw,
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
+	.mda_copy = _mda_copy_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
@@ -1810,7 +1802,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 				if (found)
 					continue;
 
-				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				mda_new = mda_copy(fmt->cmd->mem, mda);
 				if (!mda_new)
 					return_0;
 				dm_list_add(mdas, &mda_new->list);
@@ -1978,7 +1970,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 			mdas = &info->mdas;
 			dm_list_iterate_items(mda, mdas) {
 				/* FIXME Check it holds this VG */
-				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				mda_new = mda_copy(fmt->cmd->mem, mda);
 				if (!mda_new)
 					return_NULL;
 				dm_list_add(&fid->metadata_areas, &mda_new->list);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7af3dd2..117bef8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3856,6 +3856,31 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
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
+	if (mda->ops->mda_copy && mda->metadata_locn) {
+		mda_new->metadata_locn = mda->ops->mda_copy(mem, mda);
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
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6f6236f..86314b2 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -136,6 +136,11 @@ struct metadata_area_ops {
 			  struct metadata_area * mda);
 
 	/*
+	 * Per location copy constructor.
+	 */
+	void *(*mda_copy) (struct dm_pool *mem, struct metadata_area *mda);
+
+	/*
 	 * Returns number of free sectors in given metadata area.
 	 */
 	uint64_t (*mda_free_sectors) (struct metadata_area *mda);
@@ -172,6 +177,8 @@ struct metadata_area {
 	void *metadata_locn;
 	uint32_t flags;
 };
+struct metadata_area *mda_copy(struct dm_pool *mem,
+			       struct metadata_area *mda);
 
 int mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);
-- 
1.6.0.6


