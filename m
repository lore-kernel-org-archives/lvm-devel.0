From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:51 +0000 (UTC)
Subject: master - libdm: allow regions with histograms in dm_stats_create_group()
Message-ID: <20160708182651.1FC8C610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db73d756e9481a867dd486e624eb1cba7c4def42
Commit:        db73d756e9481a867dd486e624eb1cba7c4def42
Parent:        ae9cffba5297e3b3f5c5ea69469188fbfae07b0e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jul 3 22:55:33 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

libdm: allow regions with histograms in dm_stats_create_group()

Allow regions with histograms to be grouped if all histograms have
the same number of bins and matching bounds.
---
 libdm/libdm-stats.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 0aca622..55f1010 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3860,6 +3860,39 @@ merge:
 	return overlap;
 }
 
+static void _stats_copy_histogram_bounds(struct dm_histogram *to,
+					 struct dm_histogram *from)
+{
+	uint64_t i;
+
+	to->nr_bins = from->nr_bins;
+
+	for (i = 0; i < to->nr_bins; i++)
+		to->bins[i].upper = from->bins[i].upper;
+}
+
+/*
+ * Compare histogram bounds h1 and h2, and return 1 if they match (i.e.
+ * have the same number of bins and identical bin boundary values), or 0
+ * otherwise.
+ */
+static int _stats_check_histogram_bounds(struct dm_histogram *h1,
+					 struct dm_histogram *h2)
+{
+	uint64_t i;
+
+	if (!h1 || !h2)
+		return 0;
+
+	if (h1->nr_bins != h2->nr_bins)
+		return 0;
+
+	for (i = 0; i < h1->nr_bins; i++)
+		if (h1->bins[i].upper != h2->bins[i].upper)
+			return 0;
+	return 1;
+}
+
 /*
  * Create a new group in stats handle dms from the group description
  * passed in group.
@@ -3867,6 +3900,7 @@ merge:
 int dm_stats_create_group(struct dm_stats *dms, const char *members,
 			  const char *alias, uint64_t *group_id)
 {
+	struct dm_histogram *check = NULL, *bounds;
 	int i, count = 0, precise = 0;
 	dm_bitset_t regions;
 
@@ -3877,6 +3911,11 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 
 	if (!(regions = dm_bitset_parse_list(members, NULL))) {
 		log_error("Could not parse list: '%s'", members);
+		return 0;
+	}
+
+	if (!(check = dm_pool_zalloc(dms->hist_mem, sizeof(*check)))) {
+		log_error("Could not allocate memory for bounds check");
 		goto bad;
 	}
 
@@ -3902,14 +3941,20 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 				  FMTu64, i, dms->regions[i].group_id);
 			goto bad;
 		}
-		if (dms->regions[i].bounds) {
-			log_error("Region ID %d: grouping regions with "
-				  "histograms is not yet supported", i);
-			goto bad;
-		}
 		if (dms->regions[i].timescale == 1)
 			precise++;
 
+		/* check for matching histogram bounds */
+		bounds = dms->regions[i].bounds;
+		if (bounds && !check->nr_bins)
+			_stats_copy_histogram_bounds(check, bounds);
+		else if (bounds) {
+			if (!_stats_check_histogram_bounds(check, bounds)) {
+				log_error("All region histogram bounds "
+					  "must match exactly");
+				goto bad;
+			}
+		}
 		count++;
 	}
 
@@ -3923,8 +3968,11 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 	if (!_stats_create_group(dms, regions, alias, group_id))
 		goto bad;
 
+	dm_pool_free(dms->hist_mem, check);
 	return 1;
+
 bad:
+	dm_pool_free(dms->hist_mem, check);
 	dm_bitset_destroy(regions);
 	return 0;
 }


