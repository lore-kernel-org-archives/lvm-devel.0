From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:00 -0400
Subject: master - coverity: extra check for find_pool_seg
Message-ID: <201706271020.v5RAK05m003865@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9c60f874ef02c8c5539310223e61e73a8103681
Commit:        e9c60f874ef02c8c5539310223e61e73a8103681
Parent:        b939ddf80c7370ae17e26c6d05482be6799245e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 10:16:13 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:15:15 2017 +0200

coverity: extra check for find_pool_seg

find_pool_seg may return NULL in some internal error stats.
Handle it explicitely.
---
 lib/activate/activate.c |   15 +++++++++------
 lib/metadata/lv_manip.c |    5 ++++-
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b3ed513..d73e8b1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1849,12 +1849,15 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	 *  However in case command would have crashed, such LV is
 	 *  left unmonitored and may potentially require dmeventd.
 	 */
-	if ((lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
-	    !lv_is_used_cache_pool((find_pool_seg(first_seg(lv))->lv))) {
-		log_debug_activation("Skipping %smonitor of %s.%s",
-				     (monitor) ? "" : "un", display_lvname(lv),
-				     (monitor) ? " Cache pool activation for clearing only." : "");
-		return 1;
+	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
+		if (!(seg = find_pool_seg(first_seg(lv))))
+			return_0;
+		if (!lv_is_used_cache_pool(seg->lv)) {
+			log_debug_activation("Skipping %smonitor of %s.%s",
+					     (monitor) ? "" : "un", display_lvname(lv),
+					     (monitor) ? " Cache pool activation for clearing only." : "");
+			return 1;
+		}
 	}
 
 	/*
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1a584f2..f75cf51 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5288,6 +5288,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 static int _lvresize_check_type(const struct logical_volume *lv,
 				const struct lvresize_params *lp)
 {
+	struct lv_segment *seg;
+
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("Snapshot origin volumes cannot be reduced in size yet.");
@@ -5313,7 +5315,8 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 		}
 	} else if (lp->resize == LV_EXTEND)  {
 		if (lv_is_thin_pool_metadata(lv) &&
-		    !thin_pool_feature_supported(find_pool_seg(first_seg(lv))->lv, THIN_FEATURE_METADATA_RESIZE)) {
+		    (!(seg = find_pool_seg(first_seg(lv))) ||
+		     !thin_pool_feature_supported(seg->lv, THIN_FEATURE_METADATA_RESIZE))) {
 			log_error("Support for online metadata resize of %s not detected.",
 				  display_lvname(lv));
 			return 0;


