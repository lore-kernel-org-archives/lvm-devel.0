From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:38 +0000 (UTC)
Subject: master - libdm: add stats group and region iterators and properties
Message-ID: <20160705185438.553E8602F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1f2df7bc0a219afebb86823513516e002a2916f
Commit:        f1f2df7bc0a219afebb86823513516e002a2916f
Parent:        62050760aa15e7059ea768b81abcd4d773ed6cab
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 13:30:46 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: add stats group and region iterators and properties

Add support do dm_stats_walk*() to walk over the set of
available groups using the cursor embedded in the dm_stats
handle, and to obtain the type of the object at the current
stats cursor location. A set of flags is introduced to
control which objects are visited:

    DM_STATS_WALK_AREA
    DM_STATS_WALK_REGION
    DM_STATS_WALK_GROUP
    DM_STATS_WALK_ALL

A final flag suppresses visits to regions that contain only a
single area - since the aggregate of such a region is idential
to the area it contains this allows these duplicates to be
filtered out:

    DM_STATS_WALK_SKIP_SINGLE_AREA

If flags are not initialised before beginning a walk the default
set matches the behaviour of previous versions of the library.

Also accept group identifiers as immediate arguments to the
counter, metric, and property functions by adding control
flags to the region and area identifiers passed in.

Region and area properties are mapped to their equivalents for
the group (for example: group size is reported as the sum of
all regions contained in the group). Counter and metric values
are aggregated for the region or group.
---
 WHATS_NEW_DM                        |    4 +-
 libdm/.exported_symbols.DM_1_02_129 |    3 +
 libdm/libdevmapper.h                |  127 +++++++-
 libdm/libdm-stats.c                 |  585 +++++++++++++++++++++++++++++++----
 4 files changed, 641 insertions(+), 78 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 853dd00..04ba142 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,7 +1,9 @@
 Version 1.02.129 - 
 =================================
+  Add dm_stats_get_object_type() to return the type of object present.
+  Add dm_stats_walk_init() allowing control of objects visited by walks.
   Add dm_stats_get_group_descriptor() to return the member list as a string.
-  Add dm_stats_get_nr_groups() and dm_stats_group_present().
+  Introduce dm_stats_get_nr_groups() and dm_stats_group_present().
   Add dm_stats_{get,set}_alias() to set and retrieve alias names for groups.
   Add dm_stats_get_group_id() to return the group ID for a given region.
   Add dm_stats_{create,delete}_group() to allow grouping of stats regions.
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
index 46c706d..88d3f1b 100644
--- a/libdm/.exported_symbols.DM_1_02_129
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -1,5 +1,6 @@
 dm_bitset_parse_list
 dm_stats_create_group
+dm_stats_current_object_type
 dm_stats_delete_group
 dm_stats_get_alias
 dm_stats_get_counter
@@ -8,4 +9,6 @@ dm_stats_get_group_id
 dm_stats_get_metric
 dm_stats_get_nr_groups
 dm_stats_group_present
+dm_stats_object_type
 dm_stats_set_alias
+dm_stats_walk_init
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 17f88a8..a1db12a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -935,38 +935,97 @@ const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
 const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
 					 uint64_t region_id);
 
+typedef enum {
+	DM_STATS_OBJECT_TYPE_NONE,
+	DM_STATS_OBJECT_TYPE_AREA,
+	DM_STATS_OBJECT_TYPE_REGION,
+	DM_STATS_OBJECT_TYPE_GROUP
+} dm_stats_obj_type_t;
+
 /*
  * Statistics cursor
  *
  * A dm_stats handle maintains an optional cursor into the statistics
- * regions and areas that it stores. Iterators are provided to visit
- * each region, or each area in a handle and accessor methods are
- * provided to obtain properties and values for the region or area
- * at the current cursor position.
+ * tables that it stores. Iterators are provided to visit each region,
+ * area, or group in a handle and accessor methods are provided to
+ * obtain properties and values for the object at the current cursor
+ * position.
+ *
+ * Using the cursor simplifies walking all regions or groups when
+ * the tables are sparse (i.e. contains some present and some
+ * non-present region_id or group_id values either due to program_id
+ * filtering or the ordering of region and group creation and deletion).
+ *
+ * Simple macros are provided to visit each area, region, or group,
+ * contained in a handle and applications are encouraged to use these
+ * where possible.
+ */
+
+/*
+ * Walk flags are used to initialise a dm_stats handle's cursor control
+ * and to select region or group aggregation when calling a metric or
+ * counter property method with immediate group, region, and area ID
+ * values.
  *
- * Using the cursor simplifies walking all regions or areas when the
- * region table is sparse (i.e. contains some present and some
- * non-present region_id values either due to program_id filtering
- * or the ordering of region creation and deletion).
+ * Walk flags are stored in the uppermost word of a uint64_t so that
+ * a region_id or group_id may be encoded in the lower bits. This
+ * allows an aggregate region_id or group_id to be specified when
+ * retrieving counter or metric values.
+ *
+ * Flags may be ORred together when used to initialise a dm_stats_walk:
+ * the resulting walk will visit instance of each type specified by
+ * the flag combination.
+ */
+#define DM_STATS_WALK_AREA   0x1000000000000
+#define DM_STATS_WALK_REGION 0x2000000000000
+#define DM_STATS_WALK_GROUP  0x4000000000000
+
+#define DM_STATS_WALK_ALL    0x7000000000000
+#define DM_STATS_WALK_DEFAULT (DM_STATS_WALK_AREA | DM_STATS_WALK_REGION)
+
+/*
+ * Skip regions from a DM_STATS_WALK_REGION that contain only a single
+ * area: in this case the region's aggregate values are identical to
+ * the values of the single contained area. Setting this flag will
+ * suppress these duplicate entries during a dm_stats_walk_* with the
+ * DM_STATS_WALK_REGION flag set.
+ */
+#define DM_STATS_WALK_SKIP_SINGLE_AREA   0x8000000000000
+
+/*
+ * Initialise the cursor control of a dm_stats handle for the specified
+ * walk type(s). Including a walk flag in the flags argument will cause
+ * any subsequent walk to visit that type of object (until the next
+ * call to dm_stats_walk_init()).
  */
+int dm_stats_walk_init(struct dm_stats *dms, uint64_t flags);
 
 /*
- * Initialise the cursor of a dm_stats handle to address the first
- * present region. It is valid to attempt to walk a NULL stats handle
- * or a handle containing no present regions; in this case any call to
- * dm_stats_walk_next() becomes a no-op and all calls to
- * dm_stats_walk_end() return true.
+ * Set the cursor of a dm_stats handle to address the first present
+ * group, region, or area of the currently configured walk. It is
+ * valid to attempt to walk a NULL stats handle or a handle containing
+ * no present regions; in this case any call to dm_stats_walk_next()
+ * becomes a no-op and all calls to dm_stats_walk_end() return true.
  */
 void dm_stats_walk_start(struct dm_stats *dms);
 
 /*
  * Advance the statistics cursor to the next area, or to the next
- * present region if at the end of the current region.
+ * present region if at the end of the current region. If the end of
+ * the region, area, or group tables is reached a subsequent call to
+ * dm_stats_walk_end() will return 1 and dm_stats_object_type() called
+ * on the location will return DM_STATS_OBJECT_TYPE_NONE,
  */
 void dm_stats_walk_next(struct dm_stats *dms);
 
 /*
- * Advance the statistics cursor to the next region.
+ * Force the statistics cursor to advance to the next region. This will
+ * stop any in-progress area walk (by clearing DM_STATS_WALK_AREA) and
+ * advance the cursor to the next present region, the first present
+ * group (if DM_STATS_GROUP_WALK is set), or to the end. In this case a
+ * subsequent call to dm_stats_walk_end() will return 1 and a call to
+ * dm_stats_object_type() for the location will return
+ * DM_STATS_OBJECT_TYPE_NONE.
  */
 void dm_stats_walk_next_region(struct dm_stats *dms);
 
@@ -976,6 +1035,24 @@ void dm_stats_walk_next_region(struct dm_stats *dms);
 int dm_stats_walk_end(struct dm_stats *dms);
 
 /*
+ * Return the type of object at the location specified by region_id
+ * and area_id. If either region_id or area_id uses one of the special
+ * values DM_STATS_REGION_CURRENT or DM_STATS_AREA_CURRENT the
+ * corresponding region or area identifier will be taken from the
+ * current cursor location. If the cursor location or the value encoded
+ * by region_id and area_id indicates an aggregate region or group,
+ * this will be reflected in the value returned.
+ */
+dm_stats_obj_type_t dm_stats_object_type(const struct dm_stats *dms,
+					 uint64_t region_id,
+					 uint64_t area_id);
+
+/*
+ * Return the type of object at the current stats cursor location.
+ */
+dm_stats_obj_type_t dm_stats_current_object_type(const struct dm_stats *dms);
+
+/*
  * Stats iterators
  *
  * C 'for' and 'do'/'while' style iterators for dm_stats data.
@@ -996,7 +1073,8 @@ int dm_stats_walk_end(struct dm_stats *dms);
  * executed.
  */
 #define dm_stats_foreach_region(dms)				\
-for (dm_stats_walk_start((dms));				\
+for (dm_stats_walk_init((dms), DM_STATS_WALK_REGION),		\
+     dm_stats_walk_start((dms));				\
      !dm_stats_walk_end((dms)); dm_stats_walk_next_region((dms)))
 
 /*
@@ -1006,10 +1084,24 @@ for (dm_stats_walk_start((dms));				\
  * be executed.
  */
 #define dm_stats_foreach_area(dms)				\
-for (dm_stats_walk_start((dms));				\
+for (dm_stats_walk_init((dms), DM_STATS_WALK_AREA),		\
+     dm_stats_walk_start((dms));				\
      !dm_stats_walk_end((dms)); dm_stats_walk_next((dms)))
 
 /*
+ * Iterate over the regions table visiting each group. Metric and
+ * counter methods will return values for the group.
+ *
+ * If the group table is empty or unpopulated the loop body will not
+ * be executed.
+ */
+#define dm_stats_foreach_group(dms)				\
+for (dm_stats_walk_init((dms), DM_STATS_WALK_GROUP),		\
+     dm_stats_group_walk_start(dms);				\
+     !dm_stats_group_walk_end(dms);				\
+     dm_stats_group_walk_next(dms))
+
+/*
  * Start a walk iterating over the regions contained in dm_stats handle
  * 'dms'.
  *
@@ -1132,6 +1224,7 @@ int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id,
  */
 const char *dm_stats_get_alias(const struct dm_stats *dms, uint64_t id);
 
+#define DM_STATS_GROUP_NONE UINT64_MAX
 /*
  * Return the group_id that the specified region_id belongs to, or the
  * special value DM_STATS_GROUP_NONE if the region does not belong
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index dcde991..4911b62 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -17,7 +17,7 @@
 #include "math.h" /* log10() */
 
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
-#define DM_STATS_GROUP_NOT_PRESENT UINT64_MAX
+#define DM_STATS_GROUP_NOT_PRESENT DM_STATS_GROUP_NONE
 
 #define NSEC_PER_USEC   1000L
 #define NSEC_PER_MSEC   1000000L
@@ -104,6 +104,9 @@ struct dm_stats {
 	struct dm_stats_region *regions;
 	struct dm_stats_group *groups;
 	/* statistics cursor */
+	uint64_t walk_flags; /* walk control flags */
+	uint64_t cur_flags;
+	uint64_t cur_group;
 	uint64_t cur_region;
 	uint64_t cur_area;
 };
@@ -195,6 +198,9 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	dms->max_region = DM_STATS_REGION_NOT_PRESENT;
 	dms->regions = NULL;
 
+	/* maintain compatibility with earlier walk version */
+	dms->walk_flags = dms->cur_flags = DM_STATS_WALK_DEFAULT;
+
 	return dms;
 
 bad:
@@ -1267,104 +1273,354 @@ bad:
 	return 0;
 }
 
-static void _stats_walk_next(const struct dm_stats *dms, int skip_region,
-			     uint64_t *cur_r, uint64_t *cur_a)
+static void _stats_walk_next_present(const struct dm_stats *dms,
+				     uint64_t *flags,
+				     uint64_t *cur_r, uint64_t *cur_a,
+				     uint64_t *cur_g)
 {
-	struct dm_stats_region *cur;
-	int present;
+	struct dm_stats_region *cur = NULL;
+
+	/* start of walk: region loop advances *cur_r to 0. */
+	if (*cur_r != DM_STATS_REGION_NOT_PRESENT)
+		cur = &dms->regions[*cur_r];
 
+	/* within current region? */
+	if (cur && (*flags & DM_STATS_WALK_AREA)) {
+		if (++(*cur_a) < _nr_areas_region(cur))
+			return;
+		else
+			*cur_a = 0;
+	}
+
+	/* advance to next present, non-skipped region or end */
+	while (++(*cur_r) <= dms->max_region) {
+		cur = &dms->regions[*cur_r];
+		if (!_stats_region_present(cur))
+			continue;
+		if ((*flags & DM_STATS_WALK_SKIP_SINGLE_AREA))
+			if (!(*flags & DM_STATS_WALK_AREA))
+				if (_nr_areas_region(cur) < 2)
+					continue;
+		/* matching region found */
+		break;
+	}
+	return;
+}
+
+static void _stats_walk_next(const struct dm_stats *dms, uint64_t *flags,
+			     uint64_t *cur_r, uint64_t *cur_a, uint64_t *cur_g)
+{
 	if (!dms || !dms->regions)
 		return;
 
-	cur = dms->regions + *cur_r;
-	present = _stats_region_present(cur);
+	if (*flags & DM_STATS_WALK_AREA) {
+		/* advance to next area, region, or end */
+		_stats_walk_next_present(dms, flags, cur_r, cur_a, cur_g);
+		return;
+	}
 
-	if (skip_region && present)
-		*cur_a = _nr_areas_region(cur);
+	if (*flags & DM_STATS_WALK_REGION) {
+		/* enable region aggregation */
+		*cur_a = DM_STATS_WALK_REGION;
+		_stats_walk_next_present(dms, flags, cur_r, cur_a, cur_g);
+		return;
+	}
 
-	if (skip_region || !present || ++(*cur_a) == _nr_areas_region(cur)) {
-		*cur_a = 0;
-		while(!dm_stats_region_present(dms, ++(*cur_r))
-		      && *cur_r < dms->max_region)
-			; /* keep walking until a present region is found
-			   * or the end of the table is reached. */
+	if (*flags & DM_STATS_WALK_GROUP) {
+		/* enable group aggregation */
+		*cur_r = *cur_a = DM_STATS_WALK_GROUP;
+		while (!_stats_group_id_present(dms, ++(*cur_g))
+		       && (*cur_g) < dms->max_region + 1)
+			; /* advance to next present group or end */
+		return;
 	}
+
+	log_error("stats_walk_next called with empty walk flags");
 }
 
-static void _stats_walk_start(const struct dm_stats *dms,
-			      uint64_t *cur_r, uint64_t *cur_a)
+static void _group_walk_start(const struct dm_stats *dms, uint64_t *flags,
+			      uint64_t *cur_r, uint64_t *cur_a, uint64_t *cur_g)
 {
-	if (!dms || !dms->regions)
+	if (!(*flags & DM_STATS_WALK_GROUP))
+		return;
+
+	*cur_a = *cur_r = DM_STATS_WALK_GROUP;
+	*cur_g = 0;
+
+	/* advance to next present group or end */
+	while ((*cur_g) <= dms->max_region) {
+	        if (_stats_region_is_grouped(dms, *cur_g))
+			break;
+		(*cur_g)++;
+	}
+
+	if (*cur_g > dms->max_region)
+		/* no groups to walk */
+		*flags &= ~DM_STATS_WALK_GROUP;
+}
+
+static void _stats_walk_start(const struct dm_stats *dms, uint64_t *flags,
+			      uint64_t *cur_r, uint64_t *cur_a,
+			      uint64_t *cur_g)
+{
+	log_debug("starting stats walk with %s %s %s %s",
+		  (*flags & DM_STATS_WALK_AREA) ? "AREA" : "",
+		  (*flags & DM_STATS_WALK_REGION) ? "REGION" : "",
+		  (*flags & DM_STATS_WALK_GROUP) ? "GROUP" : "",
+		  (*flags & DM_STATS_WALK_SKIP_SINGLE_AREA) ? "SKIP" : "");
+
+	if (!dms->regions)
 		return;
 
-	*cur_r = 0;
+	if (!(*flags & (DM_STATS_WALK_AREA | DM_STATS_WALK_REGION)))
+		return _group_walk_start(dms, flags, cur_r, cur_a, cur_g);
+
+	/* initialise cursor state */
 	*cur_a = 0;
+	*cur_r = DM_STATS_REGION_NOT_PRESENT;
+	*cur_g = DM_STATS_GROUP_NOT_PRESENT;
+
+	if (!(*flags & DM_STATS_WALK_AREA))
+		*cur_a = DM_STATS_WALK_REGION;
 
-	/* advance to the first present region */
-	if (!dm_stats_region_present(dms, dms->cur_region))
-		_stats_walk_next(dms, 0, cur_r, cur_a);
+	/* advance to first present, non-skipped region */
+	_stats_walk_next_present(dms, flags, cur_r, cur_a, cur_g);
+}
+
+#define DM_STATS_WALK_MASK (DM_STATS_WALK_AREA			\
+			    | DM_STATS_WALK_REGION		\
+			    | DM_STATS_WALK_GROUP		\
+			    | DM_STATS_WALK_SKIP_SINGLE_AREA)
+
+int dm_stats_walk_init(struct dm_stats *dms, uint64_t flags)
+{
+	if (!dms)
+		return_0;
+
+	if (flags & ~DM_STATS_WALK_MASK) {
+		log_error("Unknown value in walk flags: 0x" FMTx64,
+			  flags & ~DM_STATS_WALK_MASK);
+		return 0;
+	}
+	dms->walk_flags = flags;
+	log_debug("dm_stats_walk_init: initialised flags to " FMTx64, flags);
+	return 1;
 }
 
 void dm_stats_walk_start(struct dm_stats *dms)
 {
-	_stats_walk_start(dms, &dms->cur_region, &dms->cur_area);
+	if (!dms || !dms->regions)
+		return;
+
+	dms->cur_flags = dms->walk_flags;
+
+	_stats_walk_start(dms, &dms->cur_flags,
+			  &dms->cur_region, &dms->cur_area,
+			  &dms->cur_group);
 }
 
 void dm_stats_walk_next(struct dm_stats *dms)
 {
-	_stats_walk_next(dms, 0, &dms->cur_region, &dms->cur_area);
+	_stats_walk_next(dms, &dms->cur_flags,
+			 &dms->cur_region, &dms->cur_area,
+			 &dms->cur_group);
 }
 
 void dm_stats_walk_next_region(struct dm_stats *dms)
 {
-	_stats_walk_next(dms, 1, &dms->cur_region, &dms->cur_area);
+	dms->cur_flags &= ~DM_STATS_WALK_AREA;
+	_stats_walk_next(dms, &dms->cur_flags,
+			 &dms->cur_region, &dms->cur_area,
+			 &dms->cur_group);
 }
 
-static int _stats_walk_end(const struct dm_stats *dms,
-			   uint64_t *cur_r, uint64_t *cur_a)
+/*
+ * Return 1 if any regions remain that are present and not skipped
+ * by the current walk flags or 0 otherwise.
+ */
+static uint64_t _stats_walk_any_unskipped(const struct dm_stats *dms,
+					  uint64_t *flags,
+					  uint64_t *cur_r, uint64_t *cur_a)
 {
-	struct dm_stats_region *region = NULL;
-	int end = 0;
+	struct dm_stats_region *region;
+	uint64_t i;
+
+	if (*cur_r > dms->max_region)
+		return 0;
 
+	for (i = *cur_r; i <= dms->max_region; i++) {
+		region = &dms->regions[i];
+		if (!_stats_region_present(region))
+			continue;
+		if ((*flags & DM_STATS_WALK_SKIP_SINGLE_AREA)
+		    && !(*flags & DM_STATS_WALK_AREA))
+			if (_nr_areas_region(region) < 2)
+				continue;
+		return 1;
+	}
+	return 0;
+}
+
+static void _stats_walk_end_areas(const struct dm_stats *dms, uint64_t *flags,
+				  uint64_t *cur_r, uint64_t *cur_a,
+				  uint64_t *cur_g)
+{
+	int end = !_stats_walk_any_unskipped(dms, flags, cur_r, cur_a);
+
+	if (!(*flags & DM_STATS_WALK_AREA))
+		return;
+
+	if (!end)
+		return;
+
+	*flags &= ~DM_STATS_WALK_AREA;
+	if (*flags & DM_STATS_WALK_REGION) {
+		/* start region walk */
+		*cur_a = DM_STATS_WALK_REGION;
+		*cur_r = DM_STATS_REGION_NOT_PRESENT;
+		_stats_walk_next_present(dms, flags, cur_r, cur_a, cur_g);
+		if (!_stats_walk_any_unskipped(dms, flags, cur_r, cur_a))
+			/* no more regions */
+			*flags &= ~DM_STATS_WALK_REGION;
+			if (!(*flags & DM_STATS_WALK_GROUP))
+				*cur_r = dms->max_region;
+	}
+
+	if (*flags & DM_STATS_WALK_REGION)
+		return;
+
+	if (*flags & DM_STATS_WALK_GROUP)
+		_group_walk_start(dms, flags, cur_r, cur_a, cur_g);
+}
+
+static int _stats_walk_end(const struct dm_stats *dms, uint64_t *flags,
+			   uint64_t *cur_r, uint64_t *cur_a, uint64_t *cur_g)
+{
 	if (!dms || !dms->regions)
 		return 1;
 
-	region = &dms->regions[*cur_r];
-	end = (*cur_r > dms->max_region
-	       || (*cur_r == dms->max_region
-		&& *cur_a >= _nr_areas_region(region)));
+	if (*flags & DM_STATS_WALK_AREA) {
+		_stats_walk_end_areas(dms, flags, cur_r, cur_a, cur_g);
+		goto out;
+	}
+
+	if (*flags & DM_STATS_WALK_REGION) {
+		if (!_stats_walk_any_unskipped(dms, flags, cur_r, cur_a)) {
+			*flags &= ~DM_STATS_WALK_REGION;
+			_group_walk_start(dms, flags, cur_r, cur_a, cur_g);
+		}
+		goto out;
+	}
 
-	return end;
+	if (*flags & DM_STATS_WALK_GROUP) {
+		if (*cur_g < dms->max_region)
+			goto out;
+		*flags &= ~DM_STATS_WALK_GROUP;
+	}
+out:
+	return !(*flags & ~DM_STATS_WALK_SKIP_SINGLE_AREA);
 }
 
 int dm_stats_walk_end(struct dm_stats *dms)
 {
-	return _stats_walk_end(dms, &dms->cur_region, &dms->cur_area);
+	if (_stats_walk_end(dms, &dms->cur_flags,
+			    &dms->cur_region, &dms->cur_area,
+			    &dms->cur_group)) {
+		dms->cur_flags = dms->walk_flags;
+		return 1;
+	}
+	return 0;
+}
+
+dm_stats_obj_type_t dm_stats_object_type(const struct dm_stats *dms,
+					 uint64_t region_id,
+					 uint64_t area_id)
+{
+	uint64_t group_id;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_AREA_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	if (region_id == DM_STATS_REGION_NOT_PRESENT)
+		/* no region */
+		return DM_STATS_OBJECT_TYPE_NONE;
+
+	if (region_id & DM_STATS_WALK_GROUP) {
+		if (region_id == DM_STATS_WALK_GROUP)
+			/* indirect group_id from cursor */
+			group_id = dms->cur_group;
+		else
+			/* immediate group_id encoded in region_id */
+			group_id = region_id & ~DM_STATS_WALK_GROUP;
+		if (!_stats_group_id_present(dms, group_id))
+			return DM_STATS_OBJECT_TYPE_NONE;
+		return DM_STATS_OBJECT_TYPE_GROUP;
+	}
+
+	if (region_id > dms->max_region)
+		/* end of table */
+		return DM_STATS_OBJECT_TYPE_NONE;
+
+	if (area_id & DM_STATS_WALK_REGION)
+		/* aggregate region */
+		return DM_STATS_OBJECT_TYPE_REGION;
+
+	/* plain region_id and area_id */
+	return DM_STATS_OBJECT_TYPE_AREA;
+}
+
+dm_stats_obj_type_t dm_stats_current_object_type(const struct dm_stats *dms)
+{
+	/* dm_stats_object_type will decode region/area */
+	return dm_stats_object_type(dms,
+				    DM_STATS_REGION_CURRENT,
+				    DM_STATS_AREA_CURRENT);
 }
 
 uint64_t dm_stats_get_region_nr_areas(const struct dm_stats *dms,
 				      uint64_t region_id)
 {
-	struct dm_stats_region *region = &dms->regions[region_id];
+	struct dm_stats_region *region = NULL;
+
+	/* groups or aggregate regions cannot be subdivided */
+	if (region_id & DM_STATS_WALK_GROUP)
+		return 1;
+
+	region = &dms->regions[region_id];
 	return _nr_areas_region(region);
 }
 
 uint64_t dm_stats_get_current_nr_areas(const struct dm_stats *dms)
 {
+	/* groups or aggregate regions cannot be subdivided */
+	if (dms->cur_region & DM_STATS_WALK_GROUP)
+		return 1;
+
 	return dm_stats_get_region_nr_areas(dms, dms->cur_region);
 }
 
 uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms)
 {
-	uint64_t nr_areas = 0;
+	uint64_t nr_areas = 0, flags = DM_STATS_WALK_AREA;
 	/* use a separate cursor */
-	uint64_t cur_region, cur_area;
+	uint64_t cur_region = 0, cur_area = 0, cur_group = 0;
+
+	/* no regions to visit? */
+	if (!dms->regions)
+		return 0;
 
-	_stats_walk_start(dms, &cur_region, &cur_area);
+	flags = DM_STATS_WALK_AREA;
+	_stats_walk_start(dms, &flags, &cur_region, &cur_area, &cur_group);
 	do {
 		nr_areas += dm_stats_get_current_nr_areas(dms);
-		_stats_walk_next(dms, 1, &cur_region, &cur_area);
-	} while (!_stats_walk_end(dms, &cur_region, &cur_area));
+		_stats_walk_next(dms, &flags,
+				 &cur_region, &cur_area,
+				 &cur_group);
+	} while (!_stats_walk_end(dms, &flags,
+				  &cur_region, &cur_area,
+				  &cur_group));
 	return nr_areas;
 }
 
@@ -1379,8 +1635,12 @@ int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
 	region_id = (region_id == DM_STATS_REGION_CURRENT)
 		     ? dms->cur_region : region_id ;
 
+	/* FIXME: support group histograms if all region bounds match */
+	if (region_id & DM_STATS_WALK_GROUP)
+		return 0;
+
 	if (!dms->regions[region_id].bounds)
-		return_0;
+		return 0;
 
 	return dms->regions[region_id].bounds->nr_bins;
 }
@@ -1840,6 +2100,14 @@ char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
 	if (!_stats_bound(dms))
 		return_0;
 
+	/*
+	 * FIXME: 'print' can be emulated for groups or aggregate regions
+	 * by populating the handle and emitting aggregate counter data
+	 * in the kernel print format.
+	 */
+	if (region_id == DM_STATS_WALK_GROUP)
+		return_0;
+
 	dmt = _stats_print_region(dms, region_id,
 				  start_line, num_lines, clear);
 
@@ -1889,7 +2157,7 @@ uint64_t dm_stats_get_nr_groups(const struct dm_stats *dms)
 }
 
 /**
- * Test whether region_id is present in this set of stats data
+ * Test whether region_id is present in this set of stats data.
  */
 int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id)
 {
@@ -1923,11 +2191,25 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 {
 	int all_regions = (region_id == DM_STATS_REGIONS_ALL);
 	struct dm_task *dmt = NULL; /* @stats_print task */
+	uint64_t saved_flags; /* saved walk flags */
 	const char *resp;
 
+	/*
+	 * We are about do destroy and re-create the region table, so it
+	 * is safe to use the cursor embedded in the stats handle: just
+	 * save a copy of the current walk_flags to restore later.
+	 */
+	saved_flags = dms->walk_flags;
+
 	if (!_stats_bound(dms))
 		return_0;
 
+	if ((!all_regions) && (region_id & DM_STATS_WALK_GROUP)) {
+		log_error("Invalid region_id for dm_stats_populate: "
+			  "DM_STATS_WALK_GROUP");
+		return 0;
+	}
+
 	/* allow zero-length program_id for populate */
 	if (!program_id)
 		program_id = dms->program_id;
@@ -1943,6 +2225,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 	if (!dms->nr_regions)
 		return_0;
 
+	dms->walk_flags = DM_STATS_WALK_REGION;
 	dm_stats_walk_start(dms);
 	do {
 		region_id = (all_regions)
@@ -1959,13 +2242,15 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		}
 
 		dm_task_destroy(dmt);
-		dm_stats_walk_next_region(dms);
+		dm_stats_walk_next(dms);
 
 	} while (all_regions && !dm_stats_walk_end(dms));
 
+	dms->walk_flags = saved_flags;
 	return 1;
 
 bad:
+	dms->walk_flags = saved_flags;
 	_stats_regions_destroy(dms);
 	dms->regions = NULL;
 	return 0;
@@ -1988,14 +2273,30 @@ void dm_stats_destroy(struct dm_stats *dms)
 }
 
 /*
+ * Walk each area that is a member of region_id rid.
+ * i is a variable of type int that holds the current area_id.
+ */
+#define _foreach_region_area(dms, rid, i)				\
+for ((i) = 0; (i) < _nr_areas_region(&dms->regions[(rid)]); (i)++)	\
+
+/*
+ * Walk each region that is a member of group_id gid.
+ * i is a variable of type int that holds the current region_id.
+ */
+#define _foreach_group_region(dms, gid, i)			\
+for ((i) = dm_bit_get_first((dms)->groups[(gid)].regions);	\
+     (i) != DM_STATS_GROUP_NOT_PRESENT;				\
+     (i) = dm_bit_get_next((dms)->groups[(gid)].regions, (i)))	\
+
+/*
  * Walk each region that is a member of group_id gid visiting each
  * area within the region.
+ * i is a variable of type int that holds the current region_id.
+ * j is a variable of type int variable that holds the current area_id.
  */
-#define _foreach_group_member(dms, gid, i, j)					\
-for ((i) = dm_bit_get_first((dms)->groups[(gid)].regions);			\
-     (i) != DM_STATS_GROUP_NOT_PRESENT;						\
-     (i) = dm_bit_get_next((dms)->groups[(gid)].regions, (i)))			\
-	for ((j) = 0; (j) < _nr_areas_region(&(dms)->regions[(i)]); (j)++)	\
+#define _foreach_group_area(dms, gid, i, j)			\
+_foreach_group_region(dms, gid, i)				\
+	_foreach_region_area(dms, i, j)
 
 static uint64_t _stats_get_counter(const struct dm_stats *dms,
 				   const struct dm_stats_counters *area,
@@ -2039,6 +2340,8 @@ uint64_t dm_stats_get_counter(const struct dm_stats *dms,
 			      dm_stats_counter_t counter,
 			      uint64_t region_id, uint64_t area_id)
 {
+	uint64_t i, j, sum = 0; /* aggregation */
+	int sum_regions = 0;
 	struct dm_stats_region *region;
 	struct dm_stats_counters *area;
 
@@ -2047,14 +2350,50 @@ uint64_t dm_stats_get_counter(const struct dm_stats *dms,
 	area_id = (area_id == DM_STATS_REGION_CURRENT)
 		   ? dms->cur_area : area_id ;
 
+	sum_regions = !!(region_id & DM_STATS_WALK_GROUP);
+
+	if (region_id == DM_STATS_WALK_GROUP)
+		/* group walk using the cursor */
+		region_id = dms->cur_group;
+	else if (region_id & DM_STATS_WALK_GROUP)
+		/* group walk using immediate group_id */
+		region_id &= ~DM_STATS_WALK_GROUP;
 	region = &dms->regions[region_id];
 
-	area = &region->counters[area_id];
+	/*
+	 * All statistics aggregation takes place here: aggregate metrics
+	 * are calculated as normal using the aggregated counter values
+	 * returned for the region or group specified.
+	 */
 
-	return _stats_get_counter(dms, area, counter);
+	if (_stats_region_is_grouped(dms, region_id) && (sum_regions)) {
+		/* group */
+		if (area_id & DM_STATS_WALK_GROUP)
+			_foreach_group_area(dms, region->group_id, i, j) {
+				area = &dms->regions[i].counters[j];
+				sum += _stats_get_counter(dms, area, counter);
+			}
+		else
+			_foreach_group_region(dms, region->group_id, i) {
+				area = &dms->regions[i].counters[area_id];
+				sum += _stats_get_counter(dms, area, counter);
+			}
+	} else if (area_id == DM_STATS_WALK_REGION) {
+		/* aggregate region */
+		_foreach_region_area(dms, region_id, j) {
+			area = &dms->regions[region_id].counters[j];
+			sum += _stats_get_counter(dms, area, counter);
+		}
+	} else {
+		/* plain region / area */
+		area = &region->counters[area_id];
+		sum = _stats_get_counter(dms, area, counter);
+	}
+
+	return sum;
 }
 
-/**
+/*
  * Methods for accessing named counter fields. All methods share the
  * following naming scheme and prototype:
  *
@@ -2393,6 +2732,14 @@ int dm_stats_get_metric(const struct dm_stats *dms, int metric,
 	if (!dms->interval_ns)
 		return_0;
 
+	/*
+	 * Decode DM_STATS_{REGION,AREA}_CURRENT here; counters will then
+	 * be returned for the actual current region and area.
+	 *
+	 * DM_STATS_WALK_GROUP is passed through to the counter methods -
+	 * aggregates for the group are returned and used to calculate
+	 * the metric for the group totals.
+	 */
 	region_id = (region_id == DM_STATS_REGION_CURRENT)
 		     ? dms->cur_region : region_id ;
 	area_id = (area_id == DM_STATS_REGION_CURRENT)
@@ -2515,7 +2862,7 @@ uint64_t dm_stats_get_current_region(const struct dm_stats *dms)
 
 uint64_t dm_stats_get_current_area(const struct dm_stats *dms)
 {
-	return dms->cur_area;
+	return dms->cur_area & ~DM_STATS_WALK_ALL;
 }
 
 int dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
@@ -2523,6 +2870,19 @@ int dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
 {
 	if (!dms || !dms->regions)
 		return_0;
+
+	/* start is unchanged when aggregating areas */
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
+	/* use start of first region as group start */
+	if (region_id & DM_STATS_WALK_GROUP) {
+		if (region_id == DM_STATS_WALK_GROUP)
+			region_id = dms->cur_group;
+		else
+			region_id &= ~DM_STATS_WALK_GROUP;
+	}
+
 	*start = dms->regions[region_id].start;
 	return 1;
 }
@@ -2530,9 +2890,35 @@ int dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
 int dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
 			    uint64_t region_id)
 {
+	uint64_t i;
 	if (!dms || !dms->regions)
 		return_0;
-	*len = dms->regions[region_id].len;
+
+	*len = 0;
+
+	/* length is unchanged when aggregating areas */
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
+	if (region_id & DM_STATS_WALK_GROUP) {
+		/* decode region / group ID */
+		if (region_id == DM_STATS_WALK_GROUP)
+			region_id = dms->cur_group;
+		else
+			region_id &= ~DM_STATS_WALK_GROUP;
+
+		/* use sum of region sizes as group size */
+		if (_stats_region_is_grouped(dms, region_id))
+			_foreach_group_region(dms, dms->cur_group, i)
+				*len += dms->regions[i].len;
+		else {
+			log_error("Group ID " FMTu64 " does not exist",
+				  region_id);
+			return 0;
+		}
+	} else
+		*len = dms->regions[region_id].len;
+
 	return 1;
 }
 
@@ -2541,6 +2927,12 @@ int dm_stats_get_region_area_len(const struct dm_stats *dms, uint64_t *len,
 {
 	if (!dms || !dms->regions)
 		return_0;
+
+	/* groups are not subdivided - area size equals group size */
+	if (region_id & (DM_STATS_WALK_GROUP | DM_STATS_WALK_REGION))
+		/* get_region_len will decode region_id */
+		return dm_stats_get_region_len(dms, len, region_id);
+
 	*len = dms->regions[region_id].step;
 	return 1;
 }
@@ -2569,6 +2961,11 @@ int dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 	struct dm_stats_region *region;
 	if (!dms || !dms->regions)
 		return_0;
+
+	/* group or region area start equals region start */
+	if (region_id & (DM_STATS_WALK_GROUP | DM_STATS_WALK_REGION))
+		return dm_stats_get_region_start(dms, start, region_id);
+
 	region = &dms->regions[region_id];
 	*start = region->start + region->step * area_id;
 	return 1;
@@ -2579,7 +2976,13 @@ int dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
 {
 	if (!dms || !dms->regions)
 		return_0;
-	*offset = dms->regions[region_id].step * area_id;
+
+	/* no areas for groups or aggregate regions */
+	if (region_id & (DM_STATS_WALK_GROUP | DM_STATS_WALK_REGION))
+		*offset = 0;
+	else
+		*offset = dms->regions[region_id].step * area_id;
+
 	return 1;
 }
 
@@ -2606,14 +3009,30 @@ int dm_stats_get_current_area_len(const struct dm_stats *dms,
 const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
 					   uint64_t region_id)
 {
-	const char *program_id = dms->regions[region_id].program_id;
+	const char *program_id = NULL;
+
+	if (region_id & DM_STATS_WALK_GROUP)
+		return dms->program_id;
+
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
+	program_id = dms->regions[region_id].program_id;
 	return (program_id) ? program_id : "";
 }
 
 const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
 					 uint64_t region_id)
 {
-	const char *aux_data = dms->regions[region_id].aux_data;
+	const char *aux_data = NULL;
+
+	if (region_id & DM_STATS_WALK_GROUP)
+		return "";
+
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
+	aux_data = dms->regions[region_id].aux_data;
 	return (aux_data) ? aux_data : "" ;
 }
 
@@ -2631,6 +3050,13 @@ int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id, const char *alia
 		return 0;
 	}
 
+	if (group_id & DM_STATS_WALK_GROUP) {
+		if (group_id == DM_STATS_WALK_GROUP)
+			group_id = dms->cur_group;
+		else
+			group_id &= ~DM_STATS_WALK_GROUP;
+	}
+
 	if (group_id != dms->regions[group_id].group_id) {
 		/* dm_stats_set_alias() must be called on the group ID. */
 		log_error("Cannot set alias for group member " FMTu64 ".",
@@ -2667,8 +3093,14 @@ const char *dm_stats_get_alias(const struct dm_stats *dms, uint64_t id)
 
 	id = (id == DM_STATS_REGION_CURRENT) ? dms->cur_region : id;
 
-	region = &dms->regions[id];
+	if (id & DM_STATS_WALK_GROUP) {
+		if (id == DM_STATS_WALK_GROUP)
+			id = dms->cur_group;
+		else
+			id &= ~DM_STATS_WALK_GROUP;
+	}
 
+	region = &dms->regions[id];
 	if (!_stats_region_is_grouped(dms, id)
 	    || !dms->groups[region->group_id].alias)
 		return dms->name;
@@ -2689,13 +3121,24 @@ const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms)
 int dm_stats_get_region_precise_timestamps(const struct dm_stats *dms,
 					   uint64_t region_id)
 {
-	struct dm_stats_region *region = &dms->regions[region_id];
+	struct dm_stats_region *region;
+
+	if (region_id == DM_STATS_REGION_CURRENT)
+		region_id = dms->cur_region;
+
+	if (region_id == DM_STATS_WALK_GROUP)
+		region_id = dms->cur_group;
+	else if (region_id & DM_STATS_WALK_GROUP)
+		region_id &= ~DM_STATS_WALK_GROUP;
+
+	region = &dms->regions[region_id];
 	return region->timescale == 1;
 }
 
 int dm_stats_get_current_region_precise_timestamps(const struct dm_stats *dms)
 {
-	return dm_stats_get_region_precise_timestamps(dms, dms->cur_region);
+	return dm_stats_get_region_precise_timestamps(dms,
+						      DM_STATS_REGION_CURRENT);
 }
 
 /*
@@ -2711,6 +3154,15 @@ struct dm_histogram *dm_stats_get_histogram(const struct dm_stats *dms,
 	area_id = (area_id == DM_STATS_AREA_CURRENT)
 		     ? dms->cur_area : area_id ;
 
+	/* FIXME return histogram sum? Requires bounds check at group time */
+	if (region_id & DM_STATS_WALK_GROUP) {
+		log_warn("Group histogram data is not supported");
+		return NULL;
+	}
+
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
 	if (!dms->regions[region_id].counters)
 		return dms->regions[region_id].bounds;
 
@@ -3340,6 +3792,19 @@ int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id)
 
 uint64_t dm_stats_get_group_id(const struct dm_stats *dms, uint64_t region_id)
 {
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id;
+
+	if (region_id & DM_STATS_WALK_GROUP) {
+		if (region_id == DM_STATS_WALK_GROUP)
+			return dms->cur_group;
+		else
+			return region_id & ~DM_STATS_WALK_GROUP;
+	}
+
+	if (region_id & DM_STATS_WALK_REGION)
+		region_id &= ~DM_STATS_WALK_REGION;
+
 	return dms->regions[region_id].group_id;
 }
 


