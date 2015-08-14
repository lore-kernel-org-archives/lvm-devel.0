From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:20 +0000 (UTC)
Subject: master - libdm: add dm_stats_get_{current_}area_offset()
Message-ID: <20150814210520.9906B60358@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00ed52365916753d0bd6eb0de09c46ad782fec2e
Commit:        00ed52365916753d0bd6eb0de09c46ad782fec2e
Parent:        77fae3d8522ffb1077dcb0e2e9ebfba86cf19daf
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 20:30:05 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

libdm: add dm_stats_get_{current_}area_offset()

Add a method to retrieve the offset of an area within the
containing region (rather than the offset within the containing
device returned by dm_stats_get_area_start()).

Although users of the library can calculate this themselves it is
better to provide this through a method call to avoid users making
assumptions about the structure of regions and areas.
---
 libdm/.exported_symbols.DM_1_02_105 |    2 ++
 libdm/libdevmapper.h                |   17 ++++++++++++++---
 libdm/libdm-stats.c                 |   15 +++++++++++++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_105 b/libdm/.exported_symbols.DM_1_02_105
index 9b701f1..4707164 100644
--- a/libdm/.exported_symbols.DM_1_02_105
+++ b/libdm/.exported_symbols.DM_1_02_105
@@ -1 +1,3 @@
 dm_report_is_empty
+dm_stats_get_area_offset
+dm_stats_get_current_area_offset
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 303ed67..bfc90da 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -705,19 +705,27 @@ uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms,
 				      uint64_t *area_len, uint64_t region_id);
 
 /*
- * Area properties: start and length.
+ * Area properties: start, offset and length.
  *
  * The area length is always equal to the area length of the region
  * that contains it and is obtained from dm_stats_get_region_area_len().
  *
- * The start offset of an area is a function of the area_id and the
- * containing region's start and area length.
+ * The start of an area is a function of the area_id and the containing
+ * region's start and area length: it gives the absolute offset into the
+ * containing device of the beginning of the area.
+ *
+ * The offset expresses the area's relative offset into the current
+ * region. I.e. the area start minus the start offset of the containing
+ * region.
  *
  * All values are returned in units of 512b sectors.
  */
 uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 				 uint64_t region_id, uint64_t area_id);
 
+uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
+				  uint64_t region_id, uint64_t area_id);
+
 /*
  * Retrieve program_id and aux_data for a specific region. Only valid
  * following a call to dm_stats_list(). The returned pointer does not
@@ -876,6 +884,9 @@ uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
 uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
 					 uint64_t *start);
 
+uint64_t dm_stats_get_current_area_offset(const struct dm_stats *dms,
+					  uint64_t *offset);
+
 uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
 				       uint64_t *start);
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 51aba79..400b12d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1335,6 +1335,14 @@ uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 	return 1;
 }
 
+uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
+				  uint64_t region_id, uint64_t area_id)
+{
+	if (!dms || !dms->regions)
+		return_0;
+	*offset = dms->regions[region_id].step * area_id;
+}
+
 uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
 					 uint64_t *start)
 {
@@ -1342,6 +1350,13 @@ uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
 				       dms->cur_region, dms->cur_area);
 }
 
+uint64_t dm_stats_get_current_area_offset(const struct dm_stats *dms,
+					  uint64_t *offset)
+{
+	return dm_stats_get_area_offset(dms, offset,
+				       dms->cur_region, dms->cur_area);
+}
+
 uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
 				       uint64_t *len)
 {


