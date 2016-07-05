From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:34:56 +0000 (UTC)
Subject: master - libdm: allow deleting regions with dm_stats_delete_group()
Message-ID: <20160705183456.679FA60F8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5160936b152670f90eb02aee8902d3f5390c7f55
Commit:        5160936b152670f90eb02aee8902d3f5390c7f55
Parent:        d6aea67a1786baf306287e722fda61f4da2e2b95
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 1 13:14:41 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

libdm: allow deleting regions with dm_stats_delete_group()

Add a flag to dm_stats_delete_group() to allow optional deletion
of all regions belonging to the group being removed.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    7 +++++--
 libdm/libdm-stats.c  |   27 ++++++++++++++++++++++++---
 3 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 04ba142..79ac489 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.129 - 
 =================================
+  Allow dm_stats_delete_group() to optionally delete all group members.
   Add dm_stats_get_object_type() to return the type of object present.
   Add dm_stats_walk_init() allowing control of objects visited by walks.
   Add dm_stats_get_group_descriptor() to return the member list as a string.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a1db12a..2fd8061 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1205,9 +1205,12 @@ int dm_stats_create_group(struct dm_stats *dms, const char *group,
 			  const char *alias, uint64_t *group_id);
 
 /*
- * Remove the specified group_id.
+ * Remove the specified group_id. If the remove argument is zero the
+ * group will be removed but the regions that it contained will remain.
+ * If remove is non-zero then all regions that belong to the group will
+ * also be removed.
  */
-int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id);
+int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id, int remove);
 
 /*
  * Set an alias for this group or region. The alias will be returned
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 4911b62..e1f05c7 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1969,8 +1969,8 @@ static int _stats_remove_region_id_from_group(struct dm_stats *dms,
 					      uint64_t region_id)
 {
 	struct dm_stats_region *region = &dms->regions[region_id];
-	dm_bitset_t regions = dms->groups[region_id].regions;
 	uint64_t group_id = region->group_id;
+	dm_bitset_t regions = dms->groups[group_id].regions;
 
 	if (!_stats_region_is_grouped(dms, region_id))
 		return_0;
@@ -3770,8 +3770,13 @@ bad:
 /*
  * Remove the specified group_id.
  */
-int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id)
+int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id,
+			  int remove_regions)
 {
+	struct dm_stats_region *leader;
+	dm_bitset_t regions;
+	uint64_t i;
+
 	if (group_id > dms->max_region) {
 		log_error("Invalid group ID: " FMTu64, group_id);
 		return 0;
@@ -3782,11 +3787,27 @@ int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id)
 		return 0;
 	}
 
+	regions = dms->groups[group_id].regions;
+	leader = &dms->regions[group_id];
+
+	/* delete all but the group leader */
+	for (i = (*regions - 1); i > leader->region_id; i--) {
+		if (dm_bit(regions, i)) {
+			dm_bit_clear(regions, i);
+			if (remove_regions && !dm_stats_delete_region(dms, i))
+				log_warn("Failed to delete region "
+					 FMTu64 " on %s.", i, dms->name);
+		}
+	}
+
 	_stats_clear_group_regions(dms, group_id);
 	_stats_group_destroy(&dms->groups[group_id]);
 
-	if (!_stats_set_aux(dms, group_id, dms->regions[group_id].aux_data))
+	if (remove_regions)
+		return dm_stats_delete_region(dms, group_id);
+	else if (!_stats_set_aux(dms, group_id, leader->aux_data))
 		return 0;
+
 	return 1;
 }
 


