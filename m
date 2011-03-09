From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:39 +0100
Subject: [PATCH 7/7] Switch over to format instance mempool use where possible.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-8-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We used cmd mempool before in format instances, now we have our own
mempool...

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format1/format1.c         |    3 +--
 lib/format_pool/format_pool.c |    3 +--
 lib/format_text/format-text.c |   25 ++++++++++++-------------
 lib/metadata/metadata.c       |    4 ++--
 4 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 3961b67..c2df5cc 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -534,10 +534,9 @@ static struct format_instance *_format1_create_instance(const struct format_type
 		return_NULL;
 
 	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
 		log_error("Unable to allocate metadata area structure "
 			  "for lvm1 format");
-		dm_pool_free(fmt->cmd->mem, fid);
 		goto bad;
 	}
 
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 53b4171..ff811fc 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -260,10 +260,9 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 		return_NULL;
 
 	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
 		log_error("Unable to allocate metadata area structure "
 			  "for pool format");
-		dm_pool_free(fmt->cmd->mem, fid);
 		goto bad;
 	}
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 789c984..f4ff9d3 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1659,7 +1659,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 
 			/* Be sure it's not already in VG's format instance! */
 			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index)) {
-				pv_mda_copy = mda_copy(vg->fid->fmt->cmd->mem, pv_mda);
+				pv_mda_copy = mda_copy(vg->fid->mem, pv_mda);
 				fid_add_mda(vg->fid, pv_mda_copy, pvid, ID_LEN, mda_index);
 			}
 		}
@@ -1727,14 +1727,14 @@ static int _create_pv_text_instance(struct format_instance *fid,
 	struct lvmcache_info *info;
 
 	if (!(fid_pv_tc = (struct text_fid_pv_context *)
-			dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*fid_pv_tc)))) {
+			dm_pool_zalloc(fid->mem, sizeof(*fid_pv_tc)))) {
 		log_error("Couldn't allocate text_fid_pv_context.");
 		return 0;
 	}
 	fid_pv_tc->label_sector = -1;
 	fid->private = (void *) fid_pv_tc;
 
-	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->fmt->cmd->mem,
+	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->mem,
 					FMT_TEXT_MAX_MDAS_PER_PV *
 					sizeof(struct metadata_area *)))) {
 		log_error("Couldn't allocate format instance metadata index.");
@@ -1810,7 +1810,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 	const char *vg_name, *vg_id;
 
 	if (!(fidtc = (struct text_fid_context *)
-			dm_pool_zalloc(fid->fmt->cmd->mem,sizeof(*fidtc)))) {
+			dm_pool_zalloc(fid->mem, sizeof(*fidtc)))) {
 		log_error("Couldn't allocate text_fid_context.");
 		return 0;
 	}
@@ -1819,10 +1819,10 @@ static int _create_vg_text_instance(struct format_instance *fid,
 	fid->private = (void *) fidtc;
 
 	if (type & FMT_INSTANCE_PRIVATE_MDAS) {
-		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+		if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 			return_0;
 		mda->ops = &_metadata_text_file_backup_ops;
-		mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, fic->context.private);
+		mda->metadata_locn = _create_text_context(fid->mem, fic->context.private);
 		mda->status = 0;
 		fid->metadata_areas_index.hash = NULL;
 		fid_add_mda(fid, mda, NULL, 0, 0);
@@ -1844,12 +1844,12 @@ static int _create_vg_text_instance(struct format_instance *fid,
 					return 0;
 				}
 
-				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 					return_0;
 				mda->ops = &_metadata_text_file_ops;
 				tc.path_live = path;
 				tc.path_edit = tc.desc = NULL;
-				mda->metadata_locn = _create_text_context(fid->fmt->cmd->mem, &tc);
+				mda->metadata_locn = _create_text_context(fid->mem, &tc);
 				mda->status = 0;
 				fid_add_mda(fid, mda, NULL, 0, 0);
 			}
@@ -1860,10 +1860,10 @@ static int _create_vg_text_instance(struct format_instance *fid,
 				if (!_raw_holds_vgname(fid, &rl->dev_area, vg_name))
 					continue;
 
-				if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
+				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
 					return_0;
 
-				if (!(mdac = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mdac))))
+				if (!(mdac = dm_pool_zalloc(fid->mem, sizeof(*mdac))))
 					return_0;
 				mda->metadata_locn = mdac;
 				/* FIXME Allow multiple dev_areas inside area */
@@ -1911,12 +1911,12 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 					  pv->fmt->name);
 	}
 
-	if (!(mda = dm_malloc(sizeof(struct metadata_area)))) {
+	if (!(mda = dm_pool_zalloc(pv->fid->mem, sizeof(struct metadata_area)))) {
 		log_error("struct metadata_area allocation failed");
 		return 0;
 	}
 
-	if (!(mdac = dm_malloc(sizeof(struct mda_context)))) {
+	if (!(mdac = dm_pool_zalloc(pv->fid->mem, sizeof(struct mda_context)))) {
 		log_error("struct mda_context allocation failed");
 		dm_free(mda);
 		return 0;
@@ -2243,7 +2243,6 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 					  _create_pv_text_instance(fid, fic))
 		return fid;
 
-	dm_pool_free(fmt->cmd->mem, fid);
 	dm_pool_destroy(fid->mem);
 	return NULL;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c6a0b27..c3b7785 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4041,7 +4041,7 @@ struct format_instance *alloc_fid(const struct format_type *fmt,
 	if (!(mem = dm_pool_create("format_instance", 1024)))
 		return_NULL;
 
-	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
+	if (!(fid = dm_pool_zalloc(mem, sizeof(*fid)))) {
 		log_error("Couldn't allocate format_instance object.");
 		goto bad;
 	}
@@ -4133,7 +4133,7 @@ int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
 	unsigned mda_index = 0;
 
 	dm_list_iterate_items(mda, mdas) {
-		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
+		mda_new = mda_copy(fid->mem, mda);
 		if (!mda_new)
 			return_0;
 		fid_remove_mda(fid, NULL, key, key_len, mda_index);
-- 
1.7.4


