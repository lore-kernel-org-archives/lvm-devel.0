From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Aug 2014 14:15:06 +0000 (UTC)
Subject: master - cleanup: consolidate lv_layout and lv_role reporting
Message-ID: <20140825141506.EC56B60C42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4e56b28299680783b8375235bdd2bd48a9934e5
Commit:        f4e56b28299680783b8375235bdd2bd48a9934e5
Parent:        2d344c2e4509af34df219a0c9727902ab73b219c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 25 10:02:32 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 25 16:14:40 2014 +0200

cleanup: consolidate lv_layout and lv_role reporting

This patch makes the keyword combinations found in "lv_layout" and
"lv_role" much more understandable - there were some ambiguities
for some of the combinations which lead to confusion before.

Now, the scheme used is:

LAYOUTS ("how the LV is laid out"):
===================================
[linear] (all segments have number of stripes = 1)

[striped] (all segments have number of stripes > 1)

[linear,striped] (mixed linear and striped)

raid (raid layout always reported together with raid level, raid layout == image + metadata LVs underneath that make up raid LV)
  [raid,raid1]
  [raid,raid10]
  [raid,raid4]
  [raid,raid5] (exact sublayout not specified during creation - default one used - raid5_ls)
    [raid,raid5,raid5_ls]
    [raid,raid5,raid6_rs]
    [raid,raid5,raid5_la]
    [raid,raid5,raid5_ra]
  [raid6,raid] (exact sublayout not specified during creation - default one used - raid6_zr)
    [raid,raid6,raid6_zr]
    [raid,raid6,raid6_nc]
    [raid,raid6,raid6_ns]

[mirror] (mirror layout == log + image LVs underneath that make up mirror LV)

thin (thin layout always reported together with sublayout)
  [thin,sparse] (thin layout == allocated out of thin pool)
  [thin,pool] (thin pool layout == data + metadata volumes underneath that make up thin pool LV, not supposed to be used for direct use!!!)

[cache] (cache layout == allocated out of cache pool in conjunction with cache origin)
  [cache,pool] (cache pool layout == data + metadata volumes underneath that make up cache pool LV, not supposed to be used for direct use!!!)

[virtual] (virtual layout == not hitting disk underneath, currently this layout denotes only 'zero' device used for origin,thickorigin role)

[unknown] (either error state or missing recognition for such layout)

ROLES ("what's the purpose or use of the LV - what is its role"):
=================================================================
- each LV has either of these two roles at least:  [public] (public LV that users may use freely to write their data to)

  [public] (public LV that users may use freely to write their data to)
  [private] (private LV that LVM maintains; not supposed to be directly used by user to write his data to)

- and then some special-purpose roles in addition to that:

  [origin,thickorigin] (origin for thick-style snapshot; "thick" as opposed to "thin")
  [origin,multithickorigin] (there are more than 2 thick-style snapshots for this origin)
  [origin,thinorigin] (origin for thin snapshot)
  [origin,multithinorigin] (there are more than 2 thin snapshots for this origin)
  [origin,extorigin] (external origin for thin snapshot)
  [origin,multiextoriginl (there are more than 2 thin snapshots using this external origin)
  [origin,cacheorigin] (cache origin)

  [snapshot,thicksnapshot] (thick-style snapshot; "thick" as opposed to "thin")
  [snapshot,thinsnapshot] (thin-style snapshot)

  [raid,metadata] (raid metadata LV)
  [raid,image] (raid image LV)

  [mirror,image] (mirror image LV)
  [mirror,log] (mirror log LV)
  [pvmove] (pvmove LV)

  [thin,pool,data] (thin pool data LV)
  [thin,pool,metadata] (thin pool metadata LV)

  [cache,pool,data] (cache pool data LV)
  [cache,pool,metadata] (cache pool metadata LV)

  [pool,spare] (pool spare LV - common role of LV that makes it used for both thin and cache repairs)
---
 lib/datastruct/str_list.c |   17 ++-
 lib/datastruct/str_list.h |    1 +
 lib/metadata/lv_manip.c   |  375 +++++++++++++++++++++++++++------------------
 3 files changed, 238 insertions(+), 155 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 3e429ab..feec8b6 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -30,7 +30,7 @@ struct dm_list *str_list_create(struct dm_pool *mem)
 	return sl;
 }
 
-int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str)
+static int _str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str, int as_first)
 {
 	struct dm_str_list *sln;
 
@@ -41,11 +41,24 @@ int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const ch
 		return_0;
 
 	sln->str = str;
-	dm_list_add(sll, &sln->list);
+	if (as_first)
+		dm_list_add_h(sll, &sln->list);
+	else
+		dm_list_add(sll, &sln->list);
 
 	return 1;
 }
 
+int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str)
+{
+	return _str_list_add_no_dup_check(mem, sll, str, 0);
+}
+
+int str_list_add_h_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str)
+{
+	return _str_list_add_no_dup_check(mem, sll, str, 1);
+}
+
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 {
 	if (!str)
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index a052df6..0046fe4 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -22,6 +22,7 @@ struct dm_pool;
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
 int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
+int str_list_add_h_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 45ce19c..fa91c4e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -85,104 +85,129 @@ struct pv_and_int {
 
 enum {
 	LV_TYPE_UNKNOWN,
+	LV_TYPE_PUBLIC,
+	LV_TYPE_PRIVATE,
 	LV_TYPE_LINEAR,
 	LV_TYPE_STRIPED,
 	LV_TYPE_MIRROR,
 	LV_TYPE_RAID,
 	LV_TYPE_THIN,
 	LV_TYPE_CACHE,
+	LV_TYPE_SPARSE,
 	LV_TYPE_ORIGIN,
-	LV_TYPE_MULTIPLE,
+	LV_TYPE_THINORIGIN,
+	LV_TYPE_MULTITHINORIGIN,
+	LV_TYPE_THICKORIGIN,
+	LV_TYPE_MULTITHICKORIGIN,
+	LV_TYPE_CACHEORIGIN,
+	LV_TYPE_EXTTHINORIGIN,
+	LV_TYPE_MULTIEXTTHINORIGIN,
 	LV_TYPE_SNAPSHOT,
+	LV_TYPE_THINSNAPSHOT,
+	LV_TYPE_THICKSNAPSHOT,
 	LV_TYPE_PVMOVE,
 	LV_TYPE_IMAGE,
 	LV_TYPE_LOG,
 	LV_TYPE_METADATA,
 	LV_TYPE_POOL,
 	LV_TYPE_DATA,
-	LV_TYPE_EXTERNAL,
 	LV_TYPE_SPARE,
 	LV_TYPE_VIRTUAL,
-	LV_TYPE_RAID_LEVEL1,
-	LV_TYPE_RAID_LEVEL10,
-	LV_TYPE_RAID_LEVEL4,
-	LV_TYPE_RAID_LEVEL5,
-	LV_TYPE_RAID_LEVEL6,
-	LV_TYPE_RAID_LEFT_ASYMMETRIC,
-	LV_TYPE_RAID_RIGHT_ASYMMETRIC,
-	LV_TYPE_RAID_LEFT_SYMMETRIC,
-	LV_TYPE_RAID_RIGHT_SYMMETRIC,
-	LV_TYPE_RAID_ZERO_RESTART,
-	LV_TYPE_RAID_N_RESTART,
-	LV_TYPE_RAID_N_CONTINUE,
+	LV_TYPE_RAID1,
+	LV_TYPE_RAID10,
+	LV_TYPE_RAID4,
+	LV_TYPE_RAID5,
+	LV_TYPE_RAID5_LA,
+	LV_TYPE_RAID5_RA,
+	LV_TYPE_RAID5_LS,
+	LV_TYPE_RAID5_RS,
+	LV_TYPE_RAID6,
+	LV_TYPE_RAID6_ZR,
+	LV_TYPE_RAID6_NR,
+	LV_TYPE_RAID6_NC,
 };
 
 static const char *_lv_type_names[] = {
 	[LV_TYPE_UNKNOWN] =				"unknown",
+	[LV_TYPE_PUBLIC] =				"public",
+	[LV_TYPE_PRIVATE] =				"private",
 	[LV_TYPE_LINEAR] =				"linear",
 	[LV_TYPE_STRIPED] =				"striped",
 	[LV_TYPE_MIRROR] =				"mirror",
 	[LV_TYPE_RAID] =				"raid",
 	[LV_TYPE_THIN] =				"thin",
 	[LV_TYPE_CACHE] =				"cache",
+	[LV_TYPE_SPARSE] =				"sparse",
 	[LV_TYPE_ORIGIN] =				"origin",
-	[LV_TYPE_MULTIPLE] =				"multiple",
+	[LV_TYPE_THINORIGIN] =				"thinorigin",
+	[LV_TYPE_MULTITHINORIGIN] =			"multithinorigin",
+	[LV_TYPE_THICKORIGIN] =				"thickorigin",
+	[LV_TYPE_MULTITHICKORIGIN] =			"multithickorigin",
+	[LV_TYPE_CACHEORIGIN] =				"cacheorigin",
+	[LV_TYPE_EXTTHINORIGIN] =			"extthinorigin",
+	[LV_TYPE_MULTIEXTTHINORIGIN] =			"multiextthinorigin",
 	[LV_TYPE_SNAPSHOT] =				"snapshot",
+	[LV_TYPE_THINSNAPSHOT] =			"thinsnapshot",
+	[LV_TYPE_THICKSNAPSHOT] =			"thicksnapshot",
 	[LV_TYPE_PVMOVE] =				"pvmove",
 	[LV_TYPE_IMAGE] =				"image",
 	[LV_TYPE_LOG] =					"log",
 	[LV_TYPE_METADATA] =				"metadata",
 	[LV_TYPE_POOL] =				"pool",
 	[LV_TYPE_DATA] =				"data",
-	[LV_TYPE_EXTERNAL] =				"external",
 	[LV_TYPE_SPARE] =				"spare",
 	[LV_TYPE_VIRTUAL] =				"virtual",
-	[LV_TYPE_RAID_LEVEL1] =				"level1",
-	[LV_TYPE_RAID_LEVEL10] =			"level10",
-	[LV_TYPE_RAID_LEVEL4] =				"level4",
-	[LV_TYPE_RAID_LEVEL5] =				"level5",
-	[LV_TYPE_RAID_LEVEL6] =				"level6",
-	[LV_TYPE_RAID_LEFT_ASYMMETRIC] =		"left-asymmetric",
-	[LV_TYPE_RAID_RIGHT_ASYMMETRIC] =		"right-asymmetric",
-	[LV_TYPE_RAID_LEFT_SYMMETRIC] =			"left-symmetric",
-	[LV_TYPE_RAID_RIGHT_SYMMETRIC] =		"right-symmetric",
-	[LV_TYPE_RAID_ZERO_RESTART] =			"zero-restart",
-	[LV_TYPE_RAID_N_RESTART] =			"n-restart",
-	[LV_TYPE_RAID_N_CONTINUE] =			"n-continue",
+	[LV_TYPE_RAID1] =				"raid1",
+	[LV_TYPE_RAID10] =				"raid10",
+	[LV_TYPE_RAID4] =				"raid4",
+	[LV_TYPE_RAID5] =				"raid5",
+	[LV_TYPE_RAID5_LA] =				"raid5_la",
+	[LV_TYPE_RAID5_RA] =				"raid5_ra",
+	[LV_TYPE_RAID5_LS] =				"raid5_ls",
+	[LV_TYPE_RAID5_RS] =				"raid5_rs",
+	[LV_TYPE_RAID6] =				"raid6",
+	[LV_TYPE_RAID6_ZR] =				"raid6_zr",
+	[LV_TYPE_RAID6_NR] =				"raid6_nr",
+	[LV_TYPE_RAID6_NC] =				"raid6_nc",
 };
 
 static int _lv_layout_and_role_mirror(struct dm_pool *mem,
 				      const struct logical_volume *lv,
 				      struct dm_list *layout,
-				      struct dm_list *role)
+				      struct dm_list *role,
+				      int *public_lv)
 {
-	int top_level = 1;
+	int top_level = 0;
 
+	/* non-top-level LVs */
 	if (lv_is_mirror_image(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
 			goto_bad;
-		top_level = 0;
 	} else if (lv_is_mirror_log(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_LOG]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_LOG]))
 			goto_bad;
 		if (lv_is_mirrored(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
-		top_level = 0;
 	} else if (lv->status & PVMOVE) {
 		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_PVMOVE]) ||
-		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]))
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
-	}
+	} else
+		top_level = 1;
 
-	if (top_level) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
-			goto_bad;
-	} else {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]))
-			goto_bad;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
 	}
 
+	/* top-level LVs */
+	if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
+		goto_bad;
+
 	return 1;
 bad:
 	return 0;
@@ -191,69 +216,75 @@ bad:
 static int _lv_layout_and_role_raid(struct dm_pool *mem,
 				    const struct logical_volume *lv,
 				    struct dm_list *layout,
-				    struct dm_list *role)
+				    struct dm_list *role,
+				    int *public_lv)
 {
-	int top_level = 1;
+	int top_level = 0;
 	const char *seg_name;
 
+	/* non-top-level LVs */
 	if (lv_is_raid_image(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_RAID]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
 			goto_bad;
-		top_level = 0;
 	} else if (lv_is_raid_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_RAID]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
-		top_level = 0;
-	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID1)) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL1]))
+	} else
+		top_level = 1;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
+	}
+
+	/* top-level LVs */
+	if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
+		goto_bad;
+
+	if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID1)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID1]))
 			goto_bad;
 	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL10]))
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID10]))
 			goto_bad;
 	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID4)) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL4]))
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID4]))
 			goto_bad;
 	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5))) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL5]))
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5]))
 			goto_bad;
 
 		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LA)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEFT_ASYMMETRIC]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_LA]))
 				goto_bad;
 		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RA)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_RIGHT_ASYMMETRIC]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_RA]))
 				goto_bad;
 		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LS)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEFT_SYMMETRIC]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_LS]))
 				goto_bad;
 		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RS)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_RIGHT_SYMMETRIC]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_RS]))
 				goto_bad;
 		}
 	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6))) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL6]))
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6]))
 			goto_bad;
 
 		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_ZR)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_ZERO_RESTART]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_ZR]))
 				goto_bad;
 		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NR)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_N_RESTART]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_NR]))
 				goto_bad;
 		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NC)) {
-			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_N_CONTINUE]))
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6_NC]))
 				goto_bad;
 		}
 	}
 
-	if (top_level) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
-			goto_bad;
-	} else {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_RAID]))
-			goto_bad;
-	}
-
 	return 1;
 bad:
 	return 0;
@@ -262,46 +293,62 @@ bad:
 static int _lv_layout_and_role_thin(struct dm_pool *mem,
 				    const struct logical_volume *lv,
 				    struct dm_list *layout,
-				    struct dm_list *role)
+				    struct dm_list *role,
+				    int *public_lv)
 {
-	int top_level = 1;
+	int top_level = 0;
 	unsigned snap_count;
 	struct lv_segment *seg;
 
-	if (lv_is_thin_pool(lv)) {
+	/* non-top-level LVs */
+	if (lv_is_thin_pool_metadata(lv)) {
 		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
-			goto_bad;
-	} else if (lv_is_thin_pool_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
-		top_level = 0;
 	} else if (lv_is_thin_pool_data(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_DATA]))
 			goto_bad;
-		top_level = 0;
-	} else if (lv_is_thin_volume(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]))
+	} else
+		top_level = 1;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
+	}
+
+	/* top-level LVs */
+	if (lv_is_thin_volume(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_SPARSE]))
 			goto_bad;
-		if (lv_is_thin_origin(lv, &snap_count) &&
-		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_ORIGIN]))
+		if (lv_is_thin_origin(lv, &snap_count)) {
+			if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+			    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THINORIGIN]))
 				goto_bad;
-		if (snap_count > 1 &&
-		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTIPLE]))
-			goto_bad;
+			if (snap_count > 1 &&
+			    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTITHINORIGIN]))
+				goto_bad;
+		}
 		if ((seg = first_seg(lv)) && (seg->origin || seg->external_lv))
-			if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_SNAPSHOT]))
+			if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_SNAPSHOT]) ||
+			    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THINSNAPSHOT]))
 				goto_bad;
+	} else if (lv_is_thin_pool(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
+			goto_bad;
+		*public_lv = 0;
 	}
 
-	if (top_level) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]))
+	if (lv_is_external_origin(lv)) {
+		if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_EXTTHINORIGIN]))
 			goto_bad;
-	} else {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]))
+		if (lv->external_count > 1 &&
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTIEXTTHINORIGIN]))
 			goto_bad;
 	}
 
@@ -313,35 +360,83 @@ bad:
 static int _lv_layout_and_role_cache(struct dm_pool *mem,
 				     const struct logical_volume *lv,
 				     struct dm_list *layout,
-				     struct dm_list *role)
+				     struct dm_list *role,
+				     int *public_lv)
 {
-	int top_level = 1;
+	int top_level = 0;
 
-	if (lv_is_cache_pool(lv)) {
+	/* non-top-level LVs */
+	if (lv_is_cache_pool_metadata(lv)) {
 		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHE]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
-			goto_bad;
-	} else if (lv_is_cache_pool_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
-		top_level = 0;
 	} else if (lv_is_cache_pool_data(lv)) {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_DATA]))
 			goto_bad;
 		if (lv_is_cache(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 			goto_bad;
-		top_level = 0;
+	} else if (lv_is_cache_origin(lv)) {
+		if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHEORIGIN]))
+			goto_bad;
+		if (lv_is_cache(lv) &&
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
+			goto_bad;
+	} else
+		top_level = 1;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
 	}
 
-	if (top_level) {
-		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
+	/* top-level LVs */
+	if (lv_is_cache(lv) &&
+	    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
+		goto_bad;
+	else if (lv_is_cache_pool(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
-	} else {
-		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHE]))
+		*public_lv = 0;
+	}
+
+	return 1;
+bad:
+	return 0;
+}
+
+static int _lv_layout_and_role_thick_origin_snapshot(struct dm_pool *mem,
+						     const struct logical_volume *lv,
+						     struct dm_list *layout,
+						     struct dm_list *role,
+						     int *public_lv)
+{
+	if (lv_is_origin(lv)) {
+		if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THICKORIGIN]))
+			goto_bad;
+		/*
+		 * Thin volumes are also marked with virtual flag, but we don't show "virtual"
+		 * layout for thin LVs as they have their own keyword for layout - "thin"!
+		 * So rule thin LVs out here!
+		 */
+		if (lv_is_virtual(lv) && !lv_is_thin_volume(lv)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_VIRTUAL]))
+				goto_bad;
+			*public_lv = 0;
+		}
+		if (lv->origin_count > 1 &&
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTITHICKORIGIN]))
+			goto_bad;
+	} else if (lv_is_cow(lv)) {
+		if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_SNAPSHOT]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THICKSNAPSHOT]))
 			goto_bad;
 	}
 
@@ -354,6 +449,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role) {
 	int linear, striped, unknown;
 	struct lv_segment *seg;
+	int public_lv = 1;
 
 	*layout = *role = NULL;
 
@@ -369,62 +465,35 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 
 	/* Mirrors and related */
 	if (lv_is_mirror_type(lv) && !lv_is_raid(lv) &&
-	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role))
+	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
 	/* RAIDs and related */
 	if (lv_is_raid_type(lv) &&
-	    !_lv_layout_and_role_raid(mem, lv, *layout, *role))
+	    !_lv_layout_and_role_raid(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
 	/* Thins and related */
-	if (lv_is_thin_type(lv) &&
-	    !_lv_layout_and_role_thin(mem, lv, *layout, *role))
+	if ((lv_is_thin_type(lv) || lv_is_external_origin(lv)) &&
+	    !_lv_layout_and_role_thin(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
-	if (lv_is_external_origin(lv)) {
-		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]) ||
-		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_EXTERNAL]))
-			goto_bad;
-		if (lv->external_count > 1 &&
-		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_MULTIPLE]))
-			goto_bad;
-		if (!lv_is_thin_volume(lv) &&
-		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_THIN]))
-			goto_bad;
-	}
-
 	/* Caches and related */
-	if (lv_is_cache_type(lv) &&
-	    !_lv_layout_and_role_cache(mem, lv, *layout, *role))
+	if ((lv_is_cache_type(lv) || lv_is_cache_origin(lv)) &&
+	    !_lv_layout_and_role_cache(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
-	if (lv_is_cache_origin(lv)) {
-		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_CACHE]) ||
-		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]))
+	/* Pool-specific */
+	if (lv_is_pool_metadata_spare(lv)) {
+		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SPARE]))
 			goto_bad;
+		public_lv = 0;
 	}
 
-	/* Pool-specific */
-	if (lv_is_pool_metadata_spare(lv) &&
-	    (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_POOL]) ||
-	     !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_METADATA]) ||
-	     !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SPARE])))
-		goto_bad;
-
 	/* Old-style origins/snapshots, virtual origins */
-	if (lv_is_origin(lv)) {
-		str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]);
-		if (lv_is_virtual(lv) &&
-		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_VIRTUAL]))
-			goto_bad;
-		if (lv->origin_count > 1 &&
-		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_MULTIPLE]))
-			goto_bad;
-	} else if (lv_is_cow(lv)) {
-		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SNAPSHOT]))
-			goto_bad;
-	}
+	if (!_lv_layout_and_role_thick_origin_snapshot(mem, lv, *layout, *role, &public_lv))
+		goto_bad;
 
 	/*
 	 * If layout not yet determined, it must be either
@@ -465,14 +534,14 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 			goto_bad;
 	}
 
-	/*
-	 * If role is not defined here yet, it means this is a pure top-level
-	 * device that is not combined with any other type. So just copy what
-	 * we have set for "layout" and use it for "role" too.
-	 */
-	if (dm_list_empty(*role) &&
-	    !str_list_dup(mem, *role, *layout))
-                goto_bad;
+	/* finally, add either 'public' or 'private' role to the LV */
+	if (public_lv) {
+		if (!str_list_add_h_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_PUBLIC]))
+			goto_bad;
+	} else {
+		if (!str_list_add_h_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_PRIVATE]))
+			goto_bad;
+	}
 
 	return 1;
 bad:


