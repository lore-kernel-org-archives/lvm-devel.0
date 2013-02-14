From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Thu, 14 Feb 2013 10:59:53 +0530
Subject: [PATCH 1/1] lvm2app: Add support to create thin lv snapshots
Message-ID: <1360819793-16806-1-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Thin LV snapshots don't need to specify the size and when
lvm_lv_snapshot function called with max_snap_size 0, a check is made if
the origin LV is of type thin and thin snapshot lv is created
accordingly.

Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
---
 liblvm/lvm_lv.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 91948a6..0fc37ee 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -320,25 +320,38 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
 	uint64_t extents = 0;
 	uint64_t size = 0;
 	struct lv_list *lvl = NULL;
+	struct lvm_property_value prop;
 
 	if (vg_read_error(lv->vg))
 		return NULL;
 	if (!vg_check_write_mode(lv->vg))
 		return NULL;
 
-	size = max_snap_size >> SECTOR_SHIFT;
+	if (max_snap_size) {
+		size = max_snap_size >> SECTOR_SHIFT;
 
-	if (!(extents = extents_from_size(lv->vg->cmd, size,
+		if (!(extents = extents_from_size(lv->vg->cmd, size,
 					  lv->vg->extent_size))) {
-		log_error("Unable to create LV snapshot without size.");
-		return NULL;
+			log_error("Unable to create LV snapshot without size.");
+			return NULL;
+		}
+		lp.segtype = _get_segtype(lv->vg->cmd);
+	} else {
+		/* Check if its request for thin lv snapshot creation */
+		prop = lvm_lv_get_property (lv, "pool_lv");
+		if (!prop.is_valid || !prop.value.string) {
+			log_error("Unable to create LV snapshot without size.");
+			return NULL;
+		}
+		lp.segtype = get_segtype_from_string(lv->vg->cmd, "thin");
+		lp.pool = prop.value.string;
+		lp.thin = 1;
 	}
 
 	_lv_set_default_params(&lp, lv->vg, snap_name, extents);
 
 	/* Fill out required default input values */
 	lp.snapshot = 1;
-	lp.segtype = _get_segtype(lv->vg->cmd);
 	lp.stripes = 1;
 	lp.origin = lv->name;
 
-- 
1.7.11.7


