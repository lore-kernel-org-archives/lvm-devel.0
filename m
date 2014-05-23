From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 19:38:48 +0000 (UTC)
Subject: master - cleanup: use directly segtype->name
Message-ID: <20140523193848.3F91660F7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf6b69c46b77f7b61c688b99b2bbaab0c46d840c
Commit:        bf6b69c46b77f7b61c688b99b2bbaab0c46d840c
Parent:        952514611d258f99e29b29daf25e285f9286c60a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 14:24:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 21:36:55 2014 +0200

cleanup: use directly segtype->name

Simplify printing of segtype name.
---
 lib/metadata/lv_manip.c |    1 -
 lib/metadata/merge.c    |   35 ++++++++++-------------------------
 2 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 37c7686..5fa75e1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6116,7 +6116,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 */
 		log_error("Can't create %s without using "
 			  "device-mapper kernel driver.",
-			  seg_is_thin_pool(lp) ? "thin pool volume" :
 			  lp->segtype->name);
 		return NULL;
 	}
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 319df4b..9d6df34 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -194,35 +194,23 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			if (seg_is_pool(seg)) {
 				if (seg->area_count != 1 ||
 				    seg_type(seg, 0) != AREA_LV) {
-					log_error("LV %s: %spool segment %u is missing a pool data LV",
-						  lv->name,
-						  seg_is_thin_pool(seg) ?
-						  "thin " : "cache",
-						  seg_count);
+					log_error("LV %s: %s segment %u is missing a pool data LV",
+						  lv->name, seg->segtype->name, seg_count);
 					inc_error_count;
 				} else if (!(seg2 = first_seg(seg_lv(seg, 0))) || find_pool_seg(seg2) != seg) {
-					log_error("LV %s: %spool segment %u data LV does not refer back to pool LV",
-						  lv->name,
-						  seg_is_thin_pool(seg) ?
-						  "thin " : "cache",
-						  seg_count);
+					log_error("LV %s: %s segment %u data LV does not refer back to pool LV",
+						  lv->name, seg->segtype->name, seg_count);
 					inc_error_count;
 				}
 
 				if (!seg->metadata_lv) {
-					log_error("LV %s: %spool segment %u is missing a pool metadata LV",
-						  lv->name,
-						  seg_is_thin_pool(seg) ?
-						  "thin " : "cache",
-						  seg_count);
+					log_error("LV %s: %s segment %u is missing a pool metadata LV",
+						  lv->name, seg->segtype->name, seg_count);
 					inc_error_count;
 				} else if (!(seg2 = first_seg(seg->metadata_lv)) ||
 					   find_pool_seg(seg2) != seg) {
-					log_error("LV %s: %spool segment %u metadata LV does not refer back to pool LV",
-						  lv->name,
-						  seg_is_thin_pool(seg) ?
-						  "thin " : "cache",
-						  seg_count);
+					log_error("LV %s: %s segment %u metadata LV does not refer back to pool LV",
+						  lv->name, seg->segtype->name, seg_count);
 					inc_error_count;
 				}
 
@@ -232,11 +220,8 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				    (seg_is_cache_pool(seg) &&
 				     ((seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
 				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)))) {
-					log_error("LV %s: %spool segment %u has chunk size %u out of range.",
-						  lv->name,
-						  seg_is_thin_pool(seg) ?
-						  "thin " : "cache",
-						  seg_count, seg->chunk_size);
+					log_error("LV %s: %s segment %u has chunk size %u out of range.",
+						  lv->name, seg->segtype->name, seg_count, seg->chunk_size);
 					inc_error_count;
 				}
 			} else {


