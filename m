From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:55 +0200
Subject: [PATCH 3/7] thin: removal of spare disables recovery
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <1dcf0ac23c95c529c396417c7d81a85b57aab9d2.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Warn user when removing spare LV.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9d67e71..d86d070 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4521,7 +4521,9 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	percent_t snap_percent;
 	struct dm_list *snh, *snht;
+	struct lv_list *lvl;
 	struct lvinfo info;
+	int found;
 
 	if (lv_is_cow(lv)) {
 		/*
@@ -4579,6 +4581,30 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
+	if (lv_is_thin_pool(lv) && lv->vg->pool_metadata_spare_lv) {
+		found = 0;
+		/* When removing last thin pool, remove spare as well */
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_thin_pool(lvl->lv) && lvl->lv != lv) {
+				found = 1;
+				break;
+			}
+
+		if (!found &&
+		    !lv_remove_with_dependencies(cmd, lv->vg->pool_metadata_spare_lv,
+						 force, level + 1))
+			return_0;
+	}
+
+	if (lv_is_pool_metadata_spare(lv) &&
+	    (force == PROMPT) &&
+	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
+			   "disables automatic recovery attempts after damage "
+			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n')) {
+		log_error("Logical volume \"%s\" not removed.", lv->name);
+		return 0;
+	}
+
 	return lv_remove_single(cmd, lv, force);
 }
 
-- 
1.8.3.1


