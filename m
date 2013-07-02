From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:38 +0000 (UTC)
Subject: master - lvm2app: Add thinp snapshot functionality
Message-ID: <20130702192638.3156960FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49e3eecc33dbe0a47d8dcdbf225ddd52a8a6b75d
Commit:        49e3eecc33dbe0a47d8dcdbf225ddd52a8a6b75d
Parent:        2a3472b2b34d2ef82cc04eb89bd29dfb456e2d47
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jun 6 16:40:51 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lvm2app: Add thinp snapshot functionality

Added parameter object constructor for thinp and
changed the shapshot function to use it.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |   21 +++++++++++-
 liblvm/lvm_lv.c  |  100 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 88 insertions(+), 33 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 65dc340..f4475c0 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1538,7 +1538,26 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 			LVM_THIN_DISCARDS_PASSDOWN)
 
 
-
+/**
+ * Creates the snapshot parameter passing object for the specified lv.
+ *
+ * \param	lv
+ * The logical volume to snapshot
+ *
+ * \param	snap_name
+ * Name of snapshot
+ *
+ * \param	max_snap_size
+ * Used for old snap shots max size, set to zero for thinp
+ *
+ * \return
+ * Valid lv_create_params pointer on success, else NULL on error.
+ * Note: Memory is associated with the vg, it will get reclaimed when vg is
+ * closed.
+ */
+lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+													const char *snap_name,
+													uint64_t max_snap_size);
 /**
  * Get the specific value of a lv create parameter by name
  *
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 9f59210..081c73e 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -347,41 +347,16 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	return 0;
 }
 
-lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)
+lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
+						uint64_t max_snap_size)
 {
-	struct lvcreate_params lp = { 0 };
-	uint64_t extents = 0;
-	uint64_t size = 0;
-	struct lv_list *lvl = NULL;
-
-	if (vg_read_error(lv->vg))
-		return NULL;
-	if (!vg_check_write_mode(lv->vg))
-		return NULL;
-
-	size = max_snap_size >> SECTOR_SHIFT;
+	struct lvm_lv_create_params *lvcp = NULL;
 
-	if (!(extents = extents_from_size(lv->vg->cmd, size,
-					  lv->vg->extent_size))) {
-		log_error("Unable to create LV snapshot without size.");
-		return NULL;
+	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
+	if (lvcp) {
+		return lvm_lv_create(lvcp);
 	}
-
-	_lv_set_default_params(&lp, lv->vg, snap_name, extents);
-
-	/* Fill out required default input values */
-	lp.snapshot = 1;
-	lp.segtype = _get_segtype(lv->vg->cmd);
-	lp.stripes = 1;
-	lp.origin = lv->name;
-
-	if (!lp.segtype)
-		return_NULL;
-	if (!lv_create_single(lv->vg, &lp))
-		return_NULL;
-	if (!(lvl = find_lv_in_vg(lv->vg, snap_name)))
-		return NULL;
-	return (lv_t) lvl->lv;
+	return NULL;
 }
 
 /* Set defaults for thin pool specific LV parameters */
@@ -496,6 +471,67 @@ static void _lv_set_thin_params(struct lvcreate_params *lp,
 	lp->stripes = 1;
 }
 
+lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+													const char *snap_name,
+													uint64_t max_snap_size)
+{
+	uint64_t size = 0;
+	uint64_t extents = 0;
+	struct lvm_lv_create_params *lvcp = NULL;
+
+	if (vg_read_error(lv->vg)) {
+		return NULL;
+	}
+
+	if (!vg_check_write_mode(lv->vg))
+			return NULL;
+
+	if (snap_name == NULL || !strlen(snap_name)) {
+		log_error("snap_name invalid");
+		return NULL;
+	}
+
+	if (max_snap_size) {
+		size = max_snap_size >> SECTOR_SHIFT;
+		extents = extents_from_size(lv->vg->cmd, size, lv->vg->extent_size);
+	}
+
+	if (!size && !lv_is_thin_volume(lv) ) {
+		log_error("Origin is not thin, specify size of snapshot");
+					return NULL;
+	}
+
+	lvcp = dm_pool_zalloc(lv->vg->vgmem, sizeof (struct lvm_lv_create_params));
+	if (lvcp) {
+		lvcp->vg = lv->vg;
+		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
+		lvcp->lvp.snapshot = 1;
+
+
+		if (size) {
+			lvcp->lvp.segtype = _get_segtype(lvcp->vg->cmd);
+			lvcp->lvp.chunk_size = 8;
+		} else {
+			lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin");
+
+			if (!lvcp->lvp.segtype) {
+				log_error(INTERNAL_ERROR "Segtype thin not found.");
+				return NULL;
+			}
+
+			lvcp->lvp.pool = first_seg(lv)->pool_lv->name;
+		}
+
+		lvcp->lvp.stripes = 1;
+		lvcp->lvp.origin = lv->name;
+
+		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
+	}
+
+	return lvcp;
+}
+
+
 lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
 									const char *lvname, uint64_t size)
 {


