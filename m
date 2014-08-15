From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 12:53:48 +0000 (UTC)
Subject: master - Add lv_layout_and_type fn, lv_layout and lv_type reporting fields.
Message-ID: <20140815125348.E11B560D9F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8bbcda2a3a6799ff4e967276f9284c8b808584c
Commit:        e8bbcda2a3a6799ff4e967276f9284c8b808584c
Parent:        8a7682cbc982004e880a740d61ca5d12f0caf769
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 13 10:03:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 14:50:38 2014 +0200

Add lv_layout_and_type fn, lv_layout and lv_type reporting fields.

The lv_layout and lv_type fields together help with LV identification.
We can do basic identification using the lv_attr field which provides
 very condensed view. In contrast to that, the new lv_layout and lv_type
fields provide more detialed information on exact layout and type used
for LVs.

For top-level LVs which are pure types not combined with any
other LV types, the lv_layout value is equal to lv_type value.

For non-top-level LVs which may be combined with other types,
the lv_layout describes the underlying layout used, while the
lv_type describes the use/type/usage of the LV.

These two new fields are both string lists so selection (-S/--select)
criteria can be defined using the list operators easily:
  [] for strict matching
  {} for subset matching.

For example, let's consider this:

$ lvs -a -o name,vg_name,lv_attr,layout,type
  LV                    VG     Attr       Layout       Type
  [lvol1_pmspare]       vg     ewi------- linear       metadata,pool,spare
  pool                  vg     twi-a-tz-- pool,thin    pool,thin
  [pool_tdata]          vg     rwi-aor--- level10,raid data,pool,thin
  [pool_tdata_rimage_0] vg     iwi-aor--- linear       image,raid
  [pool_tdata_rimage_1] vg     iwi-aor--- linear       image,raid
  [pool_tdata_rimage_2] vg     iwi-aor--- linear       image,raid
  [pool_tdata_rimage_3] vg     iwi-aor--- linear       image,raid
  [pool_tdata_rmeta_0]  vg     ewi-aor--- linear       metadata,raid
  [pool_tdata_rmeta_1]  vg     ewi-aor--- linear       metadata,raid
  [pool_tdata_rmeta_2]  vg     ewi-aor--- linear       metadata,raid
  [pool_tdata_rmeta_3]  vg     ewi-aor--- linear       metadata,raid
  [pool_tmeta]          vg     ewi-aor--- level1,raid  metadata,pool,thin
  [pool_tmeta_rimage_0] vg     iwi-aor--- linear       image,raid
  [pool_tmeta_rimage_1] vg     iwi-aor--- linear       image,raid
  [pool_tmeta_rmeta_0]  vg     ewi-aor--- linear       metadata,raid
  [pool_tmeta_rmeta_1]  vg     ewi-aor--- linear       metadata,raid
  thin_snap1            vg     Vwi---tz-k thin         snapshot,thin
  thin_snap2            vg     Vwi---tz-k thin         snapshot,thin
  thin_vol1             vg     Vwi-a-tz-- thin         thin
  thin_vol2             vg     Vwi-a-tz-- thin         multiple,origin,thin

Which is a situation with thin pool, thin volumes and thin snapshots.
We can see internal 'pool_tdata' volume that makes up thin pool has
actually a level10 raid layout and the internal 'pool_tmeta' has
level1 raid layout. Also, we can see that 'thin_snap1' and 'thin_snap2'
are both thin snapshots while 'thin_vol1' is thin origin (having
multiple snapshots).

Such reporting scheme provides much better base for selection criteria
in addition to providing more detailed information, for example:

$ lvs -a -o name,vg_name,lv_attr,layout,type -S 'type=metadata'
LV                   VG   Attr       Layout      Type
[lvol1_pmspare]      vg   ewi------- linear      metadata,pool,spare
[pool_tdata_rmeta_0] vg   ewi-aor--- linear      metadata,raid
[pool_tdata_rmeta_1] vg   ewi-aor--- linear      metadata,raid
[pool_tdata_rmeta_2] vg   ewi-aor--- linear      metadata,raid
[pool_tdata_rmeta_3] vg   ewi-aor--- linear      metadata,raid
[pool_tmeta]         vg   ewi-aor--- level1,raid metadata,pool,thin
[pool_tmeta_rmeta_0] vg   ewi-aor--- linear      metadata,raid
[pool_tmeta_rmeta_1] vg   ewi-aor--- linear      metadata,raid

(selected all LVs which are related to metadata of any type)

lvs -a -o name,vg_name,lv_attr,layout,type -S 'type={metadata,thin}'
LV           VG   Attr       Layout      Type
[pool_tmeta] vg   ewi-aor--- level1,raid metadata,pool,thin

(selected all LVs which hold metadata related to thin)

lvs -a -o name,vg_name,lv_attr,layout,type -S 'type={thin,snapshot}'
LV         VG   Attr       Layout     Type
thin_snap1 vg   Vwi---tz-k thin       snapshot,thin
thin_snap2 vg   Vwi---tz-k thin       snapshot,thin

(selected all LVs which are thin snapshots)

lvs -a -o name,vg_name,lv_attr,layout,type -S 'layout=raid'
LV           VG   Attr       Layout       Type
[pool_tdata] vg   rwi-aor--- level10,raid data,pool,thin
[pool_tmeta] vg   ewi-aor--- level1,raid  metadata,pool,thin

(selected all LVs with raid layout, any raid layout)

lvs -a -o name,vg_name,lv_attr,layout,type -S 'layout={raid,level1}'
  LV           VG   Attr       Layout      Type
  [pool_tmeta] vg   ewi-aor--- level1,raid metadata,pool,thin

(selected all LVs with raid level1 layout exactly)

And so on...
---
 WHATS_NEW                        |    1 +
 lib/datastruct/str_list.c        |   18 +-
 lib/datastruct/str_list.h        |    1 +
 lib/metadata/lv_manip.c          |  485 ++++++++++++++++++++++++++++---------
 lib/metadata/metadata-exported.h |   11 +-
 lib/metadata/thin_manip.c        |   18 +-
 lib/report/columns.h             |    6 +-
 lib/report/properties.c          |    8 +-
 lib/report/report.c              |   61 ++---
 9 files changed, 434 insertions(+), 175 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f6a877d..e5d4d6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Add lv_layout and lv_type LV reporting fields.
   Properly display lvs lv_attr volume type and target type bit for cache origin.
   Fix pvcreate_check() to update cache correctly after signature wiping.
   Fix primary device lookup failure for partition when processing mpath filter.
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index f519679..3e429ab 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -30,17 +30,13 @@ struct dm_list *str_list_create(struct dm_pool *mem)
 	return sl;
 }
 
-int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
+int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str)
 {
 	struct dm_str_list *sln;
 
 	if (!str)
 		return_0;
 
-	/* Already in list? */
-	if (str_list_match_item(sll, str))
-		return 1;
-
 	if (!(sln = dm_pool_alloc(mem, sizeof(*sln))))
 		return_0;
 
@@ -50,6 +46,18 @@ int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 	return 1;
 }
 
+int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
+{
+	if (!str)
+		return_0;
+
+	/* Already in list? */
+	if (str_list_match_item(sll, str))
+		return 1;
+
+	return str_list_add_no_dup_check(mem, sll, str);
+}
+
 void str_list_del(struct dm_list *sll, const char *str)
 {
 	struct dm_list *slh, *slht;
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 82141e1..a052df6 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -21,6 +21,7 @@ struct dm_pool;
 
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
+int str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3e1f9e9..35b898f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -83,146 +83,395 @@ struct pv_and_int {
 	int *i;
 };
 
-typedef enum {
+enum {
 	LV_TYPE_UNKNOWN,
-	LV_TYPE_PVMOVE,
-	LV_TYPE_ORIGIN,
-	LV_TYPE_EXTERNAL_ORIGIN,
-	LV_TYPE_SNAPSHOT,
+	LV_TYPE_LINEAR,
+	LV_TYPE_STRIPED,
+	LV_TYPE_MIRROR,
+	LV_TYPE_RAID,
 	LV_TYPE_THIN,
-	LV_TYPE_THIN_SNAPSHOT,
-	LV_TYPE_THIN_POOL,
-	LV_TYPE_THIN_POOL_DATA,
-	LV_TYPE_THIN_POOL_METADATA,
 	LV_TYPE_CACHE,
-	LV_TYPE_CACHE_POOL,
-	LV_TYPE_CACHE_POOL_DATA,
-	LV_TYPE_CACHE_POOL_METADATA,
-	LV_TYPE_POOL_METADATA_SPARE,
+	LV_TYPE_ORIGIN,
+	LV_TYPE_MULTIPLE,
+	LV_TYPE_SNAPSHOT,
+	LV_TYPE_PVMOVE,
+	LV_TYPE_IMAGE,
+	LV_TYPE_LOG,
+	LV_TYPE_METADATA,
+	LV_TYPE_POOL,
+	LV_TYPE_DATA,
+	LV_TYPE_EXTERNAL,
+	LV_TYPE_SPARE,
 	LV_TYPE_VIRTUAL,
-	LV_TYPE_RAID,
-	LV_TYPE_RAID_IMAGE,
-	LV_TYPE_RAID_METADATA,
-	LV_TYPE_MIRROR,
-	LV_TYPE_MIRROR_IMAGE,
-	LV_TYPE_MIRROR_LOG,
-	LV_TYPE_LINEAR,
-	LV_TYPE_STRIPED
-} lv_type_t;
+	LV_TYPE_RAID_LEVEL1,
+	LV_TYPE_RAID_LEVEL10,
+	LV_TYPE_RAID_LEVEL4,
+	LV_TYPE_RAID_LEVEL5,
+	LV_TYPE_RAID_LEVEL6,
+	LV_TYPE_RAID_LEFT_ASYMMETRIC,
+	LV_TYPE_RAID_RIGHT_ASYMMETRIC,
+	LV_TYPE_RAID_LEFT_SYMMETRIC,
+	LV_TYPE_RAID_RIGHT_SYMMETRIC,
+	LV_TYPE_RAID_ZERO_RESTART,
+	LV_TYPE_RAID_N_RESTART,
+	LV_TYPE_RAID_N_CONTINUE,
+};
 
 static const char *_lv_type_names[] = {
-	[LV_TYPE_UNKNOWN] =                     "unknown",
-	[LV_TYPE_PVMOVE] =                      "pvmove",
-	[LV_TYPE_ORIGIN] =                      "origin",
-	[LV_TYPE_EXTERNAL_ORIGIN] =             "external-origin",
-	[LV_TYPE_SNAPSHOT] =                    "snapshot",
-	[LV_TYPE_THIN] =                        "thin",
-	[LV_TYPE_THIN_SNAPSHOT] =               "thin-snapshot",
-	[LV_TYPE_THIN_POOL] =                   "thin-pool",
-	[LV_TYPE_THIN_POOL_DATA] =              "thin-pool-data",
-	[LV_TYPE_THIN_POOL_METADATA] =          "thin-pool-metadata",
-	[LV_TYPE_CACHE] =                       "cache",
-	[LV_TYPE_CACHE_POOL] =                  "cache-pool",
-	[LV_TYPE_CACHE_POOL_DATA] =             "cache-pool-data",
-	[LV_TYPE_CACHE_POOL_METADATA] =         "cache-pool-metadata",
-	[LV_TYPE_POOL_METADATA_SPARE] =         "pool-metadata-spare",
-	[LV_TYPE_VIRTUAL] =                     "virtual",
-	[LV_TYPE_RAID] =                        "raid",
-	[LV_TYPE_RAID_IMAGE] =                  "raid-image",
-	[LV_TYPE_RAID_METADATA] =               "raid-metadata",
-	[LV_TYPE_MIRROR] =                      "mirror",
-	[LV_TYPE_MIRROR_IMAGE] =                "mirror-image",
-	[LV_TYPE_MIRROR_LOG] =                  "mirror-log",
-	[LV_TYPE_LINEAR] =                      "linear",
-	[LV_TYPE_STRIPED] =                     "striped"
+	[LV_TYPE_UNKNOWN] =				"unknown",
+	[LV_TYPE_LINEAR] =				"linear",
+	[LV_TYPE_STRIPED] =				"striped",
+	[LV_TYPE_MIRROR] =				"mirror",
+	[LV_TYPE_RAID] =				"raid",
+	[LV_TYPE_THIN] =				"thin",
+	[LV_TYPE_CACHE] =				"cache",
+	[LV_TYPE_ORIGIN] =				"origin",
+	[LV_TYPE_MULTIPLE] =				"multiple",
+	[LV_TYPE_SNAPSHOT] =				"snapshot",
+	[LV_TYPE_PVMOVE] =				"pvmove",
+	[LV_TYPE_IMAGE] =				"image",
+	[LV_TYPE_LOG] =					"log",
+	[LV_TYPE_METADATA] =				"metadata",
+	[LV_TYPE_POOL] =				"pool",
+	[LV_TYPE_DATA] =				"data",
+	[LV_TYPE_EXTERNAL] =				"external",
+	[LV_TYPE_SPARE] =				"spare",
+	[LV_TYPE_VIRTUAL] =				"virtual",
+	[LV_TYPE_RAID_LEVEL1] =				"level1",
+	[LV_TYPE_RAID_LEVEL10] =			"level10",
+	[LV_TYPE_RAID_LEVEL4] =				"level4",
+	[LV_TYPE_RAID_LEVEL5] =				"level5",
+	[LV_TYPE_RAID_LEVEL6] =				"level6",
+	[LV_TYPE_RAID_LEFT_ASYMMETRIC] =		"left-asymmetric",
+	[LV_TYPE_RAID_RIGHT_ASYMMETRIC] =		"right-asymmetric",
+	[LV_TYPE_RAID_LEFT_SYMMETRIC] =			"left-symmetric",
+	[LV_TYPE_RAID_RIGHT_SYMMETRIC] =		"right-symmetric",
+	[LV_TYPE_RAID_ZERO_RESTART] =			"zero-restart",
+	[LV_TYPE_RAID_N_RESTART] =			"n-restart",
+	[LV_TYPE_RAID_N_CONTINUE] =			"n-continue",
 };
 
-static lv_type_t _get_lv_type(const struct logical_volume *lv)
+const char *lv_type_name(const struct logical_volume *lv)
 {
-	lv_type_t type = LV_TYPE_UNKNOWN;
-	struct lv_segment *seg;
+	return " ";
+}
 
-	if (lv->status & PVMOVE)
-		type = LV_TYPE_PVMOVE;
-	else if (lv_is_origin(lv))
-		type = LV_TYPE_ORIGIN;
-	else if (lv_is_external_origin(lv))
-		type = LV_TYPE_EXTERNAL_ORIGIN;
-	else if (lv_is_cow(lv))
-		type = LV_TYPE_SNAPSHOT;
-	else if (lv_is_thin_volume(lv))
-		type = first_seg(lv)->origin ? LV_TYPE_THIN_SNAPSHOT : LV_TYPE_THIN;
-	else if (lv_is_thin_pool(lv))
-		type = LV_TYPE_THIN_POOL;
-	else if (lv_is_thin_pool_data(lv))
-		type = LV_TYPE_THIN_POOL_DATA;
-	else if (lv_is_thin_pool_metadata(lv))
-		type = LV_TYPE_THIN_POOL_METADATA;
-	else if (lv_is_pool_metadata_spare(lv))
-		type = LV_TYPE_POOL_METADATA_SPARE;
-	else if (lv_is_cache(lv))
-		type = LV_TYPE_CACHE;
-	else if (lv_is_cache_pool(lv))
-		type = LV_TYPE_CACHE_POOL;
-	else if (lv_is_cache_pool_data(lv))
-		type = LV_TYPE_CACHE_POOL_DATA;
-	else if (lv_is_cache_pool_metadata(lv))
-		type = LV_TYPE_CACHE_POOL_METADATA;
-	else if (lv_is_virtual(lv))
-		type = LV_TYPE_VIRTUAL;
-	else if (lv_is_raid(lv))
-		type = LV_TYPE_RAID;
-	else if (lv_is_raid_image(lv))
-		type = LV_TYPE_RAID_IMAGE;
-	else if (lv_is_raid_metadata(lv))
-		type = LV_TYPE_RAID_METADATA;
-	else if (lv_is_mirrored(lv))
-		type = LV_TYPE_MIRROR;
-	else if (lv_is_mirror_image(lv))
-		type = LV_TYPE_MIRROR_IMAGE;
-	else if (lv_is_mirror_log(lv))
-		type = LV_TYPE_MIRROR_LOG;
-
-	/* none of the above, check linear... */
-	if (type == LV_TYPE_UNKNOWN) {
-		type = LV_TYPE_LINEAR;
-		dm_list_iterate_items(seg, &lv->segments) {
-			if (!seg_is_linear(seg)) {
-				type = LV_TYPE_UNKNOWN;
-				break;
-			}
-		}
+static int _lv_type_list_mirror(struct dm_pool *mem,
+				const struct logical_volume *lv,
+				struct dm_list *layout,
+				struct dm_list *type)
+{
+	int top_level = 1;
+
+	if (lv_is_mirror_image(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_IMAGE]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv_is_mirror_log(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_LOG]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv->status & PVMOVE) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_PVMOVE]))
+			goto_bad;
 	}
 
-	/* ...if not even linear, check striped... */
-	if (type == LV_TYPE_UNKNOWN) {
-		type = LV_TYPE_STRIPED;
-		dm_list_iterate_items(seg, &lv->segments) {
-			if (!seg_is_striped(seg)) {
-				type = LV_TYPE_UNKNOWN;
-				break;
-			}
-		}
+	if (top_level) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
+			goto_bad;
+	} else {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MIRROR]))
+			goto_bad;
 	}
 
-	return type;
+	return 1;
+bad:
+	return 0;
 }
 
-const char *lv_type_name(const struct logical_volume *lv) {
-	lv_type_t type = _get_lv_type(lv);
-	return _lv_type_names[type];
+static int _lv_type_list_raid(struct dm_pool *mem,
+			      const struct logical_volume *lv,
+			      struct dm_list *layout,
+			      struct dm_list *type)
+{
+	int top_level = 1;
+	const char *seg_name;
+
+	if (lv_is_raid_image(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_IMAGE]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv_is_raid_metadata(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+			goto_bad;
+		top_level = 0;
+	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID1)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL1]))
+			goto_bad;
+	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL10]))
+			goto_bad;
+	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID4)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL4]))
+			goto_bad;
+	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5))) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL5]))
+			goto_bad;
+
+		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LA)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEFT_ASYMMETRIC]))
+				goto_bad;
+		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RA)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_RIGHT_ASYMMETRIC]))
+				goto_bad;
+		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_LS)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEFT_SYMMETRIC]))
+				goto_bad;
+		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID5_RS)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_RIGHT_SYMMETRIC]))
+				goto_bad;
+		}
+	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6))) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_LEVEL6]))
+			goto_bad;
+
+		if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_ZR)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_ZERO_RESTART]))
+				goto_bad;
+		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NR)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_N_RESTART]))
+				goto_bad;
+		} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID6_NC)) {
+			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID_N_CONTINUE]))
+				goto_bad;
+		}
+	}
+
+	if (top_level) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
+			goto_bad;
+	} else {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_RAID]))
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	return 0;
 }
 
-int lv_is_linear(const struct logical_volume *lv)
+static int _lv_type_list_thin(struct dm_pool *mem,
+			      const struct logical_volume *lv,
+			      struct dm_list *layout,
+			      struct dm_list *type)
 {
-	lv_type_t type = _get_lv_type(lv);
-	return type == LV_TYPE_LINEAR;
+	int top_level = 1;
+	unsigned snapshot_count;
+
+	if (lv_is_thin_pool(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
+			goto_bad;
+	} else if (lv_is_thin_pool_metadata(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv_is_thin_pool_data(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_DATA]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv_is_thin_volume(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]))
+			goto_bad;
+		if (lv_is_thin_origin(lv, &snapshot_count) &&
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_ORIGIN]))
+				goto_bad;
+		if (snapshot_count > 1 &&
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MULTIPLE]))
+			goto_bad;
+		if (first_seg(lv)->origin)
+			if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_SNAPSHOT]))
+				goto_bad;
+	}
+
+	if (lv_is_external_origin(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_EXTERNAL]))
+			goto_bad;
+		top_level = 0;
+	}
+
+	if (top_level) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]))
+			goto_bad;
+	} else {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]))
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	return 0;
 }
 
-int lv_is_striped(const struct logical_volume *lv)
+static int _lv_type_list_cache(struct dm_pool *mem,
+			       const struct logical_volume *lv,
+			       struct dm_list *layout,
+			       struct dm_list *type)
 {
-	lv_type_t type = _get_lv_type(lv);
-	return type == LV_TYPE_STRIPED;
+	int top_level = 1;
+
+	if (lv_is_cache_pool(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
+			goto_bad;
+	} else if (lv_is_cache_pool_metadata(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+			goto_bad;
+		top_level = 0;
+	} else if (lv_is_cache_pool_data(lv)) {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_DATA]))
+			goto_bad;
+		top_level = 0;
+	}
+
+	if (top_level) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
+			goto_bad;
+	} else {
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_CACHE]))
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	return 0;
+}
+
+int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
+		       struct dm_list **layout, struct dm_list **type) {
+	int linear, striped, unknown;
+	struct lv_segment *seg;
+
+	*layout = *type = NULL;
+
+	if (!(*layout = str_list_create(mem))) {
+		log_error("LV layout list allocation failed");
+		goto bad;
+	}
+
+	if (!(*type = str_list_create(mem))) {
+		log_error("LV type list allocation failed");
+		goto bad;
+	}
+
+	/* Mirrors and related */
+	if (lv_is_mirror_type(lv) && !lv_is_raid(lv) &&
+	    !_lv_type_list_mirror(mem, lv, *layout, *type))
+		goto_bad;
+
+	/* RAIDs and related */
+	if (lv_is_raid_type(lv) &&
+	    !_lv_type_list_raid(mem, lv, *layout, *type))
+		goto_bad;
+
+	/* Thins and related */
+	if ((lv_is_thin_type(lv) || lv_is_external_origin(lv)) &&
+	    !_lv_type_list_thin(mem, lv, *layout, *type))
+		goto_bad;
+
+	/* Caches and related */
+	if (lv_is_cache_type(lv) &&
+	    !_lv_type_list_cache(mem, lv, *layout, *type))
+		goto_bad;
+
+	if (lv_is_cache_origin(lv)) {
+		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]))
+			goto_bad;
+	}
+
+	/* Pool-specific */
+	if (lv_is_pool_metadata_spare(lv) &&
+	    (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_POOL]) ||
+	     !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_METADATA]) ||
+	     !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_SPARE])))
+		goto_bad;
+
+	/* Old-style origins/snapshots, virtual origins */
+	if (lv_is_origin(lv)) {
+		str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]);
+		if (lv_is_virtual(lv) &&
+		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_VIRTUAL]))
+			goto_bad;
+		if (lv->origin_count > 1 &&
+		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_MULTIPLE]))
+			goto_bad;
+	} else if (lv_is_cow(lv)) {
+		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_SNAPSHOT]))
+			goto_bad;
+	}
+
+	/*
+	 * If layout not yet determined, it must be either
+	 * linear or striped or mixture of these two.
+	 */
+	if (dm_list_empty(*layout)) {
+		linear = striped = unknown = 0;
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (seg_is_linear(seg))
+				linear = 1;
+			else if (seg_is_striped(seg))
+				striped = 1;
+			else {
+				/*
+				 * This should not happen but if it does
+				 * we'll see that there's "unknown" layout
+				 * present. This means we forgot to detect
+				 * the type above and we need add proper
+				 * detection for such type!
+				 */
+				unknown = 1;
+				log_error(INTERNAL_ERROR "Failed to properly detect "
+					  "layout and type for for LV %s/%s",
+					  lv->vg->name, lv->name);
+			}
+		}
+
+		if (linear &&
+		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_LINEAR]))
+			goto_bad;
+
+		if (striped &&
+		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_STRIPED]))
+			goto_bad;
+
+		if (!linear && !striped &&
+		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_UNKNOWN]))
+			goto_bad;
+	}
+
+	/*
+	 * If type is not defined here yet, it means this is a pure top-level
+	 * device that is not combined with any other type. So just copy what
+	 * we have set for "layout" and use it for "type" too.
+	 */
+	if (dm_list_empty(*type))
+		str_list_dup(mem, *type, *layout);
+
+	return 1;
+bad:
+	if (*type)
+		dm_pool_free(mem, *type);
+	if (*layout)
+		dm_pool_free(mem, *layout);
+	return 0;
 }
 
 static int _lv_is_on_pv(struct logical_volume *lv, void *data)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 497e59c..59d68d6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -191,6 +191,9 @@
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & (POOL_METADATA_SPARE)) ? 1 : 0)
 
+int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
+		       struct dm_list **layout, struct dm_list **type);
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	AREA_UNASSIGNED,
@@ -911,17 +914,11 @@ struct lv_segment *last_seg(const struct logical_volume *lv);
 const char *lv_type_name(const struct logical_volume *lv);
 
 /*
- * Useful function to determine linear and striped volumes.
- */
-int lv_is_linear(const struct logical_volume *lv);
-int lv_is_striped(const struct logical_volume *lv);
-
-/*
 * Useful functions for managing snapshots.
 */
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
-int lv_is_thin_origin(const struct logical_volume *lv);
+int lv_is_thin_origin(const struct logical_volume *lv, unsigned *snapshot_count);
 int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 7d86187..b4da500 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -500,18 +500,28 @@ const char *get_pool_discards_name(thin_discards_t discards)
 	return "unknown";
 }
 
-int lv_is_thin_origin(const struct logical_volume *lv)
+int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snapshot_count)
 {
 	struct seg_list *segl;
+	int r = 0;
+
+	if (snapshot_count)
+		*snapshot_count = 0;
 
 	if (!lv_is_thin_volume(lv) ||
 	    dm_list_empty(&lv->segs_using_this_lv))
 		return 0;
 
 	dm_list_iterate_items(segl, &lv->segs_using_this_lv) {
-		if (segl->seg->origin == lv)
-			return 1;
+		if (segl->seg->origin == lv) {
+			r = 1;
+			if (snapshot_count)
+				(*snapshot_count)++;
+			else
+				/* not interested in number of snapshots */
+				break;
+		}
 	}
 
-	return 0;
+	return r;
 }
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 1761a6d..d203f3d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -39,7 +39,8 @@ FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Bla
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
-//FIELD(LVS, lv, STR, "Type", lvid, 10, lvvolumetype, lv_volume_type, "LV volume type.", 0)
+FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
+FIELD(LVS, lv, STR_LIST, "Type", lvid, 10, lvtype, lv_type, "LV type.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
 FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Set if mirror/RAID image is synchronized.", 0)
 FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Set if snapshot LV is being merged to origin.", 0)
@@ -49,7 +50,6 @@ FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_loc
 FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV has fixed minor number assigned.", 0)
 FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
 FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
-//FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kernel target type the LV is related to.", 0)
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
@@ -148,7 +148,7 @@ FIELD(VGS, vg, SIZ, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata a
 FIELD(VGS, vg, SIZ, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
 
-FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
+FIELD(SEGS, seg, STR, "SegType", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripesize, "For stripes, amount of data placed on one device before switching to the next.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 3be44f2..eac8c2c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -179,8 +179,10 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _vg_clustered_set prop_not_implemented_set
 #define _vg_clustered_get prop_not_implemented_get
 
-//#define _lv_volume_type_set prop_not_implemented_set
-//#define _lv_volume_type_get prop_not_implemented_get
+#define _lv_layout_set prop_not_implemented_set
+#define _lv_layout_get prop_not_implemented_get
+#define _lv_type_set prop_not_implemented_set
+#define _lv_type_get prop_not_implemented_get
 #define _lv_initial_image_sync_set prop_not_implemented_set
 #define _lv_initial_image_sync_get prop_not_implemented_get
 #define _lv_image_synced_get prop_not_implemented_get
@@ -216,8 +218,6 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_inactive_table_get prop_not_implemented_get
 #define _lv_device_open_set prop_not_implemented_set
 #define _lv_device_open_get prop_not_implemented_get
-//#define _lv_target_type_set prop_not_implemented_set
-//#define _lv_target_type_get prop_not_implemented_get
 #define _lv_health_status_set prop_not_implemented_set
 #define _lv_health_status_get prop_not_implemented_get
 #define _lv_skip_activation_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 842a1a5..69151e0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1318,15 +1318,37 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered_y), private);
 }
 
-/* FIXME Replace with something that provides a complete unique description for every combination.
-static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct dm_list *lv_layout;
+	struct dm_list *lv_type;
+
+	if (!lv_layout_and_type(mem, lv, &lv_layout, &lv_type)) {
+		log_error("Failed to display layout for LV %s/%s.", lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return _field_set_string_list(rh, field, lv_layout, private);
+}
+
+static int _lvtype_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
 {
-	const char *type = lv_type_name((const struct logical_volume *) data);
-	return _string_disp(rh, mem, field, &type, private);
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct dm_list *lv_layout;
+	struct dm_list *lv_type;
+
+	if (!lv_layout_and_type(mem, lv, &lv_layout, &lv_type)) {
+		log_error("Failed to display type for LV %s/%s.", lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return _field_set_string_list(rh, field, lv_type, private);
 }
-*/
 
 static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 				    struct dm_report_field *field,
@@ -1605,35 +1627,6 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_undef_disp(rh, mem, field, private);
 }
 
-/* FIXME Replace with something that provides a complete unique description for every combination.
-static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
-			      struct dm_report_field *field,
-			      const void *data, void *private)
-{
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *target_type = "unknown";
-
-	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
-		target_type = "thin";
-	else if (lv_is_cache_type(lv))
-		target_type = "cache";
-	else if (lv_is_raid_type(lv))
-		target_type = "raid";
-	else if (lv_is_mirror_type(lv))
-		target_type = "mirror";
-	else if (lv_is_cow(lv) || lv_is_origin(lv))
-		target_type = "snapshot";
-	else if (lv_is_virtual(lv))
-		target_type = "virtual";
-	else if (lv_is_linear(lv))
-		target_type = "linear";
-	else if (lv_is_striped(lv))
-		target_type = "striped";
-
-	return _string_disp(rh, mem, field, &target_type, private);
-}
-*/
-
 static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)


