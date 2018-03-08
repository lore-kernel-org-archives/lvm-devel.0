From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Mar 2018 04:43:15 -0500
Subject: master - cache: fix lock usage for cache conversion
Message-ID: <201803080943.w289hF8v019655@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee37838b1149f3f8d5c34dc2d459421f8e085bbb
Commit:        ee37838b1149f3f8d5c34dc2d459421f8e085bbb
Parent:        7421252edccead6ce395cabc361ed175236bcb5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 10:30:46 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 8 10:39:47 2018 +0100

cache: fix lock usage for cache conversion

Just like with lvcreate, this lvconvert case also need to properly
check which LV actually holds lock for cached origin - as it might
be i.e. thin-pool tdata subLV.
---
 lib/metadata/lv_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bde2a00..9566f3e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7384,6 +7384,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct logical_volume *lv, *origin_lv = NULL;
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *tmp_lv;
+	const struct logical_volume *lock_lv;
 	struct lv_segment *seg, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 	int historical;
@@ -7547,11 +7548,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		/* Validate cache origin is exclusively active */
+		lock_lv = lv_lock_holder(origin_lv);
 		if (vg_is_clustered(origin_lv->vg) &&
 		    locking_is_clustered() &&
 		    locking_supports_remote_queries() &&
-		    lv_is_active(origin_lv) &&
-		    !lv_is_active_exclusive(origin_lv)) {
+		    lv_is_active(lock_lv) &&
+		    !lv_is_active_exclusive(lock_lv)) {
 			log_error("Cannot cache not exclusively active origin volume %s.",
 				  display_lvname(origin_lv));
 			return NULL;


