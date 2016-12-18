From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:12 +0000 (UTC)
Subject: master - lv: fix lock holder for external origin
Message-ID: <20161218185212.D35E060E2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29b0e42be3026a11c86fc05f82f6a14e71d26cc8
Commit:        29b0e42be3026a11c86fc05f82f6a14e71d26cc8
Parent:        a24eae6e82f365c66f4faeabc975ead0c476916b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 22:40:14 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:25:25 2016 +0100

lv: fix lock holder for external origin

External origin could be reloaded via more locks.
It's actually even more complex then thin-pool,
as it may be active on more nodes for linear LVs
(and maybe even more types).

External origin is always read-only thus unmodifiable
device so there should not be a problem accesing it
through multiple nodes.

Also for thin-pool check first presence of active thin-pool.

FIXME:
It's not easy to detect on which nodes this device is active
Thus manipulation with such device may require checking every
node and it active state and refresh.

But since such setup is quite complex to prepare and use,
hopefully there are not user trying to 'explore' this usage yet.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6b9a310..6ab2b19 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Improve search of lock-holder for external origin and thin-pool.
   Support status checking of cache volume used in layer.
   Avoid shifting by one number of blocks when clearing dirty cache volume.
   Extend metadata validation of external origin LV use count.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 1084149..8587902 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1551,14 +1551,19 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 	if (lv_is_cow(lv))
 		return lv_lock_holder(origin_from_cow(lv));
 
-	if (lv_is_thin_pool(lv)) {
-		/* Find any active LV from the pool */
-		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-			if (lv_is_active(sl->seg->lv)) {
-				log_debug_activation("Thin volume %s is active.",
-						     display_lvname(lv));
-				return sl->seg->lv;
-			}
+	if (lv_is_thin_pool(lv) ||
+	    lv_is_external_origin(lv)) {
+		/* FIXME: Ensure cluster keeps thin-pool active exlusively.
+		 * External origin can be activated on more nodes (depends on type).
+		 */
+		if (!lv_is_active(lv))
+			/* Find any active LV from the pool or external origin */
+			dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+				if (lv_is_active(sl->seg->lv)) {
+					log_debug_activation("Thin volume %s is active.",
+							     display_lvname(lv));
+					return sl->seg->lv;
+				}
 		return lv;
 	}
 
@@ -1573,9 +1578,6 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 		    lv_is_thin_volume(sl->seg->lv) &&
 		    first_seg(lv)->pool_lv == sl->seg->pool_lv)
 			continue; /* Skip thin snaphost */
-		if (lv_is_external_origin(lv) &&
-		    lv_is_thin_volume(sl->seg->lv))
-			continue; /* Skip external origin */
 		if (lv_is_pending_delete(sl->seg->lv))
 			continue; /* Skip deleted LVs */
 		return lv_lock_holder(sl->seg->lv);


