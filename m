From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:10 +0000 (UTC)
Subject: master - cache: prepare status checking for layer
Message-ID: <20161218185210.C609560E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a24eae6e82f365c66f4faeabc975ead0c476916b
Commit:        a24eae6e82f365c66f4faeabc975ead0c476916b
Parent:        bf157ed833f8732c4e264422bd8be46fdf75673a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 21:52:27 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:23:13 2016 +0100

cache: prepare status checking for layer

To be ready to show status of cache volume, call the status
with layer.  Layer is automatically detected in this case when
cache volume is used in 'layered' form (needs -real suffix).
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    4 ++--
 lib/metadata/cache_manip.c |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e9c953..6b9a310 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support status checking of cache volume used in layer.
   Avoid shifting by one number of blocks when clearing dirty cache volume.
   Extend metadata validation of external origin LV use count.
   Fix dm table when the last user of active external origin is removed.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c554337..b7009e6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -770,7 +770,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 		/* INFO is not set as cache-pool cannot be active.
 		 * STATUS is collected from cache LV */
 		lv_seg = get_only_segment_using_this_lv(lv);
-		(void) _lv_info(cmd, lv_seg->lv, 0, NULL, lv_seg, &status->seg_status, 0, 0);
+		(void) _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
 	}
 
@@ -1171,7 +1171,7 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 		return 0;
 	}
 
-	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0)) {
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 1, NULL, 0, 0)) {
 		log_error("Cannot check status for locally inactive cache volume %s.",
 			  display_lvname(cache_lv));
 		return 0;
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 54d907c..ed72fae 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -475,7 +475,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	}
 
 	/* Localy active volume is needed for writeback */
-	if (!lv_is_active_locally(cache_lv)) {
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 1, NULL, 0, 0)) {
 		/* Give up any remote locks */
 		if (!deactivate_lv(cache_lv->vg->cmd, cache_lv)) {
 			log_error("Cannot deactivate remotely active cache volume %s.",


