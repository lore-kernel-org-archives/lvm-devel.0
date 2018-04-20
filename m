From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:50 -0400
Subject: master - cleanup: correcting macro wrapping
Message-ID: <201804201102.w3KB2oa3031412@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73cda0437f8added751716c9bbae33fe321b4963
Commit:        73cda0437f8added751716c9bbae33fe321b4963
Parent:        9731d48691e85641e45a127ddf77fb603aa4900c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 19 17:35:48 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: correcting macro wrapping

Use proper do {} while(0) so ';' after macros are correctly
interpretted..
---
 lib/metadata/merge.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 90b40e2..7299620 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -71,12 +71,12 @@ int lv_merge_segments(struct logical_volume *lv)
 	if (error_count++ > ERROR_MAX)	\
 		goto out
 
-#define seg_error(msg) { \
+#define seg_error(msg) do { \
 		log_error("LV %s, segment %u invalid: %s for %s segment.", \
 			  seg->lv->name, seg_count, (msg), lvseg_name(seg)); \
 		if ((*error_count)++ > ERROR_MAX) \
 			return; \
-	}
+	} while (0)
 
 /*
  * RAID segment property checks.
@@ -84,19 +84,19 @@ int lv_merge_segments(struct logical_volume *lv)
  * Checks in here shall catch any
  * bogus segment structure setup.
  */
-#define raid_seg_error(msg) { \
+#define raid_seg_error(msg) do { \
 	log_error("LV %s invalid: %s for %s segment", \
 		  seg->lv->name, (msg), lvseg_name(seg)); \
 	if ((*error_count)++ > ERROR_MAX) \
 		return; \
-}
+} while (0)
 
-#define raid_seg_error_val(msg, val) { \
+#define raid_seg_error_val(msg, val) do { \
 	log_error("LV %s invalid: %s (is %u) for %s segment", \
 		  seg->lv->name, (msg), (val), lvseg_name(seg)); \
 	if ((*error_count)++ > ERROR_MAX) \
 		return; \
-}
+} while(0)
 
 /* Check segment LV for reshape flags. */
 static int _check_raid_seg_reshape_flags(struct lv_segment *seg)
@@ -354,7 +354,7 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			case CACHE_MODE_PASSTHROUGH:
 				break;
 			default:
-				seg_error("has invalid cache's feature flag")
+				seg_error("has invalid cache's feature flag");
 			}
 			if (!seg->policy_name)
 				seg_error("is missing cache policy name");


