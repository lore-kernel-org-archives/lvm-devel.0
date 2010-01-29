From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:51 -0500
Subject: [PATCH 01/12] Add copy constructor for struct metadata_area.
In-Reply-To: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Clean up cut&paste code with proper copy constructor.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   74 ++++++++++++++++++++---------------------
 1 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2c75054..225b596 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1548,15 +1548,40 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 	return 1;
 }
 
+/*
+ * Copy constructor for a metadata_area.
+ */
+static struct metadata_area *_mda_copy(struct dm_pool *mem,
+				       struct metadata_area *mda)
+{
+	struct metadata_area *mda_new;
+	struct mda_context *mdac, *mdac_new;
+
+	if (!(mda_new = dm_pool_alloc(mem, sizeof(*mda_new)))) {
+		log_error("metadata_area allocation failed");
+		return NULL;
+	}
+	/* FIXME: this should be per-mda instance */
+	mdac = (struct mda_context *) mda->metadata_locn;
+	if (!(mdac_new = dm_pool_alloc(mem, sizeof(*mdac_new)))) {
+		log_error("metadata_area allocation failed");
+		return NULL;
+	}
+	memcpy(mda_new, mda, sizeof(*mda));
+	memcpy(mdac_new, mdac, sizeof(*mdac));
+	mda_new->metadata_locn = mdac_new;
+	return mda_new;
+}
+
+
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		    struct physical_volume *pv, struct dm_list *mdas,
 		    int scan_label_only)
 {
+	struct metadata_area *mda, *mda_new;
 	struct label *label;
 	struct device *dev;
 	struct lvmcache_info *info;
-	struct metadata_area *mda, *mda_new;
-	struct mda_context *mdac, *mdac_new;
 
 	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
 		return_0;
@@ -1573,18 +1598,9 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 
 	/* Add copy of mdas to supplied list */
 	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = (struct mda_context *) mda->metadata_locn;
-		if (!(mda_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda_new)))) {
-			log_error("metadata_area allocation failed");
-			return 0;
-		}
-		if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac_new)))) {
-			log_error("metadata_area allocation failed");
+		mda_new = _mda_copy(fmt->cmd->mem, mda);
+		if (!mda_new)
 			return 0;
-		}
-		memcpy(mda_new, mda, sizeof(*mda));
-		memcpy(mdac_new, mdac, sizeof(*mdac));
-		mda_new->metadata_locn = mdac_new;
 		dm_list_add(mdas, &mda_new->list);
 	}
 
@@ -1672,7 +1688,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 		     struct physical_volume *pv, struct volume_group *vg)
 {
 	struct metadata_area *mda, *mda_new, *mda2;
-	struct mda_context *mdac, *mdac_new, *mdac2;
+	struct mda_context *mdac, *mdac2;
 	struct dm_list *pvmdas;
 	struct lvmcache_info *info;
 	int found;
@@ -1718,18 +1734,11 @@ static int _text_pv_setup(const struct format_type *fmt,
 				if (found)
 					continue;
 
-				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new))))
+				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				if (!mda_new)
 					return_0;
-
-				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new))))
-					return_0;
-				/* FIXME multiple dev_areas inside area */
-				memcpy(mda_new, mda, sizeof(*mda));
-				memcpy(mdac_new, mdac, sizeof(*mdac));
-				mda_new->metadata_locn = mdac_new;
 				dm_list_add(mdas, &mda_new->list);
+				/* FIXME multiple dev_areas inside area */
 			}
 		}
 
@@ -1815,7 +1824,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 	struct format_instance *fid;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda, *mda_new;
-	struct mda_context *mdac, *mdac_new;
+	struct mda_context *mdac;
 	struct dir_list *dl;
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list, *mdas;
@@ -1892,21 +1901,10 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 		dm_list_iterate_items(info, &vginfo->infos) {
 			mdas = &info->mdas;
 			dm_list_iterate_items(mda, mdas) {
-				mdac =
-				    (struct mda_context *) mda->metadata_locn;
-
 				/* FIXME Check it holds this VG */
-				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new))))
-					return_NULL;
-
-				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new))))
+				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				if (!mda_new)
 					return_NULL;
-				/* FIXME multiple dev_areas inside area */
-				memcpy(mda_new, mda, sizeof(*mda));
-				memcpy(mdac_new, mdac, sizeof(*mdac));
-				mda_new->metadata_locn = mdac_new;
 				dm_list_add(&fid->metadata_areas, &mda_new->list);
 			}
 		}
-- 
1.6.0.6


