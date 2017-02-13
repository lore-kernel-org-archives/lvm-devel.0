From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:51 +0000 (UTC)
Subject: master - cleanup: fix warning about shadowed declaration
Message-ID: <20170213091451.C4F8B60E73@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a39c828c01f747696a6e042df48da62ec0e1ba75
Commit:        a39c828c01f747696a6e042df48da62ec0e1ba75
Parent:        717d0c6b94c81730582eb3000d77f585eeca6569
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 17:47:35 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:18 2017 +0100

cleanup: fix warning about shadowed declaration

Avoid shadowing lv_size as lv_size() is already defined function in lv.h
---
 lib/metadata/lv_manip.c          |    5 +++--
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/raid_manip.c        |    4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dfeb3ad..01ab96b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4089,6 +4089,7 @@ int lv_extend(struct logical_volume *lv,
 	uint32_t sub_lv_count;
 	uint32_t old_extents;
 	uint32_t new_extents;	/* Total logical size after extension. */
+	uint64_t raid_size;
 
 	log_very_verbose("Adding segment of type %s to LV %s.", segtype->name, lv->name);
 
@@ -4111,7 +4112,7 @@ int lv_extend(struct logical_volume *lv,
 	/* FIXME log_count should be 1 for mirrors */
 
 	if (segtype_is_raid(segtype) && !segtype_is_any_raid0(segtype)) {
-		uint64_t lv_size = ((uint64_t) lv->le_count + extents) * lv->vg->extent_size;
+		raid_size = ((uint64_t) lv->le_count + extents) * lv->vg->extent_size;
 
 		/*
 		 * The MD bitmap is limited to being able to track 2^21 regions.
@@ -4119,7 +4120,7 @@ int lv_extend(struct logical_volume *lv,
 		 * unless raid0/raid0_meta, which doesn't have a bitmap.
 		 */
 
-		region_size = raid_ensure_min_region_size(lv, lv_size, region_size);
+		region_size = raid_ensure_min_region_size(lv, raid_size, region_size);
 
 		if (first_seg(lv))
 			first_seg(lv)->region_size = region_size;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 05771d8..5fe169c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1222,7 +1222,7 @@ uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
 				  uint32_t region_size, uint32_t extent_size);
 uint32_t raid_rimage_extents(const struct segment_type *segtype,
 			     uint32_t extents, uint32_t stripes, uint32_t data_copies);
-uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t lv_size, uint32_t region_size);
+uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t raid_size, uint32_t region_size);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0f0631f..eaafd65 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -55,9 +55,9 @@ static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned n
  *
  * Pass in @lv_size, because funcion can be called with an empty @lv.
  */
-uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t lv_size, uint32_t region_size)
+uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t raid_size, uint32_t region_size)
 {
-	uint32_t min_region_size = lv_size / (1 << 21);
+	uint32_t min_region_size = raid_size / (1 << 21);
 	uint32_t region_size_sav = region_size;
 
 	while (region_size < min_region_size)


