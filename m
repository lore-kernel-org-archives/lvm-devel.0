From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:08 +0000 (UTC)
Subject: master - cache: improve wait for cache clear
Message-ID: <20161218185208.B4F9460E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf157ed833f8732c4e264422bd8be46fdf75673a
Commit:        bf157ed833f8732c4e264422bd8be46fdf75673a
Parent:        36f609e513262547aa4d92c2b55d98b1471ba2e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 15:05:57 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:22:11 2016 +0100

cache: improve wait for cache clear

Avoid printing misleading message about single dirty block.
Instead properly detect condition where the 'cleaner' policy
needs to be installed without 'overloading' dirty variable.

Also print warning if we would be clearing read-only volume.
(it really shouldn't happen).
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   17 ++++++++++-------
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5002308..2e9c953 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Avoid shifting by one number of blocks when clearing dirty cache volume.
   Extend metadata validation of external origin LV use count.
   Fix dm table when the last user of active external origin is removed.
   Improve reported lvs status for active external origin volume.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index d73142d..54d907c 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -383,7 +383,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	const struct logical_volume *lock_lv = lv_lock_holder(cache_lv);
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct lv_status_cache *status;
-	int cleaner_policy;
+	int cleaner_policy, writeback;
 	uint64_t dirty_blocks;
 
 	*is_clean = 0;
@@ -402,14 +402,11 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 		cleaner_policy = !strcmp(status->cache->policy_name, "cleaner");
 		dirty_blocks = status->cache->dirty_blocks;
-
-		/* No clear policy and writeback mode means dirty */
-		if (!cleaner_policy &&
-		    (status->cache->feature_flags & DM_CACHE_FEATURE_WRITEBACK))
-			dirty_blocks++;
+		writeback = (status->cache->feature_flags & DM_CACHE_FEATURE_WRITEBACK);
 		dm_pool_destroy(status->mem);
 
-		if (!dirty_blocks)
+		/* Only clear when policy is Clear or mode != writeback */
+		if (!dirty_blocks && (cleaner_policy || !writeback))
 			break;
 
 		log_print_unless_silent("Flushing " FMTu64 " blocks for cache %s.",
@@ -420,6 +417,12 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 			continue;
 		}
 
+		if (!(cache_lv->status & LVM_WRITE)) {
+			log_warn("WARNING: Dirty blocks found on read-only cache volume %s.",
+				 display_lvname(cache_lv));
+			/* TODO: can we actually clean something? */
+		}
+
 		/* Switch to cleaner policy to flush the cache */
 		cache_seg->cleaner_policy = 1;
 		/* Reaload kernel with "cleaner" policy */


