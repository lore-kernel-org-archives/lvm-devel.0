From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  4 Aug 2016 00:26:18 +0000 (UTC)
Subject: master - striped: Add precise macros for original segtype.
Message-ID: <20160804002619.05B1760DAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a15abe865c7087de5505388e9757623da282311
Commit:        4a15abe865c7087de5505388e9757623da282311
Parent:        5c3141a8b9f2a4d67ca50674bc1bfec20fdc9e09
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 4 01:24:39 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 4 01:24:39 2016 +0100

striped: Add precise macros for original segtype.

The existing striped macros include raid0 segments.
---
 lib/metadata/raid_manip.c |    8 ++++----
 lib/metadata/segtype.h    |    4 ++++
 lib/striped/striped.c     |    2 +-
 tools/lvconvert.c         |    3 +--
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9da05e5..1c03d37 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2253,7 +2253,7 @@ static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 {
 	log_error("Converting the segment type for %s from %s to %s is not supported.",
 		  display_lvname(lv), lvseg_name(first_seg(lv)),
-		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		  (segtype_is_striped_target(new_segtype) &&
 		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	return 0;
@@ -2263,7 +2263,7 @@ static int _takeover_unsupported_yet(const struct logical_volume *lv, const unsi
 {
 	log_error("Converting the segment type for %s from %s to %s is not supported yet.",
 		  display_lvname(lv), lvseg_name(first_seg(lv)),
-		  (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		  (segtype_is_striped_target(new_segtype) &&
 		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	return 0;
@@ -2701,7 +2701,7 @@ static unsigned _segtype_ix(const struct segment_type *segtype, uint32_t area_co
 	int i = 2, j;
 
 	/* Linear special case */
-	if (segtype_is_striped(segtype) && !segtype_is_any_raid0(segtype)) {
+	if (segtype_is_striped_target(segtype)) {
 		if (area_count == 1)
 			return 0;	/* linear */
 		return 1;	/* striped */
@@ -2772,7 +2772,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	log_verbose("Converting %s from %s to %s.",
 		    display_lvname(lv), lvseg_name(first_seg(lv)),
-		    (segtype_is_striped(new_segtype) && !segtype_is_any_raid0(new_segtype) &&
+		    (segtype_is_striped_target(new_segtype) &&
 		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
 	/* FIXME If not active, prompt and activate */
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index bf7c5eb..0da2d94 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -68,6 +68,8 @@ struct dev_manager;
 #define SEG_RAID6_N_6		0x0000000800000000ULL
 #define SEG_RAID6		SEG_RAID6_ZR
 
+#define SEG_STRIPED_TARGET	0x0000008000000000ULL
+
 #define SEG_UNKNOWN		0x8000000000000000ULL
 
 #define SEG_TYPE_NAME_LINEAR		"linear"
@@ -98,6 +100,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID6_ZR		"raid6_zr"
 
 #define segtype_is_linear(segtype)	(!strcmp(segtype->name, SEG_TYPE_NAME_LINEAR))
+#define segtype_is_striped_target(segtype)	((segtype)->flags & SEG_STRIPED_TARGET ? 1 : 0)
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -137,6 +140,7 @@ struct dev_manager;
 	  segtype_is_thin(segtype) || segtype_is_snapshot(segtype) || \
 	  (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
 
+#define seg_is_striped_target(seg)	segtype_is_striped_target((seg)->segtype)
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 530e48e..7d19786 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -233,7 +233,7 @@ struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 
 	segtype->ops = &_striped_ops;
 	segtype->name = SEG_TYPE_NAME_STRIPED;
-	segtype->flags =
+	segtype->flags = SEG_STRIPED_TARGET |
 	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED | SEG_FORMAT1_SUPPORT;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0aac89e..8ea293d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1925,8 +1925,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (!seg_is_striped(seg) && !seg_is_any_raid0(seg) &&
-		    !lv_raid_percent(lv, &sync_percent)) {
+		if (!seg_is_striped(seg) && !lv_raid_percent(lv, &sync_percent)) {
 			log_error("Unable to determine sync status of %s.",
 				  display_lvname(lv));
 			return 0;


