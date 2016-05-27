From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:38 +0000 (UTC)
Subject: master - cache: enhance lv_cache_wait_for_clean
Message-ID: <20160527134738.E8AC260642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c07e6746234e361ea68073b47a47df4bf4a7b2a
Commit:        1c07e6746234e361ea68073b47a47df4bf4a7b2a
Parent:        0424277c00a8c576082389e0f4cdd8fd64052a54
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 14:19:29 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

cache: enhance lv_cache_wait_for_clean

Handle passthrough mode when checking cache mode state explicitely.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   27 +++++++++++++++------------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a6957bc..213bc72 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Support passthrough cache mode when waiting for clean cache.
   Check cache status only for 'in-use' cache pools.
   Extend setup_task() to preset flushing for dm_task object.
   When checking LV is a merging COW, validate its a COW LV first.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a39549d..3e8c5c7 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -425,8 +425,11 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 			log_error("Cannot deactivate remotely active cache lv.");
 			return 0;
 		}
-		/* For inactive writethrough just drop cache layer */
-		if (first_seg(cache_seg->pool_lv)->cache_mode == CACHE_MODE_WRITETHROUGH) {
+
+		switch (first_seg(cache_seg->pool_lv)->cache_mode) {
+		case CACHE_MODE_WRITETHROUGH:
+		case CACHE_MODE_PASSTHROUGH:
+			/* For inactive pass/writethrough just drop cache layer */
 			corigin_lv = seg_lv(cache_seg, 0);
 			if (!detach_pool_lv(cache_seg))
 				return_0;
@@ -435,17 +438,17 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 			if (!lv_remove(corigin_lv))
 				return_0;
 			return 1;
+		default:
+			/* Otherwise localy activate volume to sync dirty blocks */
+			cache_lv->status |= LV_TEMPORARY;
+			if (!activate_lv_excl_local(cache_lv->vg->cmd, cache_lv) ||
+			    !lv_is_active_locally(cache_lv)) {
+				log_error("Failed to active cache locally %s.",
+					  display_lvname(cache_lv));
+				return 0;
+			}
+			cache_lv->status &= ~LV_TEMPORARY;
 		}
-
-		/* Otherwise localy active volume is need to sync dirty blocks */
-		cache_lv->status |= LV_TEMPORARY;
-		if (!activate_lv_excl_local(cache_lv->vg->cmd, cache_lv) ||
-		    !lv_is_active_locally(cache_lv)) {
-			log_error("Failed to active cache locally %s.",
-				  display_lvname(cache_lv));
-			return 0;
-		}
-		cache_lv->status &= ~LV_TEMPORARY;
 	}
 
 	/*


