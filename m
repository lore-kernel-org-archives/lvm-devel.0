From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  9 Mar 2011 13:18:33 +0100
Subject: [PATCH 2/4] Refactor code for _lv_postoder
In-Reply-To: <cover.1299670163.git.zkabelac@redhat.com>
References: <cover.1299670163.git.zkabelac@redhat.com>
Message-ID: <0e29ca355668d9c3e8feeac151bee81f051cff94.1299670163.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add _lv_postorder_vg() - for calling postorder for every LV from VG.
We use this in 2 places -  vg_mark_partial_lvs and vg_validate
so make it as one function.

Benefit here is - to use only one cleanup code and avoid
potentially duplicate scan of same LVs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   39 ++++++++++++++++++++++++---------------
 1 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5525e3d..c006b60 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2068,6 +2068,25 @@ static int _lv_postorder(struct logical_volume *lv,
 	return r;
 }
 
+static int _lv_postorder_vg(struct volume_group *vg,
+			    int (*fn)(struct logical_volume *lv, void *data),
+			    void *data)
+{
+	struct lv_list *lvl;
+	int r = 1;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
+			stack;
+			r = 0;
+		}
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		_lv_postorder_cleanup(lvl->lv, 0);
+
+	return r;
+}
+
 struct _lv_mark_if_partial_baton {
 	int partial;
 };
@@ -2105,11 +2124,6 @@ static int _lv_mark_if_partial_single(struct logical_volume *lv, void *data)
 	return 1;
 }
 
-static int _lv_mark_if_partial(struct logical_volume *lv)
-{
-	return _lv_postorder(lv, _lv_mark_if_partial_single, NULL);
-}
-
 /*
  * Mark LVs with missing PVs using PARTIAL_LV status flag. The flag is
  * propagated transitively, so LVs referencing other LVs are marked
@@ -2117,14 +2131,9 @@ static int _lv_mark_if_partial(struct logical_volume *lv)
  */
 int vg_mark_partial_lvs(struct volume_group *vg)
 {
-	struct logical_volume *lv;
-	struct lv_list *lvl;
+	if (!_lv_postorder_vg(vg, _lv_mark_if_partial_single, NULL))
+		return_0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		lv = lvl->lv;
-		if (!_lv_mark_if_partial(lv))
-			return_0;
-	}
 	return 1;
 }
 
@@ -2407,9 +2416,9 @@ int vg_validate(struct volume_group *vg)
 	dm_hash_destroy(lvname_hash);
 	dm_hash_destroy(lvid_hash);
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!_lv_postorder(lvl->lv, _lv_validate_references_single, NULL))
-			r = 0;
+	if (!_lv_postorder_vg(vg, _lv_validate_references_single, NULL)) {
+		stack;
+		r = 0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-- 
1.7.4.1


