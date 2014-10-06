From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:43 +0000 (UTC)
Subject: master - validation: share more code for pool validation
Message-ID: <20141006133343.6C02E61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c4429900645959966784dd0f0045ec0c4f6233f
Commit:        6c4429900645959966784dd0f0045ec0c4f6233f
Parent:        57a52e787843ce1f370f7e60d2f75f78d9f03d54
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 18:48:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

validation: share more code for pool validation

Reuse thin validation code for cache pool validation.
---
 lib/metadata/merge.c             |    8 ++++----
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 37026d1..0afe596 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -110,7 +110,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 		}
 
-		if (lv_is_thin_pool_data(lv) &&
+		if (lv_is_pool_data(lv) &&
 		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
 		     seg2->area_count != 1 || seg_type(seg2, 0) != AREA_LV ||
 		     seg_lv(seg2, 0) != lv)) {
@@ -119,7 +119,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
-		if (lv_is_thin_pool_metadata(lv) &&
+		if (lv_is_pool_metadata(lv) &&
 		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
 		     seg2->metadata_lv != lv)) {
 			log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
@@ -236,7 +236,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 			} else {
 				if (seg->metadata_lv) {
-					log_error("LV %s: segment %u must not have thin pool metadata LV set",
+					log_error("LV %s: segment %u must not have pool metadata LV set",
 						  lv->name, seg_count);
 					inc_error_count;
 				}
@@ -301,7 +301,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 			} else {
 				if (seg->pool_lv) {
-					log_error("LV %s: segment %u must not have thin pool LV set",
+					log_error("LV %s: segment %u must not have pool LV set",
 						  lv->name, seg_count);
 					inc_error_count;
 				}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f8a84de..4843d2c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -199,6 +199,7 @@
 #define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
 #define lv_is_pool(lv)		(((lv)->status & (CACHE_POOL | THIN_POOL)) ? 1 : 0)
+#define lv_is_pool_data(lv)		(((lv)->status & (CACHE_POOL_DATA | THIN_POOL_DATA)) ? 1 : 0)
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 


