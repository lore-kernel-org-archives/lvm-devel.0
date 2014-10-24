From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:59 +0000 (UTC)
Subject: master - pool: better error path handling
Message-ID: <20141024144059.B394360CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7359a9df889a2ed8d6e6114ecc3f57438a75d9d7
Commit:        7359a9df889a2ed8d6e6114ecc3f57438a75d9d7
Parent:        16320642813c811c30c9348c57b7f7fec1221ee9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 24 14:22:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

pool: better error path handling

Move test for size of new LV names in front before
any creation of LV.

Properly check striped  segtype kernel presence,
since passed 'segtype' is already tested.

Keep deactivation error path local to wiping part of the function.

Create metadata with temporary flag (it's activated, zeroed
and deactivated).
---
 lib/metadata/pool_manip.c |   52 +++++++++++++++++++++++++-------------------
 1 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 02a82bd..b4259a8 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -390,6 +390,7 @@ int create_pool(struct logical_volume *pool_lv,
 	struct logical_volume *meta_lv, *data_lv;
 	struct lv_segment *seg;
 	char name[NAME_LEN];
+	int r;
 
 	if (pool_lv->le_count) {
 		log_error(INTERNAL_ERROR "Pool %s already has extents.",
@@ -397,14 +398,22 @@ int create_pool(struct logical_volume *pool_lv,
 		return 0;
 	}
 
+	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,
+			(segtype_is_cache_pool(segtype)) ?
+			"cmeta" : "tmeta") < 0) {
+		log_error("Name of logical volume %s is too long to be a pool name.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
 	/* LV is not yet a pool, so it's extension from lvcreate */
 	if (!(striped = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
 		return_0;
 
-	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(pool_lv->vg->cmd, NULL, NULL)) {
+	if (activation() && striped->ops->target_present &&
+	    !striped->ops->target_present(pool_lv->vg->cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel.", segtype->name);
+			  "detected in your kernel.", striped->name);
 		return 0;
 	}
 
@@ -432,24 +441,25 @@ int create_pool(struct logical_volume *pool_lv,
 		 * or directly converted to invisible device via suspend/resume
 		 */
 		pool_lv->status |= LV_TEMPORARY;
-		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
-		    /* Clear 4KB of pool metadata device. */
-		    !wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 })) {
-			log_error("Aborting. Failed to wipe pool metadata %s.",
-				  pool_lv->name);
+		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+			log_error("Aborting. Failed to activate pool metadata %s.",
+				  display_lvname(pool_lv));
 			goto bad;
 		}
+		/* Clear 4KB of pool metadata device. */
+		if (!(r = wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 }))) {
+			log_error("Aborting. Failed to wipe pool metadata %s.",
+				  display_lvname(pool_lv));
+		}
 		pool_lv->status &= ~LV_TEMPORARY;
 		/* Deactivates cleared metadata LV */
-		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv))
-			goto_bad;
-	}
-
-	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,
-			(segtype_is_cache_pool(segtype)) ?
-			"cmeta" : "tmeta") < 0) {
-		log_error("Name is too long to be a pool name.");
-		goto bad;
+		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+			log_error("Aborting. Could not deactivate pool metadata %s.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+		if (!r)
+			goto bad;
 	}
 
 	if (!(meta_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
@@ -486,12 +496,7 @@ int create_pool(struct logical_volume *pool_lv,
 
 bad:
 	if (activation()) {
-		if (lv_is_active_locally(pool_lv) &&
-		    deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
-			log_error("Aborting. Could not deactivate pool %s.",
-				  pool_lv->name);
-			return 0;
-		}
+		/* Without activation there was no intermediate commit */
 		if (!lv_remove(pool_lv) ||
 		    !vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 			log_error("Manual intervention may be required to "
@@ -520,6 +525,7 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.stripe_size = stripe_size,
 		.stripes = stripes,
 		.zero = 1,
+		.temporary = 1,
 	};
 
 	dm_list_init(&lvc.tags);


