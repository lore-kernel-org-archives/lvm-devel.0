From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:03 +0200
Subject: [PATCH 3/6] thin: removal of spare disables recovery
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <6844a5105bb7fc9494a28bfa1b7cf867b91b08de.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Warn user when removing spare LV.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8acca49..f0fad05 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3623,6 +3623,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	percent_t snap_percent;
 	struct dm_list *snh, *snht;
+	struct lv_list *lvl;
 	struct lvinfo info;
 
 	if (lv_is_cow(lv)) {
@@ -3681,6 +3682,24 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
+	if (lv_is_thin_pool(lv) && lv->vg->spare) {
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_thin_pool(lvl->lv) && lvl->lv != lv)
+				break;
+
+		if ((!lv_is_thin_pool(lvl->lv) || lvl->lv == lv) &&
+		    !lv_remove_with_dependencies(cmd, lv->vg->spare, force, level + 1))
+			return_0;
+	}
+
+	if (lv_is_spare(lv) &&
+	    (force == PROMPT) &&
+	    (yes_no_prompt("Removal of spare logical volume \"%s\" disables thin pool recovery. "
+			   "Proceed? [y/n]: ", lv->name) == 'n')) {
+		log_error("Logical volume \"%s\" not removed.", lv->name);
+		return 0;
+	}
+
 	return lv_remove_single(cmd, lv, force);
 }
 
-- 
1.8.2.1


