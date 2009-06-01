From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 01 Jun 2009 10:34:45 +0200
Subject: [PATCH] Provide an extended message for pvmove when all LVs are skipped on a PV
Message-ID: <4A2392A5.3010600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This just adds an extended message when trying to do a pvmove on
a PV where all the PEs belong to locked or non-top level LVs.
This way it's less confusing than the plain message "No data to
move". (requested in BZ 500898/500899)

Peter

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9ece646..f26a1e7 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -187,6 +187,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
 	int lv_found = 0;
+	int lv_skipped = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -216,22 +217,27 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			lv_found = 1;
 		}
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
+			lv_skipped = 1;
 			log_print("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRRORED) {
+			lv_skipped = 1;
 			log_print("Skipping mirror LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_LOG) {
+			lv_skipped = 1;
 			log_print("Skipping mirror log LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_IMAGE) {
+			lv_skipped = 1;
 			log_print("Skipping mirror image LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & LOCKED) {
+			lv_skipped = 1;
 			log_print("Skipping locked LV %s", lv->name);
 			continue;
 		}
@@ -247,6 +253,10 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 	/* Is temporary mirror empty? */
 	if (!lv_mirr->le_count) {
+		if (lv_skipped)
+			log_error("All data on source PV skipped. "
+				  "It contains locked, hidden or "
+				  "non-top level LVs only.");
 		log_error("No data to move for %s", vg->name);
 		return NULL;
 	}


