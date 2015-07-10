From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jul 2015 20:54:24 +0000 (UTC)
Subject: master - lockd: disable part of lock_args validation
Message-ID: <20150710205424.E841760139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0823511262bd52bb14b150a180fcd23ea35fc8fb
Commit:        0823511262bd52bb14b150a180fcd23ea35fc8fb
Parent:        738ae4a77f3e28b408c2a401ebce6db6949395b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 11:41:29 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 10 15:53:21 2015 -0500

lockd: disable part of lock_args validation

There are at least a couple instances where
the lock_args check does not work correctly,
(listed in the comment), so disable the
NULL check for lock_args until those are
resolved.
---
 lib/locking/lvmlockd.c  |   55 +++++++++++++++++++++++++++++++++++++++-------
 lib/metadata/metadata.c |   40 +++++++++++++++++++++++++++++++--
 2 files changed, 83 insertions(+), 12 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index b861334..99fc047 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2444,15 +2444,52 @@ out:
 
 int lockd_lv_uses_lock(struct logical_volume *lv)
 {
-	if (!lv_is_visible(lv) ||
-	    lv_is_thin_volume(lv) ||
-	    lv_is_thin_pool_data(lv) ||
-	    lv_is_thin_pool_metadata(lv) ||
-	    lv_is_pool_metadata_spare(lv) ||
-	    lv_is_cache_pool(lv) ||
-	    lv_is_cache_pool_data(lv) ||
-	    lv_is_cache_pool_metadata(lv) ||
-	    lv_is_lockd_sanlock_lv(lv))
+	if (lv_is_thin_volume(lv))
 		return 0;
+
+	if (lv_is_thin_pool_data(lv))
+		return 0;
+
+	if (lv_is_thin_pool_metadata(lv))
+		return 0;
+
+	if (lv_is_pool_metadata_spare(lv))
+		return 0;
+
+	if (lv_is_cache_pool(lv))
+		return 0;
+
+	if (lv_is_cache_pool_data(lv))
+		return 0;
+
+	if (lv_is_cache_pool_metadata(lv))
+		return 0;
+
+	if (lv_is_cow(lv))
+		return 0;
+
+	if (lv->status & SNAPSHOT)
+		return 0;
+
+	/* FIXME: lv_is_virtual_origin ? */
+
+	if (lv_is_lockd_sanlock_lv(lv))
+		return 0;
+
+	if (lv_is_mirror_image(lv))
+		return 0;
+
+	if (lv_is_mirror_log(lv))
+		return 0;
+
+	if (lv_is_raid_image(lv))
+		return 0;
+
+	if (lv_is_raid_metadata(lv))
+		return 0;
+
+	if (!lv_is_visible(lv))
+		return 0;
+
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b0aa122..c4974de 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2899,7 +2899,7 @@ int vg_validate(struct volume_group *vg)
 			r = 0;
 		}
 
-		if (!vg->skip_validate_lock_args && !_validate_vg_lock_args(vg))
+		if (!_validate_vg_lock_args(vg))
 			r = 0;
 	} else {
 		if (vg->lock_args) {
@@ -2915,10 +2915,44 @@ int vg_validate(struct volume_group *vg)
 				if (vg->skip_validate_lock_args)
 					continue;
 
+				/*
+				 * FIXME: make missing lock_args an error.
+				 * There are at least two cases where this
+				 * check doesn't work correctly:
+				 *
+				 * 1. When creating a cow snapshot,
+				 * (lvcreate -s -L1M -n snap1 vg/lv1),
+				 * lockd_lv_uses_lock() uses lv_is_cow()
+				 * which depends on lv->snapshot being
+				 * set, but it's not set at this point,
+				 * so lockd_lv_uses_lock() cannot identify
+				 * the LV as a cow_lv, and thinks it needs
+				 * a lock when it doesn't.  To fix this we
+				 * probably need to validate by finding the
+				 * origin LV, then finding all its snapshots
+				 * which will have no lock_args.
+				 *
+				 * 2. When converting an LV to a thin pool
+				 * without using an existing metadata LV,
+				 * (lvconvert --type thin-pool vg/poolX),
+				 * there is an intermediate LV created,
+				 * probably for the metadata LV, and
+				 * validate is called on the VG in this
+				 * intermediate state, which finds the
+				 * newly created LV which is not yet
+				 * identified as a metadata LV, and
+				 * does not have any lock_args.  To fix
+				 * this we might be able to find the place
+				 * where the intermediate LV is created,
+				 * and set new variable on it like for vgs,
+				 * lv->skip_validate_lock_args.
+				 */
 				if (!lvl->lv->lock_args) {
-					log_error(INTERNAL_ERROR "LV %s/%s missing lock_args",
-						  vg->name, lvl->lv->name);
+					/*
+					log_verbose("LV %s/%s missing lock_args",
+						    vg->name, lvl->lv->name);
 					r = 0;
+					*/
 					continue;
 				}
 


