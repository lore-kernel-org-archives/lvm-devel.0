From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:08 +0000 (UTC)
Subject: master - thin: check for new pool before creating thin volume
Message-ID: <20141104143308.28CB2608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8563c3e1a96f0d7ad180c859e9bf23a90e63e907
Commit:        8563c3e1a96f0d7ad180c859e9bf23a90e63e907
Parent:        6116b1d6e302097086c9dcd418e4404ddd337939
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 15:08:15 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:29:19 2014 +0100

thin: check for new pool before creating thin volume

Call check_new_thin_pool() to detect in-use thin-pool.
Save extra reactivation of thin-pool when thin pool is not active.
(it's now a bit more expensive to invoke thin_check for new pools.)

For new pools:

We now active locally exclusively thin-pool as 'public' LV.
Validate transaction_id is till 0.
Deactive.
Prepare create message for thin-pool and exclusively active pool.
Active new thin LV.
And deactivate thin pool if it used to be inactive.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   37 +++++++++++++++++++++++++++++++++++--
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d824289..3914392 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Inital support for external users of thin pools based on transaction_id.
   Report some basic percentage info for cache pools.
   Introduce size_mb_arg_with_percent() for advanced size arg reading.
   Add extra support for '.' as decimal point in size args.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b5fc84a..d3c0c47 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6559,6 +6559,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *tmp_lv;
 	struct lv_segment *seg, *pool_seg;
+	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -6679,6 +6680,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 		}
 
+		if (seg_is_thin_volume(lp) &&
+		    lv_is_new_thin_pool(pool_lv)) {
+			thin_pool_was_active = lv_is_active(pool_lv);
+			if (!check_new_thin_pool(pool_lv))
+				return_NULL;
+			/* New pool is now inactive */
+		}
+
 		if (seg_is_cache(lp) &&
 		    !wipe_cache_pool(pool_lv))
 			return_NULL;
@@ -7003,7 +7012,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				goto revert_new_lv;
 			}
 			/* At this point remove pool messages, snapshot is active */
-			if (!update_pool_lv(first_seg(origin_lv)->pool_lv, 0)) {
+			if (!update_pool_lv(pool_lv, 0)) {
 				stack;
 				goto revert_new_lv;
 			}
@@ -7013,7 +7022,23 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		if (is_change_activating(lp->activate)) {
 			/* Send message so that table preload knows new thin */
-			if (!update_pool_lv(first_seg(lv)->pool_lv, 1)) {
+			if (!lv_is_active(pool_lv)) {
+				/* Avoid multiple thin-pool activations in this case */
+				if (thin_pool_was_active < 0)
+					thin_pool_was_active = 0;
+				if (!activate_lv_excl(cmd, pool_lv)) {
+					log_error("Failed to activate thin pool %s/%s.",
+						  origin_lv->vg->name, origin_lv->name);
+					goto revert_new_lv;
+				}
+				if (!lv_is_active(pool_lv)) {
+					log_error("Cannot activate thin pool %s, perhaps skipped in lvm.conf volume_list?",
+						  display_lvname(pool_lv));
+					return 0;
+				}
+			}
+			/* Keep thin pool active until thin volume is activated */
+			if (!update_pool_lv(pool_lv, (thin_pool_was_active < 0) ? 1 : 0)) {
 				stack;
 				goto revert_new_lv;
 			}
@@ -7024,6 +7049,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				log_error("Failed to activate thin %s.", lv->name);
 				goto deactivate_and_revert_new_lv;
 			}
+
+			/* Restore inactive state if needed */
+			if (!thin_pool_was_active &&
+			    !deactivate_lv(cmd, pool_lv)) {
+				log_error("Failed to deactivate thin pool %s.",
+					  display_lvname(pool_lv));
+				return NULL;
+			}
 		}
 	} else if (lp->snapshot) {
 		if (!activate_lv_local(cmd, lv)) {


