From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 15 Nov 2012 20:53:22 -0600
Subject: [PATCH 1/2] lvm2app: Add lv shapshot support
Message-ID: <1353034403-17049-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h | 21 +++++++++++++++++++++
 liblvm/lvm_lv.c  | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index d99742c..7515973 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1377,6 +1377,27 @@ int lvm_lv_rename(lv_t lv, const char *new_name);
  */
 int lvm_lv_resize(const lv_t lv, uint64_t new_size);
 
+/**
+ * Create a snapshot of a logical volume
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   snap_name
+ * Name of the snapshot.
+ *
+ * \param   max_snap_size
+ * Max snapshot space to use. If you pass zero the same amount of space as
+ * the origin will be used.
+ *
+ * \return
+ * Valid lv pointer on success, else NULL on error.
+ *
+ */
+lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
+
 /************************** physical volume handling ************************/
 
 /**
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index b22ba11..08f9b53 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -122,12 +122,19 @@ static void _lv_set_default_params(struct lvcreate_params *lp,
 	dm_list_init(&lp->tags);
 }
 
+static struct segment_type * _get_segtype(struct cmd_context *cmd) {
+	struct segment_type *rc = get_segtype_from_string(cmd, "striped");
+	if (!rc) {
+		log_error(INTERNAL_ERROR "Segtype striped not found.");
+	}
+	return rc;
+}
+
 /* Set default for linear segment specific LV parameters */
 static int _lv_set_default_linear_params(struct cmd_context *cmd,
 					  struct lvcreate_params *lp)
 {
-	if (!(lp->segtype = get_segtype_from_string(cmd, "striped"))) {
-		log_error(INTERNAL_ERROR "Segtype striped not found.");
+	if (!(lp->segtype = _get_segtype(cmd))) {
 		return 0;
 	}
 
@@ -321,3 +328,49 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 
 	return 0;
 }
+
+lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)
+{
+	struct lvcreate_params lp = { 0 };
+	uint64_t extents = 0;
+	uint64_t size = 0;
+	struct lv_list *lvl = NULL;
+
+	if (vg_read_error(lv->vg))
+		return NULL;
+	if (!vg_check_write_mode(lv->vg))
+		return NULL;
+
+	/* Determine the correct size */
+	if (0 == max_snap_size){
+		size = lv->size;
+	} else {
+		size = max_snap_size >> SECTOR_SHIFT;
+
+		if (size > lv->size) {
+			size = lv->size;
+		}
+	}
+
+	if (!(extents = extents_from_size(lv->vg->cmd, size,
+					  lv->vg->extent_size))) {
+		log_error("Unable to create LV snapshot without size.");
+		return NULL;
+	}
+
+	_lv_set_default_params(&lp, lv->vg, snap_name, extents);
+
+	/* Fill out required default input values */
+	lp.snapshot = 1;
+	lp.segtype = _get_segtype(lv->vg->cmd);
+	lp.stripes = 1;
+	lp.origin = lv->name;
+
+	if (!lp.segtype)
+		return_NULL;
+	if (!lv_create_single(lv->vg, &lp))
+		return_NULL;
+	if (!(lvl = find_lv_in_vg(lv->vg, snap_name)))
+		return NULL;
+	return (lv_t) lvl->lv;
+}
-- 
1.7.11.7


