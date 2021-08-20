From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 19:51:34 +0000 (GMT)
Subject: main - logging: messages for found metadata
Message-ID: <20210820195134.14BDA385801E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e79a022ea391a3cfb9e9f95f10ecfe7a277e794
Commit:        9e79a022ea391a3cfb9e9f95f10ecfe7a277e794
Parent:        6cd4470e6d88047ceefd4ecaaf00384d85dd2dad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 19 15:07:05 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 14:51:09 2021 -0500

logging: messages for found metadata

---
 lib/format_text/format-text.c | 27 +++++++++------------------
 lib/format_text/text_label.c  |  4 ++--
 2 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a274ab543..44c77d027 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -305,20 +305,8 @@ static struct raw_locn *_read_metadata_location_vg(struct cmd_context *cmd,
 	if (*precommitted && rlocn_precommitted->size &&
 	    (rlocn_precommitted->offset != rlocn->offset)) {
 		rlocn = rlocn_precommitted;
-		log_debug_metadata("VG %s metadata check %s mda %llu slot1 offset %llu size %llu",
-				   vgname ?: "",
-				   dev_name(dev_area->dev),
-				   (unsigned long long)dev_area->start,
-				   (unsigned long long)rlocn->offset,
-				   (unsigned long long)rlocn->size);
 	} else {
 		*precommitted = 0;
-		log_debug_metadata("VG %s metadata check %s mda %llu slot0 offset %llu size %llu",
-				   vgname ?: "",
-				   dev_name(dev_area->dev),
-				   (unsigned long long)dev_area->start,
-				   (unsigned long long)rlocn->offset,
-				   (unsigned long long)rlocn->size);
 	}
 
 	/* Do not check non-existent metadata. */
@@ -440,19 +428,22 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
 				&when, &desc);
 
 	if (!vg && !*use_previous_vg) {
-		log_warn("WARNING: failed to read metadata text on %s at %llu size %llu for VG %s.",
-			 dev_name(area->dev),
+		log_warn("WARNING: Failed to read metadata text at %llu off %llu size %llu VG %s on %s",
 			 (unsigned long long)(area->start + rlocn->offset),
+			 (unsigned long long)rlocn->offset,
 			 (unsigned long long)rlocn->size,
-			 vgname);
+			 vgname,
+			 dev_name(area->dev));
+
 		return NULL;
 	}
 
-	log_debug_metadata("Found metadata on %s at %llu size %llu for VG %s",
-			   dev_name(area->dev),
+	log_debug_metadata("Found metadata text at %llu off %llu size %llu VG %s on %s",
 			   (unsigned long long)(area->start + rlocn->offset),
+			   (unsigned long long)rlocn->offset,
 			   (unsigned long long)rlocn->size,
-			   vgname);
+			   vgname,
+			   dev_name(area->dev));
 
 	if (vg && precommitted)
 		vg->status |= PRECOMMITTED;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index f12171eca..29b470271 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -561,7 +561,7 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 				bad_mda_count++;
 			} else {
 				/* The normal success path */
-				log_debug("Scanned %s mda1 seqno %u", dev_name(dev), vgsummary.seqno);
+				log_debug("Found metadata seqno %u in mda1 on %s", vgsummary.seqno, dev_name(dev));
 				good_mda_count++;
 			}
 		}
@@ -611,7 +611,7 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 				bad_mda_count++;
 			} else {
 				/* The normal success path */
-				log_debug("Scanned %s mda2 seqno %u", dev_name(dev), vgsummary.seqno);
+				log_debug("Found metadata seqno %u in mda2 on %s", vgsummary.seqno, dev_name(dev));
 				good_mda_count++;
 			}
 		}


