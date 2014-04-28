From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:45 +0000 (UTC)
Subject: master - thin: move segment info display to correct code section
Message-ID: <20140428104345.8958860D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c405a9b490423fc2dbcc475ca4649f2c4a03f5e
Commit:        4c405a9b490423fc2dbcc475ca4649f2c4a03f5e
Parent:        71314a9905eb5f515aa15af5de2a1f73d82b5ae3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:56:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:41:25 2014 +0200

thin: move segment info display to correct code section

Relocate info from thin pool and thin volume segments
to proper code section for segments.
Add discards and thin count status info.

Info is shown with  'lvdisplay --maps' (like for other segments).
---
 WHATS_NEW             |    1 +
 lib/display/display.c |    6 ------
 lib/thin/thin.c       |   24 ++++++++++++++++++++++++
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d4640f..9d792a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Move segment thin pool/volume info into segment display 'lvdisplay --maps'.
   Display thin pool usage even when just thin volume is available.
   Display monitoring status for monitorable segments in 'lvdisplay --maps'.
   Display virtual extents for virtual LVs in 'lvdisplay --maps'.
diff --git a/lib/display/display.c b/lib/display/display.c
index 83fb901..36274b6 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -509,7 +509,6 @@ int lvdisplay_full(struct cmd_context *cmd,
 	if (lv_is_thin_volume(lv)) {
 		seg = first_seg(lv);
 		log_print("LV Pool name           %s", seg->pool_lv->name);
-		log_print("LV Thin device ID      %u", seg->device_id);
 		if (seg->origin)
 			log_print("LV Thin origin name    %s",
 				  seg->origin->name);
@@ -531,13 +530,8 @@ int lvdisplay_full(struct cmd_context *cmd,
 		}
 		/* FIXME: display thin_pool targets transid for activated LV as well */
 		seg = first_seg(lv);
-		log_print("LV Pool transaction ID %" PRIu64, seg->transaction_id);
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
-		log_print("LV Pool chunk size     %s",
-			  display_size(cmd, seg->chunk_size));
-		log_print("LV Zero new blocks     %s",
-			  seg->zero_new_blocks ? "yes" : "no");
 	}
 
 	if (inkernel && info.suspended)
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index b717603..a1bfaaa 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "display.h"
 #include "metadata.h"
 #include "segtype.h"
 #include "text_export.h"
@@ -40,6 +41,20 @@ static const char *_thin_pool_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
+static void _thin_pool_display(const struct lv_segment *seg)
+{
+	log_print("  Chunk size\t\t%s",
+		  display_size(seg->lv->vg->cmd, seg->chunk_size));
+	log_print("  Discards\t\t%s", get_pool_discards_name(seg->discards));
+	log_print("  Thin count\t\t%u",
+		  dm_list_size(&seg->lv->segs_using_this_lv));
+	log_print("  Transaction ID\t%" PRIu64, seg->transaction_id);
+	log_print("  Zero new blocks\t%s",
+		  seg->zero_new_blocks ? "yes" : "no");
+
+	log_print(" ");
+}
+
 static int _thin_pool_add_message(struct lv_segment *seg,
 				  const char *key,
 				  const struct dm_config_node *sn)
@@ -439,6 +454,13 @@ static const char *_thin_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
+static void _thin_display(const struct lv_segment *seg)
+{
+	log_print("  Device ID\t\t%u", seg->device_id);
+
+	log_print(" ");
+}
+
 static int _thin_text_import(struct lv_segment *seg,
 			     const struct dm_config_node *sn,
 			     struct dm_hash_table *pv_hash __attribute__((unused)))
@@ -699,6 +721,7 @@ static void _thin_destroy(struct segment_type *segtype)
 
 static struct segtype_handler _thin_pool_ops = {
 	.name = _thin_pool_name,
+	.display = _thin_pool_display,
 	.text_import = _thin_pool_text_import,
 	.text_import_area_count = _thin_pool_text_import_area_count,
 	.text_export = _thin_pool_text_export,
@@ -720,6 +743,7 @@ static struct segtype_handler _thin_pool_ops = {
 
 static struct segtype_handler _thin_ops = {
 	.name = _thin_name,
+	.display = _thin_display,
 	.text_import = _thin_text_import,
 	.text_export = _thin_text_export,
 #ifdef DEVMAPPER_SUPPORT


