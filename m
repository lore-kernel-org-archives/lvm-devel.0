From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:34:49 +0000 (UTC)
Subject: master - libdm: add statistics groups
Message-ID: <20160705183449.E189B61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abb499c1c2e2928b66ddcb1eab9044b0483daf31
Commit:        abb499c1c2e2928b66ddcb1eab9044b0483daf31
Parent:        728949c7bb2ad9151b31a8d7001fb4358deeb170
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Feb 29 17:52:29 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

libdm: add statistics groups

Add a grouping facility to the libdm-stats library that allows the
user to bind several regions together as a group. Groups may be
used to aggregate data from several regions for reporting, or to
select and sort among large sets of regions.

A textual descriptor ("group tag") is associated with each group
and is stored in the first group member's aux_data field. The
tag contains the group member list and an optional alias for the
group, allowing the user to assign meaningful names to groups of
regions.

These descriptors are parsed in @stats_list message responses and
populate the resulting region and area tables with the group
structure.

Groups with overlapping regions are permitted but since this will
result in some events being counted more than once a warning is
printed in this case.

Nested and overlapping groups are not currently supported and
attempting to create these configurations results in error.
---
 WHATS_NEW_DM                        |    5 +
 libdm/.exported_symbols.DM_1_02_129 |    8 +
 libdm/libdevmapper.h                |   74 +++
 libdm/libdm-stats.c                 |  880 ++++++++++++++++++++++++++++++++++-
 4 files changed, 953 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 59d0cdf..853dd00 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,10 @@
 Version 1.02.129 - 
 =================================
+  Add dm_stats_get_group_descriptor() to return the member list as a string.
+  Add dm_stats_get_nr_groups() and dm_stats_group_present().
+  Add dm_stats_{get,set}_alias() to set and retrieve alias names for groups.
+  Add dm_stats_get_group_id() to return the group ID for a given region.
+  Add dm_stats_{create,delete}_group() to allow grouping of stats regions.
   Add enum-driven dm_stats_get_{metric,counter}() interfaces.
   Add dm_bitset_parse_list() to parse a string representation of a bitset.
   Thin dmeventd plugin umounts lvm2 volume only when pool is 95% or more.
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
index 8385362..46c706d 100644
--- a/libdm/.exported_symbols.DM_1_02_129
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -1,3 +1,11 @@
 dm_bitset_parse_list
+dm_stats_create_group
+dm_stats_delete_group
+dm_stats_get_alias
 dm_stats_get_counter
+dm_stats_get_group_descriptor
+dm_stats_get_group_id
 dm_stats_get_metric
+dm_stats_get_nr_groups
+dm_stats_group_present
+dm_stats_set_alias
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 68f1192..17f88a8 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -715,6 +715,19 @@ void dm_stats_buffer_destroy(struct dm_stats *dms, char *buffer);
 uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms);
 
 /*
+ * Determine the number of groups contained in a dm_stats handle
+ * following a dm_stats_list() or dm_stats_populate() call.
+ *
+ * The value returned is the number of registered groups visible with the
+ * progam_id value used for the list or populate operation and may not be
+ * equal to the highest present group_id (either due to program_id
+ * filtering or gaps in the sequence of group_id values).
+ *
+ * Always returns zero on an empty handle.
+ */
+uint64_t dm_stats_get_nr_groups(const struct dm_stats *dms);
+
+/*
  * Test whether region_id is present in this dm_stats handle.
  */
 int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id);
@@ -733,6 +746,11 @@ uint64_t dm_stats_get_region_nr_areas(const struct dm_stats *dms,
 uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms);
 
 /*
+ * Test whether group_id is present in this dm_stats handle.
+ */
+int dm_stats_group_present(const struct dm_stats *dms, uint64_t group_id);
+
+/*
  * Return the number of bins in the histogram configuration for the
  * specified region or zero if no histogram specification is configured.
  * Valid following a dm_stats_list() or dm_stats_populate() operation.
@@ -1080,6 +1098,62 @@ const char *dm_stats_get_current_region_program_id(const struct dm_stats *dms);
 const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms);
 
 /*
+ * Statistics groups and data aggregation.
+ */
+
+/*
+ * Create a new group in stats handle dms from the group descriptor
+ * passed in group. The group descriptor is a string containing a list
+ * of region_id values that will be included in the group. The first
+ * region_id found will be the group leader. Ranges of identifiers may
+ * be expressed as "M-N", where M and N are the start and end region_id
+ * values for the range.
+ */
+int dm_stats_create_group(struct dm_stats *dms, const char *group,
+			  const char *alias, uint64_t *group_id);
+
+/*
+ * Remove the specified group_id.
+ */
+int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id);
+
+/*
+ * Set an alias for this group or region. The alias will be returned
+ * instead of the normal dm-stats name for this region or group.
+ */
+int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id,
+		       const char *alias);
+
+/*
+ * Returns a pointer to the currently configured alias for id, or the
+ * name of the dm device the handle is bound to if no alias has been
+ * set. The pointer will be freed automatically when a new alias is set
+ * or when the stats handle is cleared.
+ */
+const char *dm_stats_get_alias(const struct dm_stats *dms, uint64_t id);
+
+/*
+ * Return the group_id that the specified region_id belongs to, or the
+ * special value DM_STATS_GROUP_NONE if the region does not belong
+ * to any group.
+ */
+uint64_t dm_stats_get_group_id(const struct dm_stats *dms, uint64_t region_id);
+
+/*
+ * Store a pointer to a string describing the regions that are members
+ * of the group specified by group_id in the memory pointed to by buf.
+ * The string is in the same format as the 'group' argument to
+ * dm_stats_create_group().
+ *
+ * The pointer does not need to be freed explicitly by the caller: it
+ * will become invalid following a subsequent dm_stats_list(),
+ * dm_stats_populate() or dm_stats_destroy() of the corresponding
+ * dm_stats handle.
+ */
+int dm_stats_get_group_descriptor(const struct dm_stats *dms,
+				  uint64_t group_id, char **buf);
+
+/*
  * Call this to actually run the ioctl.
  */
 int dm_task_run(struct dm_task *dmt);
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index dc97346..537caab 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -17,6 +17,7 @@
 #include "math.h" /* log10() */
 
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
+#define DM_STATS_GROUP_NOT_PRESENT UINT64_MAX
 
 #define NSEC_PER_USEC   1000L
 #define NSEC_PER_MSEC   1000000L
@@ -64,6 +65,7 @@ struct dm_stats_counters {
 
 struct dm_stats_region {
 	uint64_t region_id; /* as returned by @stats_list */
+	uint64_t group_id;
 	uint64_t start;
 	uint64_t len;
 	uint64_t step;
@@ -74,6 +76,12 @@ struct dm_stats_region {
 	struct dm_stats_counters *counters;
 };
 
+struct dm_stats_group {
+	uint64_t group_id;
+	const char *alias;
+	dm_bitset_t regions;
+};
+
 struct dm_stats {
 	/* device binding */
 	int bind_major;  /* device major that this dm_stats object is bound to */
@@ -84,12 +92,14 @@ struct dm_stats {
 	const char *name; /* cached device_name used for reporting */
 	struct dm_pool *mem; /* memory pool for region and counter tables */
 	struct dm_pool *hist_mem; /* separate pool for histogram tables */
+	struct dm_pool *group_mem; /* separate pool for group tables */
 	uint64_t nr_regions; /* total number of present regions */
 	uint64_t max_region; /* size of the regions table */
 	uint64_t interval_ns;  /* sampling interval in nanoseconds */
 	uint64_t timescale; /* default sample value multiplier */
 	int precise; /* use precise_timestamps when creating regions */
 	struct dm_stats_region *regions;
+	struct dm_stats_group *groups;
 	/* statistics cursor */
 	uint64_t cur_region;
 	uint64_t cur_area;
@@ -139,6 +149,7 @@ static uint64_t _nr_areas_region(struct dm_stats_region *region)
 struct dm_stats *dm_stats_create(const char *program_id)
 {
 	size_t hist_hint = sizeof(struct dm_histogram_bin);
+	size_t group_hint = sizeof(struct dm_stats_group);
 	struct dm_stats *dms = NULL;
 
 	if (!(dms = dm_zalloc(sizeof(*dms))))
@@ -153,6 +164,9 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	if (!(dms->hist_mem = dm_pool_create("histogram_pool", hist_hint)))
 		goto_bad;
 
+	if (!(dms->group_mem = dm_pool_create("group_pool", group_hint)))
+		goto_bad;
+
 	if (!program_id || !strlen(program_id))
 		dms->program_id = _program_id_from_proc();
 	else
@@ -182,11 +196,15 @@ struct dm_stats *dm_stats_create(const char *program_id)
 
 bad:
 	dm_pool_destroy(dms->mem);
+	if (dms->hist_mem)
+		dm_pool_destroy(dms->hist_mem);
+	if (dms->group_mem)
+		dm_pool_destroy(dms->group_mem);
 	dm_free(dms);
 	return NULL;
 }
 
-/**
+/*
  * Test whether the stats region pointed to by region is present.
  */
 static int _stats_region_present(const struct dm_stats_region *region)
@@ -194,6 +212,51 @@ static int _stats_region_present(const struct dm_stats_region *region)
 	return !(region->region_id == DM_STATS_REGION_NOT_PRESENT);
 }
 
+/*
+ * Test whether the stats group pointed to by group is present.
+ */
+static int _stats_group_present(const struct dm_stats_group *group)
+{
+	return !(group->group_id == DM_STATS_GROUP_NOT_PRESENT);
+}
+
+/*
+ * Test whether a stats group id is present.
+ */
+static int _stats_group_id_present(const struct dm_stats *dms, uint64_t id)
+{
+	struct dm_stats_group *group = NULL;
+
+	if (!dms || !dms->regions)
+		return_0;
+
+	if (id > dms->max_region)
+		return 0;
+
+	group = &dms->groups[id];
+
+	return _stats_group_present(group);
+}
+
+/*
+ * Test whether the given region_id is a member of any group.
+ */
+static uint64_t _stats_region_is_grouped(const struct dm_stats* dms,
+					 uint64_t region_id)
+{
+	uint64_t group_id;
+
+	if (region_id == DM_STATS_GROUP_NOT_PRESENT)
+		return 0;
+
+	if (!_stats_region_present(&dms->regions[region_id]))
+		return 0;
+
+	group_id = dms->regions[region_id].group_id;
+
+	return group_id != DM_STATS_GROUP_NOT_PRESENT;
+}
+
 static void _stats_histograms_destroy(struct dm_pool *mem,
 				      struct dm_stats_region *region)
 {
@@ -213,17 +276,27 @@ static void _stats_region_destroy(struct dm_stats_region *region)
 	if (!_stats_region_present(region))
 		return;
 
-	/**
-	 * Don't free counters here explicitly; it will be dropped
-	 * from the pool along with the corresponding regions table.
+	region->start = region->len = region->step = 0;
+	region->timescale = 0;
+
+	/*
+	 * Don't free counters and histogram bounds here: they are
+	 * dropped from the pool along with the corresponding
+	 * regions table.
 	 *
 	 * The following objects are all allocated with dm_malloc.
 	 */
 
+	region->counters = NULL;
+	region->bounds = NULL;
+
 	if (region->program_id)
 		dm_free(region->program_id);
+	region->program_id = NULL;
 	if (region->aux_data)
 		dm_free(region->aux_data);
+	region->aux_data = NULL;
+	region->region_id = DM_STATS_REGION_NOT_PRESENT;
 }
 
 static void _stats_regions_destroy(struct dm_stats *dms)
@@ -243,6 +316,34 @@ static void _stats_regions_destroy(struct dm_stats *dms)
 	dm_pool_free(mem, dms->regions);
 }
 
+static void _stats_group_destroy(struct dm_stats_group *group)
+{
+	if (!_stats_group_present(group))
+		return;
+
+	if (group->alias) {
+		dm_free((char *) group->alias);
+		group->alias = NULL;
+	}
+	if (group->regions) {
+		dm_bitset_destroy(group->regions);
+		group->regions = NULL;
+	}
+	group->group_id = DM_STATS_GROUP_NOT_PRESENT;
+}
+
+static void _stats_groups_destroy(struct dm_stats *dms)
+{
+	uint64_t i;
+
+	if (!dms->groups)
+		return;
+
+	for (i = dms->max_region; (i != DM_STATS_REGION_NOT_PRESENT); i--)
+		_stats_group_destroy(&dms->groups[i]);
+	dm_pool_free(dms->group_mem, dms->groups);
+}
+
 static int _set_stats_device(struct dm_stats *dms, struct dm_task *dmt)
 {
 	if (dms->bind_name)
@@ -255,7 +356,7 @@ static int _set_stats_device(struct dm_stats *dms, struct dm_task *dmt)
 	return_0;
 }
 
-static int _stats_bound(struct dm_stats *dms)
+static int _stats_bound(const struct dm_stats *dms)
 {
 	if (dms->bind_major > 0 || dms->bind_name || dms->bind_uuid)
 		return 1;
@@ -282,6 +383,7 @@ int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor)
 {
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
+	_stats_groups_destroy(dms);
 
 	dms->bind_major = major;
 	dms->bind_minor = minor;
@@ -293,6 +395,7 @@ int dm_stats_bind_name(struct dm_stats *dms, const char *name)
 {
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
+	_stats_groups_destroy(dms);
 
 	if (!(dms->bind_name = dm_pool_strdup(dms->mem, name)))
 		return_0;
@@ -304,6 +407,7 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid)
 {
 	_stats_clear_binding(dms);
 	_stats_regions_destroy(dms);
+	_stats_groups_destroy(dms);
 
 	if (!(dms->bind_uuid = dm_pool_strdup(dms->mem, uuid)))
 		return_0;
@@ -484,6 +588,127 @@ bad:
 }
 
 /*
+ * update region group_id values
+ */
+static void _stats_update_groups(struct dm_stats *dms)
+{
+	struct dm_stats_group *group;
+	uint64_t group_id, i;
+
+	for (group_id = 0; group_id < dms->max_region + 1; group_id++) {
+		if (!_stats_group_id_present(dms, group_id))
+			continue;
+
+		group = &dms->groups[group_id];
+
+		for (i = dm_bit_get_first(group->regions);
+		     i != DM_STATS_GROUP_NOT_PRESENT;
+		     i = dm_bit_get_next(group->regions, i))
+			dms->regions[i].group_id = group_id;
+	}
+}
+
+/*
+ * Parse a DMS_GROUP group descriptor embedded in a region's aux_data.
+ *
+ * DMS_GROUP="ALIAS:MEMBERS"
+ *
+ * ALIAS: group alias
+ * MEMBERS: list of group member region ids.
+ *
+ */
+#define DMS_GROUP_TAG "DMS_GROUP="
+#define DMS_GROUP_TAG_LEN (sizeof(DMS_GROUP_TAG) - 1)
+#define DMS_GROUP_SEP ':'
+#define DMS_AUX_SEP "#"
+static int _parse_aux_data_group(struct dm_stats *dms,
+				 struct dm_stats_region *region,
+				 struct dm_stats_group *group)
+{
+	char *alias, *c, *end;
+	dm_bitset_t regions;
+
+	memset(group, 0, sizeof(*group));
+	group->group_id = DM_STATS_GROUP_NOT_PRESENT;
+
+	/* find start of group tag */
+	c = strstr(region->aux_data, DMS_GROUP_TAG);
+	if (!c)
+		return 1; /* no group is not an error */
+
+	alias = c + strlen(DMS_GROUP_TAG);
+
+	c = strchr(c, DMS_GROUP_SEP);
+
+	if (!c) {
+		log_error("Found malformed group tag while reading aux_data");
+		return 0;
+	}
+
+	/* terminate alias and advance to members */
+	*(c++) = '\0';
+
+	log_debug("Read alias '%s' from aux_data", alias);
+
+	if (!c) {
+		log_error("Found malformed group descriptor while "
+			  "reading aux_data, expected '%c'", DMS_GROUP_SEP);
+		return 0;
+	}
+
+	/* if user aux_data follows make sure we have a terminated
+	 * string to pass to dm_bitset_parse_list().
+	 */
+	end = strstr(c, DMS_AUX_SEP);
+	if (!end)
+		end = c + strlen(c);
+	*(end++) = '\0';
+
+	if (!(regions = dm_bitset_parse_list(c, NULL))) {
+		log_error("Could not parse member list while "
+			  "reading group aux_data");
+		return 0;
+	}
+
+	group->group_id = dm_bit_get_first(regions);
+	group->regions = regions;
+
+	group->alias = NULL;
+	if (strlen(alias)) {
+		group->alias = dm_strdup(alias);
+		if (!group->alias) {
+			log_error("Could not allocate memory for group alias");
+			goto bad;
+		}
+	}
+
+	/* separate group tag from user aux_data */
+	if (strlen(end))
+		c = dm_strdup(end);
+	else
+		c = dm_strdup("");
+
+	if (!c) {
+		log_error("Could not allocate memory for user aux_data");
+		goto bad_alias;
+	}
+
+	dm_free(region->aux_data);
+	region->aux_data = c;
+
+	log_debug("Found group_id " FMTu64 ": alias=\"%s\"", group->group_id,
+		  (group->alias) ? group->alias : "");
+
+	return 1;
+
+bad_alias:
+	dm_free((char *) group->alias);
+bad:
+	dm_bitset_destroy(regions);
+	return 0;
+}
+
+/*
  * Parse a histogram specification returned by the kernel in a
  * @stats_list response.
  */
@@ -596,8 +821,8 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 				    struct dm_stats_region *region, char *line)
 {
 	char *p = NULL, string_data[4096]; /* FIXME: add dm_sscanf with %ms? */
-	const char *program_id, *aux_data, *stats_args;
-	const char *empty_string = "";
+	char *program_id, *aux_data, *stats_args;
+	char *empty_string = (char *) "";
 	int r;
 
 	memset(string_data, 0, sizeof(string_data));
@@ -626,17 +851,22 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 	if ((p = strchr(string_data, ' '))) {
 		/* terminate program_id string. */
 		*p = '\0';
-		if (!strcmp(program_id, "-"))
+		if (!strncmp(program_id, "-", 1))
 			program_id = empty_string;
 		aux_data = p + 1;
 		if ((p = strchr(aux_data, ' '))) {
 			/* terminate aux_data string. */
 			*p = '\0';
-			if (!strcmp(aux_data, "-"))
-				aux_data = empty_string;
 			stats_args = p + 1;
 		} else
 			stats_args = empty_string;
+
+		/* no aux_data? */
+		if (!strncmp(aux_data, "-", 1))
+			aux_data = empty_string;
+		else
+			/* remove trailing newline */
+			aux_data[strlen(aux_data) - 1] = '\0';
 	} else
 		aux_data = stats_args = empty_string;
 
@@ -651,6 +881,8 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 	} else
 		region->bounds = NULL;
 
+	region->group_id = DM_STATS_GROUP_NOT_PRESENT;
+
 	if (!(region->program_id = dm_strdup(program_id)))
 		return_0;
 	if (!(region->aux_data = dm_strdup(aux_data))) {
@@ -666,7 +898,8 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 {
 	uint64_t max_region = 0, nr_regions = 0;
 	struct dm_stats_region cur, fill;
-	struct dm_pool *mem = dms->mem;
+	struct dm_stats_group cur_group;
+	struct dm_pool *mem = dms->mem, *group_mem = dms->group_mem;
 	FILE *list_rows;
 	/* FIXME: use correct maximum line length for kernel format */
 	char line[256];
@@ -676,8 +909,8 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 		return 0;
 	}
 
-	if (dms->regions)
-		_stats_regions_destroy(dms);
+	_stats_regions_destroy(dms);
+	_stats_groups_destroy(dms);
 
 	/* no regions */
 	if (!strlen(resp)) {
@@ -693,27 +926,52 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	if (!(list_rows = fmemopen((char *)resp, strlen(resp), "r")))
 		return_0;
 
+	/* begin region table */
 	if (!dm_pool_begin_object(mem, 1024))
 		goto_bad;
 
+	/* begin group table */
+	if (!dm_pool_begin_object(group_mem, 32))
+		goto_bad;
+
 	while(fgets(line, sizeof(line), list_rows)) {
 
+		cur_group.group_id = DM_STATS_GROUP_NOT_PRESENT;
+		cur_group.regions = NULL;
+		cur_group.alias = NULL;
+
 		if (!_stats_parse_list_region(dms, &cur, line))
 			goto_bad;
 
 		/* handle holes in the list of region_ids */
 		if (cur.region_id > max_region) {
 			memset(&fill, 0, sizeof(fill));
+			memset(&cur_group, 0, sizeof(cur_group));
 			fill.region_id = DM_STATS_REGION_NOT_PRESENT;
+			cur_group.group_id = DM_STATS_GROUP_NOT_PRESENT;
 			do {
 				if (!dm_pool_grow_object(mem, &fill, sizeof(fill)))
 					goto_bad;
+				if (!dm_pool_grow_object(group_mem, &cur_group,
+							 sizeof(cur_group)))
+					goto_bad;
 			} while (max_region++ < (cur.region_id - 1));
 		}
 
+		if (cur.aux_data)
+			if (!_parse_aux_data_group(dms, &cur, &cur_group))
+				log_error("Failed to parse group descriptor "
+					  "from region_id " FMTu64 " aux_data:"
+					  "'%s'", cur.region_id, cur.aux_data);
+				/* continue */
+
 		if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
 			goto_bad;
 
+		if (!dm_pool_grow_object(group_mem, &cur_group,
+					 sizeof(cur_group)))
+			goto_bad;
+
 		max_region++;
 		nr_regions++;
 	}
@@ -725,6 +983,9 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	dms->nr_regions = nr_regions;
 	dms->max_region = max_region - 1;
 	dms->regions = dm_pool_end_object(mem);
+	dms->groups = dm_pool_end_object(group_mem);
+
+	_stats_update_groups(dms);
 
 	if (fclose(list_rows))
 		stack;
@@ -735,6 +996,7 @@ bad:
 	if (fclose(list_rows))
 		stack;
 	dm_pool_abandon_object(mem);
+	dm_pool_abandon_object(group_mem);
 
 	return 0;
 }
@@ -1104,6 +1366,11 @@ uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms)
 	return nr_areas;
 }
 
+int dm_stats_group_present(const struct dm_stats *dms, uint64_t group_id)
+{
+	return _stats_group_id_present(dms, group_id);
+}
+
 int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
 					  uint64_t region_id)
 {
@@ -1116,6 +1383,198 @@ int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
 	return dms->regions[region_id].bounds->nr_bins;
 }
 
+/*
+ * Fill buf with a list of set regions in the regions bitmap. Consecutive
+ * ranges of set region IDs are output using "M-N" range notation.
+ *
+ * The number of bytes consumed is returned or zero on error.
+ */
+static size_t _stats_group_tag_fill(const struct dm_stats *dms,
+				    dm_bitset_t regions,
+				    char *buf, size_t buflen)
+{
+	int i, j, r, next, last = 0;
+	size_t used = 0;
+
+	i = dm_bit_get_first(regions);
+	for (; i >= 0; i = dm_bit_get_next(regions, i))
+		last = i;
+
+	i = dm_bit_get_first(regions);
+	for(; i >= 0; i = dm_bit_get_next(regions, i)) {
+		/* find range end */
+		j = i;
+		do
+			next = j + 1;
+		while ((j = dm_bit_get_next(regions, j)) == next);
+
+		/* set to last set bit */
+		j = next - 1;
+
+		/* handle range vs. single region */
+		if (i != j)
+			r = dm_snprintf(buf, buflen, FMTu64 "-" FMTu64 "%s",
+					(uint64_t) i, (uint64_t) j,
+					(j == last) ? "" : ",");
+		else
+			r = dm_snprintf(buf, buflen, FMTu64 "%s", (uint64_t) i,
+					(i == last) ? "" : ",");
+		if (r < 0)
+			goto_bad;
+
+		i = next; /* skip handled bits if in range */
+
+		buf += r;
+		used += r;
+	}
+
+	return used;
+bad:
+	log_error("Could not format group list.");
+	return 0;
+}
+
+/*
+ * Calculate the space required to hold a string description of the group
+ * described by the regions bitset using comma separated list in range
+ * notation ("A,B,C,M-N").
+ */
+static size_t _stats_group_tag_len(const struct dm_stats *dms,
+				   dm_bitset_t regions)
+{
+	int i, j, next, nr_regions = 0;
+	size_t buflen = 0, id_len = 0;
+
+	/* check region ids and find last set bit */
+	i = dm_bit_get_first(regions);
+	for (; i >= 0; i = dm_bit_get_next(regions, i)) {
+		if (!dm_stats_region_present(dms, i)) {
+			log_error("Region identifier %d not found", i);
+			return 0;
+		}
+
+		/* length of region_id or range start in characters */
+		id_len = (i) ? 1 + (size_t) log10(i) : 1;
+		buflen += id_len;
+		j = i;
+		do
+			next = j + 1;
+		while ((j = dm_bit_get_next(regions, j)) == next);
+
+		/* set to last set bit */
+		j = next - 1;
+
+		nr_regions += j - i + 1;
+
+		/* handle range */
+		if (i != j) {
+			/* j is always > i, which is always >= 0 */
+			id_len = 1 + (size_t) log10(j);
+			buflen += id_len + 1; /* range end plus "-" */
+		}
+		buflen++;
+		i = next; /* skip bits if handling range */
+	}
+	return buflen;
+}
+
+/*
+ * Build a DMS_GROUP="..." tag for the group specified by group_id,
+ * to be stored in the corresponding region's aux_data field.
+ */
+static char *_build_group_tag(struct dm_stats *dms, uint64_t group_id)
+{
+	char *aux_string, *buf;
+	dm_bitset_t regions;
+	const char *alias;
+	size_t buflen = 0;
+	int r;
+
+	regions = dms->groups[group_id].regions;
+	alias = dms->groups[group_id].alias;
+
+	buflen = _stats_group_tag_len(dms, regions);
+
+	if (!buflen)
+		return_0;
+
+	buflen += DMS_GROUP_TAG_LEN;
+	buflen += 1 + (alias ? strlen(alias) : 0); /* 'alias:' */
+
+	buf = aux_string = dm_malloc(buflen);
+	if (!buf) {
+		log_error("Could not allocate memory for aux_data string.");
+		return NULL;
+	}
+
+	if (!dm_strncpy(buf, DMS_GROUP_TAG, DMS_GROUP_TAG_LEN + 1))
+		goto_bad;
+
+	buf += DMS_GROUP_TAG_LEN;
+	buflen -= DMS_GROUP_TAG_LEN;
+
+	r = dm_snprintf(buf, buflen, "%s%c", alias ? alias : "", DMS_GROUP_SEP);
+	if (r < 0)
+		goto_bad;
+
+	buf += r;
+	buflen -= r;
+
+	r = _stats_group_tag_fill(dms, regions, buf, buflen);
+	if (!r)
+		goto_bad;
+
+	return aux_string;
+bad:
+	log_error("Could not format group aux_data.");
+	dm_free(aux_string);
+	return NULL;
+}
+
+/*
+ * Store updated aux_data for a region. The aux_data is passed to the
+ * kernel using the @stats_set_aux message. Any required group tag is
+ * generated from the current group table and included in the message.
+ */
+static int _stats_set_aux(struct dm_stats *dms,
+			  uint64_t region_id, const char *aux_data)
+{
+	const char *group_tag = NULL;
+	struct dm_task *dmt = NULL;
+	char msg[1024];
+
+	/* group data required? */
+	if (_stats_group_id_present(dms, region_id)) {
+		group_tag = _build_group_tag(dms, region_id);
+		if (!group_tag) {
+			log_error("Could not build group descriptor for "
+				  "region ID " FMTu64, region_id);
+			goto_bad;
+		}
+	}
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_set_aux " FMTu64 " %s%s%s ",
+			 region_id, (group_tag) ? group_tag : "",
+			 (group_tag) ? DMS_AUX_SEP : "",
+			 (strlen(aux_data)) ? aux_data : "-")) {
+		log_error("Could not prepare @stats_set_aux message");
+		goto bad;
+	}
+
+	if (!(dmt = _stats_send_message(dms, msg)))
+		goto_bad;
+
+	dm_free((char *) group_tag);
+
+	/* no response to a @stats_set_aux message */
+	dm_task_destroy(dmt);
+
+	return 1;
+bad:
+	dm_free((char *) group_tag);
+	return 0;
+}
+
 static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 				uint64_t start, uint64_t len, int64_t step,
 				int precise, const char *hist_arg,
@@ -1227,6 +1686,40 @@ out:
 	return r;
 }
 
+static void _stats_clear_group_regions(struct dm_stats *dms, uint64_t group_id)
+{
+	struct dm_stats_group *group;
+	uint64_t i;
+
+	group = &dms->groups[group_id];
+	for (i = dm_bit_get_first(group->regions);
+	     i != DM_STATS_GROUP_NOT_PRESENT;
+	     i = dm_bit_get_next(group->regions, i))
+		dms->regions[i].group_id = DM_STATS_GROUP_NOT_PRESENT;
+}
+
+static int _stats_remove_region_id_from_group(struct dm_stats *dms,
+					      uint64_t region_id)
+{
+	struct dm_stats_region *region = &dms->regions[region_id];
+	dm_bitset_t regions = dms->groups[region_id].regions;
+	uint64_t group_id = region->group_id;
+
+	if (!_stats_region_is_grouped(dms, region_id))
+		return_0;
+
+	dm_bit_clear(regions, region_id);
+
+	/* removing group leader? */
+	if (region_id == group_id) {
+		dms->groups[group_id].group_id = DM_STATS_GROUP_NOT_PRESENT;
+		_stats_clear_group_regions(dms, group_id);
+		_stats_group_destroy(&dms->groups[group_id]);
+	}
+
+	return _stats_set_aux(dms, group_id, dms->regions[group_id].aux_data);
+}
+
 int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
 	struct dm_task *dmt;
@@ -1235,6 +1728,32 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 	if (!_stats_bound(dms))
 		return_0;
 
+	if (!dms->regions && !dm_stats_list(dms, dms->program_id)) {
+		log_error("Could not obtain region list while deleting "
+			  "region ID " FMTu64, region_id);
+		return 0;
+	}
+
+	if (!dm_stats_get_nr_areas(dms)) {
+		log_error("Could not delete region ID " FMTu64 ": "
+			  "no regions found", region_id);
+		return 0;
+	}
+
+	/* includes invalid and special region_id values */
+	if (!dm_stats_region_present(dms, region_id)) {
+		log_error("Region ID " FMTu64 " does not exist", region_id);
+		return 0;
+	}
+
+	if(_stats_region_is_grouped(dms, region_id))
+		if (!_stats_remove_region_id_from_group(dms, region_id)) {
+			log_error("Could not remove region ID " FMTu64 " from "
+				  "group ID " FMTu64,
+				  region_id, dms->regions[region_id].group_id);
+			return 0;
+		}
+
 	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
 		log_error("Could not prepare @stats_delete message.");
 		return 0;
@@ -1245,6 +1764,9 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 		return_0;
 	dm_task_destroy(dmt);
 
+	/* wipe region and mark as not present */
+	_stats_region_destroy(&dms->regions[region_id]);
+
 	return 1;
 }
 
@@ -1340,6 +1862,25 @@ uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms)
 	return dms->nr_regions;
 }
 
+uint64_t dm_stats_get_nr_groups(const struct dm_stats *dms)
+{
+	uint64_t group_id, nr_groups = 0;
+
+	if (!dms)
+		return_0;
+
+	/* no regions or groups? */
+	if (!dms->regions || !dms->groups)
+		return 0;
+
+	for (group_id = 0; group_id <= dms->max_region; group_id++)
+		if (dms->groups[group_id].group_id
+		    != DM_STATS_GROUP_NOT_PRESENT)
+			nr_groups++;
+
+	return nr_groups;
+}
+
 /**
  * Test whether region_id is present in this set of stats data
  */
@@ -1349,7 +1890,7 @@ int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id)
 		return_0;
 
 	if (region_id > dms->max_region)
-		return_0;
+		return 0;
 
 	return _stats_region_present(&dms->regions[region_id]);
 }
@@ -1429,14 +1970,26 @@ bad:
 void dm_stats_destroy(struct dm_stats *dms)
 {
 	_stats_regions_destroy(dms);
+	_stats_groups_destroy(dms);
 	_stats_clear_binding(dms);
 	dm_pool_destroy(dms->mem);
 	dm_pool_destroy(dms->hist_mem);
+	dm_pool_destroy(dms->group_mem);
 	dm_free(dms->program_id);
 	dm_free((char *) dms->name);
 	dm_free(dms);
 }
 
+/*
+ * Walk each region that is a member of group_id gid visiting each
+ * area within the region.
+ */
+#define _foreach_group_member(dms, gid, i, j)					\
+for ((i) = dm_bit_get_first((dms)->groups[(gid)].regions);			\
+     (i) != DM_STATS_GROUP_NOT_PRESENT;						\
+     (i) = dm_bit_get_next((dms)->groups[(gid)].regions, (i)))			\
+	for ((j) = 0; (j) < _nr_areas_region(&(dms)->regions[(i)]); (j)++)	\
+
 static uint64_t _stats_get_counter(const struct dm_stats *dms,
 				   const struct dm_stats_counters *area,
 				   dm_stats_counter_t counter)
@@ -1833,6 +2386,11 @@ int dm_stats_get_metric(const struct dm_stats *dms, int metric,
 	if (!dms->interval_ns)
 		return_0;
 
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
 	if (metric < 0 || metric >= DM_STATS_NR_METRICS) {
 		log_error("Attempt to read invalid metric: %d", metric);
 		return 0;
@@ -2052,6 +2610,65 @@ const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
 	return (aux_data) ? aux_data : "" ;
 }
 
+int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id, const char *alias)
+{
+	struct dm_stats_group *group = NULL;
+	const char *old_alias = NULL;
+
+	if (!dms->regions || !dms->groups || !alias)
+		return_0;
+
+	if (!_stats_region_is_grouped(dms, group_id)) {
+		log_error("Cannot set alias for ungrouped region ID "
+			  FMTu64, group_id);
+		return 0;
+	}
+
+	if (group_id != dms->regions[group_id].group_id) {
+		/* dm_stats_set_alias() must be called on the group ID. */
+		log_error("Cannot set alias for group member " FMTu64 ".",
+			  group_id);
+		return 0;
+	}
+
+	group = &dms->groups[group_id];
+	old_alias = group->alias;
+
+	group->alias = dm_strdup(alias);
+	if (!group->alias) {
+		log_error("Could not allocate memory for alias.");
+		goto bad;
+	}
+
+	if (!_stats_set_aux(dms, group_id, dms->regions[group_id].aux_data)) {
+		log_error("Could not set new aux_data");
+		goto bad;
+	}
+
+	dm_free((char *) old_alias);
+
+	return 1;
+
+bad:
+	group->alias = old_alias;
+	return 0;
+}
+
+const char *dm_stats_get_alias(const struct dm_stats *dms, uint64_t id)
+{
+	const struct dm_stats_region *region;
+
+	id = (id == DM_STATS_REGION_CURRENT) ? dms->cur_region : id;
+
+	region = &dms->regions[id];
+
+	if (!_stats_region_is_grouped(dms, id)
+	    || !dms->groups[region->group_id].alias)
+		return dms->name;
+
+	return dms->groups[region->group_id].alias;
+}
+
 const char *dm_stats_get_current_region_program_id(const struct dm_stats *dms)
 {
 	return dm_stats_get_region_program_id(dms, dms->cur_region);
@@ -2504,6 +3121,241 @@ bad:
 }
 
 /*
+ * A lightweight representation of an extent (region, area, file
+ * system block or extent etc.). A table of extents can be used
+ * to sort and to efficiently find holes or overlaps among a set
+ * of tuples of the form (id, start, len).
+ */
+struct _extent {
+	struct dm_list list;
+	uint64_t id;
+	uint64_t start;
+	uint64_t len;
+};
+
+/* last address in an extent */
+#define _extent_end(a) ((a)->start + (a)->len - 1)
+
+/* a and b must be sorted by increasing start sector */
+#define _extents_overlap(a, b) (_extent_end(a) > (b)->start)
+
+/*
+ * Comparison function to sort extents in ascending start order.
+ */
+static int _extent_start_compare(const void *p1, const void *p2)
+{
+	struct _extent *r1, *r2;
+	r1 = (struct _extent *) p1;
+	r2 = (struct _extent *) p2;
+
+	if (r1->start < r2->start)
+		return -1;
+	else if (r1->start == r2->start)
+		return 0;
+	return 1;
+}
+
+static int _stats_create_group(struct dm_stats *dms, dm_bitset_t regions,
+			       const char *alias, uint64_t *group_id)
+{
+	struct dm_stats_group *group;
+	*group_id = dm_bit_get_first(regions);
+
+	/* group has no regions? */
+	if (*group_id == DM_STATS_GROUP_NOT_PRESENT)
+		return_0;
+
+	group = &dms->groups[*group_id];
+
+	if (group->regions) {
+		log_error(INTERNAL_ERROR "Unexpected group state while"
+			  "creating group ID bitmap" FMTu64, *group_id);
+		return 0;
+	}
+
+	group->group_id = *group_id;
+	group->regions = regions;
+
+	if (alias)
+		group->alias = dm_strdup(alias);
+	else
+		group->alias = NULL;
+
+	/* force an update of the group tag stored in aux_data */
+	if (!_stats_set_aux(dms, *group_id, dms->regions[*group_id].aux_data))
+		return 0;
+
+	return 1;
+}
+
+static int _stats_group_check_overlap(const struct dm_stats *dms,
+				      dm_bitset_t regions, int count)
+{
+	struct dm_list ext_list = DM_LIST_HEAD_INIT(ext_list);
+	struct _extent *ext, *tmp, *next, *map = NULL;
+	size_t map_size = (dms->max_region + 1) * sizeof(*map);
+	int i = 0, id, overlap, merged;
+
+	map = dm_pool_alloc(dms->mem, map_size);
+	if (!map) {
+		log_error("Could not allocate memory for region map");
+		return 0;
+	}
+
+	for (id = dm_bit_get_first(regions); id >= 0;
+	     id = dm_bit_get_next(regions, id)) {
+		dm_list_init(&map[i].list);
+		map[i].id = id;
+		map[i].start = dms->regions[id].start;
+		map[i].len = dms->regions[id].len;
+		i++;
+	}
+
+	qsort(map, count, sizeof(*map), _extent_start_compare);
+
+	for (i = 0; i < count; i++)
+		dm_list_add(&ext_list, &map[i].list);
+
+	overlap = 0;
+merge:
+	merged = 0;
+	dm_list_iterate_items_safe(ext, tmp, &ext_list) {
+		next = dm_list_item(dm_list_next(&ext_list, &ext->list),
+				    struct _extent);
+		if (!next)
+			continue;
+
+		if (_extents_overlap(ext, next)) {
+			log_warn("Warning: region IDs " FMTu64 " and "
+				 FMTu64 " overlap. Some events will be "
+				 "counted twice.", ext->id, next->id);
+			/* merge larger extent into smaller */
+			if (_extent_end(ext) > _extent_end(next)) {
+				next->id = ext->id;
+				next->len = ext->len;
+			}
+			if (ext->start < next->start)
+				next->start = ext->start;
+			dm_list_del(&ext->list);
+			overlap = merged = 1;
+		}
+	}
+	if (merged)
+		goto merge;
+
+	dm_pool_free(dms->mem, map);
+	return overlap;
+}
+
+/*
+ * Create a new group in stats handle dms from the group description
+ * passed in group.
+ */
+int dm_stats_create_group(struct dm_stats *dms, const char *members,
+			  const char *alias, uint64_t *group_id)
+{
+	int i, count = 0, precise = 0;
+	dm_bitset_t regions;
+
+	if (!dms->regions || !dms->groups) {
+		log_error("Could not create group: no regions found.");
+		return 0;
+	};
+
+	if (!(regions = dm_bitset_parse_list(members, NULL))) {
+		log_error("Could not parse list: '%s'", members);
+		goto bad;
+	}
+
+	/* too many bits? */
+	if ((*regions - 1) > dms->max_region) {
+		log_error("Invalid region ID: %d", *regions - 1);
+		goto bad;
+	}
+
+	for (i = dm_bit_get_first(regions); i >= 0;
+	     i = dm_bit_get_next(regions, i)) {
+		if (!dm_stats_region_present(dms, i)) {
+			log_error("Region ID %d does not exist", i);
+			goto bad;
+		}
+		if (_stats_region_is_grouped(dms, i)) {
+			log_error("Region ID %d already a member of group ID "
+				  FMTu64, i, dms->regions[i].group_id);
+			goto bad;
+		}
+
+		if (dms->regions[i].timescale == 1)
+			precise++;
+
+		count++;
+	}
+
+	if (precise && (precise != count))
+		log_warn("Grouping regions with different clock resolution: "
+			 "precision may be lost");
+
+	if (!_stats_group_check_overlap(dms, regions, count))
+		log_info("Creating group with overlapping regions");
+
+	if (!_stats_create_group(dms, regions, alias, group_id))
+		goto bad;
+
+	return 1;
+bad:
+	dm_bitset_destroy(regions);
+	return 0;
+}
+
+/*
+ * Remove the specified group_id.
+ */
+int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id)
+{
+	if (group_id > dms->max_region) {
+		log_error("Invalid group ID: " FMTu64, group_id);
+		return 0;
+	}
+
+	if (!_stats_group_id_present(dms, group_id)) {
+		log_error("Group ID " FMTu64 " does not exist", group_id);
+		return 0;
+	}
+
+	_stats_clear_group_regions(dms, group_id);
+	_stats_group_destroy(&dms->groups[group_id]);
+
+	if (!_stats_set_aux(dms, group_id, dms->regions[group_id].aux_data))
+		return 0;
+	return 1;
+}
+
+uint64_t dm_stats_get_group_id(const struct dm_stats *dms, uint64_t region_id)
+{
+	return dms->regions[region_id].group_id;
+}
+
+int dm_stats_get_group_descriptor(const struct dm_stats *dms,
+				  uint64_t group_id, char **buf)
+{
+	dm_bitset_t regions = dms->groups[group_id].regions;
+	size_t buflen;
+
+	buflen = _stats_group_tag_len(dms, regions);
+
+	*buf = dm_pool_alloc(dms->mem, buflen);
+	if (!*buf) {
+		log_error("Could not allocate memory for regions string");
+		return 0;
+	}
+
+	if (!_stats_group_tag_fill(dms, regions, *buf, buflen))
+		return 0;
+
+	return 1;
+}
+
+/*
  * Backward compatible dm_stats_create_region() implementations.
  *
  * Keep these at the end of the file to avoid adding clutter around the


