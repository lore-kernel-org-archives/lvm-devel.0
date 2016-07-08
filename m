From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:48 +0000 (UTC)
Subject: master - libdm: add aggregation support to dm_stats_get_histogram()
Message-ID: <20160708182648.F363160FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae9cffba5297e3b3f5c5ea69469188fbfae07b0e
Commit:        ae9cffba5297e3b3f5c5ea69469188fbfae07b0e
Parent:        d901468a273327b78207e60fde2ab5f8c3a6cbc7
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jul 3 21:59:31 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

libdm: add aggregation support to dm_stats_get_histogram()

Support aggregate group and region histograms by allocating a new
histogram from the pool and populating it with a sum of the histogram
data for the areas contained in the region or group.

To avoid repeatedly summing the same histogram data, cache the pointer
in the group and regions structs for subsequent access. The aggregate
histograms are allocated from the same pool as the area histograms in
the corresponding handle and will be discarded at each list or populate
operation.
---
 libdm/libdm-stats.c |  134 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 126 insertions(+), 8 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 2393edd..0aca622 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -85,6 +85,7 @@ struct dm_stats_region {
 	char *aux_data;
 	uint64_t timescale; /* precise_timestamps is per-region */
 	struct dm_histogram *bounds; /* histogram configuration */
+	struct dm_histogram *histogram; /* aggregate cache */
 	struct dm_stats_counters *counters;
 };
 
@@ -92,6 +93,7 @@ struct dm_stats_group {
 	uint64_t group_id;
 	const char *alias;
 	dm_bitset_t regions;
+	struct dm_histogram *histogram;
 };
 
 struct dm_stats {
@@ -339,6 +341,8 @@ static void _stats_group_destroy(struct dm_stats_group *group)
 	if (!_stats_group_present(group))
 		return;
 
+	group->histogram = NULL;
+
 	if (group->alias) {
 		dm_free((char *) group->alias);
 		group->alias = NULL;
@@ -899,6 +903,9 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 	} else
 		region->bounds = NULL;
 
+	/* clear aggregate cache */
+	region->histogram = NULL;
+
 	region->group_id = DM_STATS_GROUP_NOT_PRESENT;
 
 	if (!(region->program_id = dm_strdup(program_id)))
@@ -3177,21 +3184,132 @@ int dm_stats_get_current_region_precise_timestamps(const struct dm_stats *dms)
  * Histogram access methods.
  */
 
+static void _sum_histogram_bins(const struct dm_stats *dms,
+				struct dm_histogram *dmh_aggr,
+				uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_region *region;
+	struct dm_histogram_bin *bins;
+	struct dm_histogram *dmh_cur;
+	uint64_t bin;
+
+	region = &dms->regions[region_id];
+	dmh_cur = region->counters[area_id].histogram;
+	bins = dmh_aggr->bins;
+
+	for (bin = 0; bin < dmh_aggr->nr_bins; bin++)
+		bins[bin].count += dmh_cur->bins[bin].count;
+}
+
+/*
+ * Create an aggregate histogram for a sub-divided region or a group.
+ */
+static struct dm_histogram *_aggregate_histogram(const struct dm_stats *dms,
+						 uint64_t region_id,
+						 uint64_t area_id)
+{
+	struct dm_histogram *dmh_aggr, *dmh_cur, **dmh_cachep;
+	int bin, nr_bins, group = 1;
+	uint64_t group_id;
+	size_t hist_size;
+
+	if (area_id == DM_STATS_WALK_REGION) {
+		/* region aggregation */
+		group = 0;
+		if (!_stats_region_present(&dms->regions[region_id]))
+			return_NULL;
+
+		if (!dms->regions[region_id].bounds)
+			return_NULL;
+
+		if (!dms->regions[region_id].counters)
+			return dms->regions[region_id].bounds;
+
+		if (dms->regions[region_id].histogram)
+			return dms->regions[region_id].histogram;
+
+		dmh_cur = dms->regions[region_id].counters[0].histogram;
+		dmh_cachep = &dms->regions[region_id].histogram;
+		nr_bins = dms->regions[region_id].bounds->nr_bins;
+	} else {
+		/* group aggregation */
+		group_id = region_id;
+		area_id = DM_STATS_WALK_GROUP;
+		if (!_stats_group_id_present(dms, group_id))
+			return_NULL;
+
+		if (!dms->regions[group_id].bounds)
+			return_NULL;
+
+		if (!dms->regions[group_id].counters)
+			return dms->regions[group_id].bounds;
+
+		if (dms->groups[group_id].histogram)
+			return dms->groups[group_id].histogram;
+
+		dmh_cur = dms->regions[group_id].counters[0].histogram;
+		dmh_cachep = &dms->groups[group_id].histogram;
+		nr_bins = dms->regions[group_id].bounds->nr_bins;
+	}
+
+	hist_size = sizeof(*dmh_aggr)
+		     + nr_bins * sizeof(struct dm_histogram_bin);
+
+	if (!(dmh_aggr = dm_pool_zalloc(dms->hist_mem, hist_size))) {
+		log_error("Could not allocate group histogram");
+		return 0;
+	}
+
+	dmh_aggr->nr_bins = dmh_cur->nr_bins;
+	dmh_aggr->dms = dms;
+
+	if (!group)
+		_foreach_region_area(dms, region_id, area_id) {
+			_sum_histogram_bins(dms, dmh_aggr, region_id, area_id);
+		}
+	else {
+		_foreach_group_area(dms, group_id, region_id, area_id) {
+			_sum_histogram_bins(dms, dmh_aggr, region_id, area_id);
+		}
+	}
+
+	for (bin = 0; bin < nr_bins; bin++) {
+		dmh_aggr->sum += dmh_aggr->bins[bin].count;
+		dmh_aggr->bins[bin].upper = dmh_cur->bins[bin].upper;
+	}
+
+	/* cache aggregate histogram for subsequent access */
+	*dmh_cachep = dmh_aggr;
+
+	return dmh_aggr;
+}
+
 struct dm_histogram *dm_stats_get_histogram(const struct dm_stats *dms,
 					    uint64_t region_id,
 					    uint64_t area_id)
 {
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_AREA_CURRENT)
-		     ? dms->cur_area : area_id ;
+	int aggr = 0;
 
-	/* FIXME return histogram sum? Requires bounds check at group time */
-	if (region_id & DM_STATS_WALK_GROUP) {
-		log_err_once("Group histogram data is not supported");
-		return NULL;
+	if (region_id == DM_STATS_REGION_CURRENT) {
+		region_id = dms->cur_region;
+		if (region_id & DM_STATS_WALK_GROUP) {
+			region_id = dms->cur_group;
+			aggr = 1;
+		}
+	} else if (region_id & DM_STATS_WALK_GROUP) {
+		region_id &= ~DM_STATS_WALK_GROUP;
+		aggr = 1;
 	}
 
+	area_id = (area_id == DM_STATS_AREA_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	if (area_id == DM_STATS_WALK_REGION)
+		aggr = 1;
+
+	if (aggr)
+		return _aggregate_histogram(dms, region_id, area_id);
+
 	if (region_id & DM_STATS_WALK_REGION)
 		region_id &= ~DM_STATS_WALK_REGION;
 


