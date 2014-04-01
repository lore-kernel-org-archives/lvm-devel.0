From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:03 +0000 (UTC)
Subject: master - cache: fix order of metadata change
Message-ID: <20140401185603.348566092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e72dea55bf3ba3b03014b2f04edeb048ade296eb
Commit:        e72dea55bf3ba3b03014b2f04edeb048ade296eb
Parent:        d3004479cc0fa1fac3bd340cfb0c306a1f088280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 18:08:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:17:10 2014 +0200

cache: fix order of metadata change

Start to change metadata after they are archived.
And since cache_pool is virtual skip deactivation
call for this LV.
---
 lib/metadata/lv_manip.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b939479..2da6ae1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4688,21 +4688,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
-	/*
-	 * If we are removing a cache_pool, we must first unlink
-	 * it from any origins (i.e. remove the cache layer).
-	 *
-	 * If the cache_pool is not linked, we can simply proceed
-	 * to remove it.
-	 */
-	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
-		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
-			return_0;
-
-		if (!lv_cache_remove(cache_seg->lv))
-			return_0;
-	}
-
 	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
 		log_error("Can't remove logical volume %s used by a cache_pool.",
 			  lv->name);
@@ -4760,8 +4745,18 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 	}
 
-	/* FIXME Review and fix the snapshot error paths! */
-	if (!deactivate_lv(cmd, lv)) {
+	if (lv_is_cache_pool(lv)) {
+		/* Cache pool removal drops cache layer
+		 * If the cache pool is not linked, we can simply remove it. */
+		if (!dm_list_empty(&lv->segs_using_this_lv)) {
+			if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+				return_0;
+			/* TODO: polling */
+			if (!lv_cache_remove(cache_seg->lv))
+				return_0;
+		}
+	} else if (!deactivate_lv(cmd, lv)) {
+		/* FIXME Review and fix the snapshot error paths! */
 		log_error("Unable to deactivate logical volume \"%s\"",
 			  lv->name);
 		return 0;


