From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:29 +0000 (UTC)
Subject: master - lvcreate: check for lv type and created segtype
Message-ID: <20160505220129.491D060C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3b15674df99a2dd17b5205b850606d80a155df7
Commit:        d3b15674df99a2dd17b5205b850606d80a155df7
Parent:        d0111563c2ffd4026ea45dc38c97d4210d903889
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 15:02:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:34:35 2016 +0200

lvcreate: check for lv type and created segtype

When creating LV - in some case we change created segment type
(ATM for cache and snapshot) and we then manipulate with
lv segment according to 'lp' segtype.
Fix this by checking for proper type before accessing segment members.

This makes command like:

lvcreate --type cache-pool -L10 vg/cpool
lvcreate -H -L10 --cachesettings migtation_threshold=10000  vg/cpool

to pass since now tool correctly selects default cache policy.
---
 lib/metadata/lv_manip.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cd0a78c..2969d2a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7370,7 +7370,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->wipe_signatures = 0;
 	}
 
-	if (!seg_is_virtual(lp) && !lp->approx_alloc &&
+	if (!segtype_is_virtual(create_segtype) && !lp->approx_alloc &&
 	    (vg->free_count < lp->extents)) {
 		log_error("Volume group \"%s\" has insufficient free space "
 			  "(%u extents): %u required.",
@@ -7382,7 +7382,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 
-	if (pool_lv && seg_is_thin_volume(lp)) {
+	if (pool_lv && segtype_is_thin_volume(create_segtype)) {
 		/* Ensure all stacked messages are submitted */
 		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
 		    !update_pool_lv(pool_lv, 1))
@@ -7398,7 +7398,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		log_debug_metadata("Setting read ahead sectors %u.", lv->read_ahead);
 	}
 
-	if (!seg_is_pool(lp) && lp->minor >= 0) {
+	if (!segtype_is_pool(create_segtype) && lp->minor >= 0) {
 		lv->major = lp->major;
 		lv->minor = lp->minor;
 		lv->status |= FIXED_MINOR;
@@ -7419,15 +7419,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!lv_extend(lv, create_segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
-		       seg_is_pool(lp) ? lp->pool_metadata_extents : lp->region_size,
-		       seg_is_thin_volume(lp) ? lp->virtual_extents : lp->extents,
+		       segtype_is_pool(create_segtype) ? lp->pool_metadata_extents : lp->region_size,
+		       segtype_is_thin_volume(create_segtype) ? lp->virtual_extents : lp->extents,
 		       lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
-	if (seg_is_cache_pool(lp) || seg_is_cache(lp)) {
+	if (lv_is_cache_pool(lv) || lv_is_cache(lv)) {
 		if (!cache_set_mode(first_seg(lv), lp->cache_mode)) {
 			stack;
 			goto revert_new_lv;
@@ -7448,10 +7448,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				goto revert_new_lv;
 			}
 		}
-	} else if (seg_is_raid(lp)) {
+	} else if (lv_is_raid(lv)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
-	} else if (seg_is_thin_pool(lp)) {
+	} else if (lv_is_thin_pool(lv)) {
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
 		first_seg(lv)->discards = lp->discards;
@@ -7462,7 +7462,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		if (lp->error_when_full)
 			lv->status |= LV_ERROR_WHEN_FULL;
-	} else if (pool_lv && seg_is_thin_volume(lp)) {
+	} else if (pool_lv && lv_is_virtual(lv)) { /* going to be a thin volume */
 		seg = first_seg(lv);
 		pool_seg = first_seg(pool_lv);
 		if (!(seg->device_id = get_free_pool_device_id(pool_seg)))


