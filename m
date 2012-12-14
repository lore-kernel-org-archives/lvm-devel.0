From: Andy Grover <grover@fedoraproject.org>
Date: Fri, 14 Dec 2012 18:33:53 +0000 (UTC)
Subject: master - lvm2app: Add lv snapshot support
Message-ID: <20121214183353.551C916B9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90467a1412e8c227f83ba7825250e33a4d39607d
Commit:        90467a1412e8c227f83ba7825250e33a4d39607d
Parent:        e8025aa67a05af046878f52dfb45fca30ed70084
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Dec 13 17:57:38 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Thu Dec 13 17:58:48 2012 -0800

lvm2app: Add lv snapshot support

Signed-off-by: Tony Asleson <tasleson@redhat.com>
Signed-off-by: Andy Grover <agrover@redhat.com>
---
 liblvm/lvm2app.h |   21 +++++++++++++++++++
 liblvm/lvm_lv.c  |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index b758945..93a78c3 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1379,6 +1379,27 @@ int lvm_lv_rename(lv_t lv, const char *new_name);
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
index b2a604d..a02e68d 100644
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
 
@@ -306,3 +313,49 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	log_error("NOT IMPLEMENTED YET");
 	return -1;
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


