From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 20:31:54 +0000 (UTC)
Subject: master - libdm: check for non-existent region_id values in groups
Message-ID: <20161213203154.EA9EB60659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e339728283d3b83222a25c7bf12b79a944c6ef5
Commit:        8e339728283d3b83222a25c7bf12b79a944c6ef5
Parent:        99b6d82e2dac7ef097fa940c64456620930d7758
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 14:31:39 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 15:37:48 2016 +0000

libdm: check for non-existent region_id values in groups

Check that all region_id values specified in a group bitmap are
actually present: although this should not normally happen when
using the dmstats tool, it is possible as a result of manual
changes (or bugs) for a group descriptor to contain one or more
group_id values that do not exist.

Check for this situation when reading group descriptors, warn
the user the user, and clear these bits in the bitmap when
formatting it for output.
---
 libdm/libdm-stats.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5833ac6..2d2a032 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -645,6 +645,23 @@ static void _stats_update_groups(struct dm_stats *dms)
 	}
 }
 
+static void _check_group_regions_present(struct dm_stats *dms,
+					 struct dm_stats_group *group)
+{
+	dm_bitset_t regions = group->regions;
+	int64_t i, group_id;
+
+	group_id = i = dm_bit_get_first(regions);
+
+	for (; i > 0; dm_bit_get_next(regions, i))
+		if (!_stats_region_present(&dms->regions[i])) {
+			log_warn("Group descriptor " FMTi64 " contains "
+				 "non-existent region_id " FMTi64 ".",
+				 group_id, i);
+			dm_bit_clear(regions, i);
+		}
+}
+
 /*
  * Parse a DMS_GROUP group descriptor embedded in a region's aux_data.
  *
@@ -1030,6 +1047,9 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	dms->regions = dm_pool_end_object(mem);
 	dms->groups = dm_pool_end_object(group_mem);
 
+	dm_stats_foreach_group(dms)
+		_check_group_regions_present(dms, &dms->groups[dms->cur_group]);
+
 	_stats_update_groups(dms);
 
 	if (fclose(list_rows))
@@ -1742,17 +1762,12 @@ bad:
 static size_t _stats_group_tag_len(const struct dm_stats *dms,
 				   dm_bitset_t regions)
 {
-	int i, j, next, nr_regions = 0;
+	int64_t i, j, next, nr_regions = 0;
 	size_t buflen = 0, id_len = 0;
 
 	/* check region ids and find last set bit */
 	i = dm_bit_get_first(regions);
 	for (; i >= 0; i = dm_bit_get_next(regions, i)) {
-		if (!dm_stats_region_present(dms, i)) {
-			log_error("Region identifier %d not found", i);
-			return 0;
-		}
-
 		/* length of region_id or range start in characters */
 		id_len = (i) ? 1 + (size_t) log10(i) : 1;
 		buflen += id_len;


