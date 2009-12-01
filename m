From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 01 Dec 2009 15:23:00 +0100
Subject: [PATCH] Give better message for pvmove when all data is skipped
Message-ID: <4B1526C4.2010900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just a little thing - better message in pvmove, maybe :) 
BZ #500898/#500899

Peter

diff --git a/tools/pvmove.c b/tools/pvmove.c
index ac09d6a..cc20320 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -180,6 +180,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
 	int lv_found = 0;
+	int lv_skipped = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -209,22 +210,27 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
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
@@ -240,6 +246,10 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 	/* Is temporary mirror empty? */
 	if (!lv_mirr->le_count) {
+		if (lv_skipped)
+			log_error("All data on source PV skipped. "
+				  "It contains locked, hidden or "
+				  "non-top level LVs only.");
 		log_error("No data to move for %s", vg->name);
 		return NULL;
 	}


