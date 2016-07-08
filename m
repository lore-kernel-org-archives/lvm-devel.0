From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 11:31:36 +0000 (UTC)
Subject: master - libdm: improve comments in stats grouping functions
Message-ID: <20160708113136.83D3760F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc4f036d36a89a57f60dc87acfca5046f74c3f7d
Commit:        cc4f036d36a89a57f60dc87acfca5046f74c3f7d
Parent:        059a383cf8d3198ba6c77a18cea09c4a0a40032a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 11:05:38 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 11:16:12 2016 +0100

libdm: improve comments in stats grouping functions

Add more detailed comments to dm_stats_create_group() and
_stats_group_check_overlap().
---
 libdm/libdm-stats.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d89f77a..9b55813 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3686,6 +3686,7 @@ static int _stats_group_check_overlap(const struct dm_stats *dms,
 		return 0;
 	}
 
+	/* build a table of extents in order of region_id */
 	for (id = dm_bit_get_first(regions); id >= 0;
 	     id = dm_bit_get_next(regions, id)) {
 		dm_list_init(&map[i].list);
@@ -3695,6 +3696,7 @@ static int _stats_group_check_overlap(const struct dm_stats *dms,
 		i++;
 	}
 
+	/* sort by extent.start */
 	qsort(map, count, sizeof(*map), _extent_start_compare);
 
 	for (i = 0; i < count; i++)
@@ -3724,6 +3726,7 @@ merge:
 			overlap = merged = 1;
 		}
 	}
+	/* continue until no merge candidates remain */
 	if (merged)
 		goto merge;
 
@@ -3757,6 +3760,11 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 		goto bad;
 	}
 
+	/*
+	 * Check that each region_id in the bitmap meets the group
+	 * constraints: present, not already grouped, and if any
+	 * histogram is present that they all have the same bounds.
+	 */
 	for (i = dm_bit_get_first(regions); i >= 0;
 	     i = dm_bit_get_next(regions, i)) {
 		if (!dm_stats_region_present(dms, i)) {
@@ -3828,9 +3836,11 @@ int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id,
 		}
 	}
 
+	/* clear group and mark as not present */
 	_stats_clear_group_regions(dms, group_id);
 	_stats_group_destroy(&dms->groups[group_id]);
 
+	/* delete leader or clear aux_data */
 	if (remove_regions)
 		return dm_stats_delete_region(dms, group_id);
 	else if (!_stats_set_aux(dms, group_id, leader->aux_data))


