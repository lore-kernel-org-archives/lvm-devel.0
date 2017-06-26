From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:30:07 -0400
Subject: master - coverity: validate retval from get_only_segment_using_this_lv
Message-ID: <201706262230.v5QMU7Fq010548@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=275fc2d45bbef5ffaa43a83c1f9572232fdf2268
Commit:        275fc2d45bbef5ffaa43a83c1f9572232fdf2268
Parent:        664e947726ad3e64b59b2e3d43cd4ea01f7e5d5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 00:24:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

coverity: validate retval from get_only_segment_using_this_lv

---
 lib/activate/activate.c |    3 ++-
 lib/display/display.c   |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 282dd4f..b3ed513 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -781,7 +781,8 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 	if (lv_is_used_cache_pool(lv)) {
 		/* INFO is not set as cache-pool cannot be active.
 		 * STATUS is collected from cache LV */
-		lv_seg = get_only_segment_using_this_lv(lv);
+		if (!(lv_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
 		(void) _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
 	}
diff --git a/lib/display/display.c b/lib/display/display.c
index 18e49f9..9a928d9 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -517,8 +517,8 @@ int lvdisplay_full(struct cmd_context *cmd,
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
 	} else if (lv_is_cache_origin(lv)) {
-		log_print("LV origin of Cache LV  %s",
-			  get_only_segment_using_this_lv(lv)->lv->name);
+		if ((seg = get_only_segment_using_this_lv(lv)))
+			log_print("LV origin of Cache LV  %s", seg->lv->name);
 	} else if (lv_is_cache(lv)) {
 		seg = first_seg(lv);
 		if (inkernel && !lv_cache_status(lv, &cache_status))


