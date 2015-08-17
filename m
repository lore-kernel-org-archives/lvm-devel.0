From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 16:01:30 +0000 (UTC)
Subject: master - libdm-stats: only return uint64_t when required
Message-ID: <20150817160130.4CF25601C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4227b2ebb453410f00c0780d2d3a86b4dac4da24
Commit:        4227b2ebb453410f00c0780d2d3a86b4dac4da24
Parent:        15e20bb5c01190217969c4b2e42926af3709223c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 15:23:27 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 17 16:59:52 2015 +0100

libdm-stats: only return uint64_t when required

Several interfaced in libdm-stats return a uint64_t when it is
only used to signal success/failure: change all these uses to
return a simple int instead.
---
 libdm/libdevmapper.h |   44 +++++++++++++++++++++++---------------------
 libdm/libdm-stats.c  |   40 ++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index bfc90da..af08ba3 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -697,12 +697,14 @@ int dm_stats_set_program_id(struct dm_stats *dms, int allow_empty,
  *
  * All values are returned in units of 512b sectors.
  */
-uint64_t dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
-				   uint64_t region_id);
-uint64_t dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
-				 uint64_t region_id);
-uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms,
-				      uint64_t *area_len, uint64_t region_id);
+int dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
+			      uint64_t region_id);
+
+int dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
+			    uint64_t region_id);
+
+int dm_stats_get_region_area_len(const struct dm_stats *dms,
+				 uint64_t *len, uint64_t region_id);
 
 /*
  * Area properties: start, offset and length.
@@ -720,11 +722,11 @@ uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms,
  *
  * All values are returned in units of 512b sectors.
  */
-uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
-				 uint64_t region_id, uint64_t area_id);
+int dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
+			    uint64_t region_id, uint64_t area_id);
 
-uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
-				  uint64_t region_id, uint64_t area_id);
+int dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
+			     uint64_t region_id, uint64_t area_id);
 
 /*
  * Retrieve program_id and aux_data for a specific region. Only valid
@@ -864,14 +866,14 @@ uint64_t dm_stats_get_current_area(const struct dm_stats *dms);
  *
  * All values are returned in units of 512b sectors.
  */
-uint64_t dm_stats_get_current_region_start(const struct dm_stats *dms,
-					   uint64_t *start);
+int dm_stats_get_current_region_start(const struct dm_stats *dms,
+				      uint64_t *start);
 
-uint64_t dm_stats_get_current_region_len(const struct dm_stats *dms,
-					 uint64_t *len);
+int dm_stats_get_current_region_len(const struct dm_stats *dms,
+				    uint64_t *len);
 
-uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
-					      uint64_t *area_len);
+int dm_stats_get_current_region_area_len(const struct dm_stats *dms,
+					 uint64_t *area_len);
 
 /*
  * Current area properties: start and length.
@@ -881,13 +883,13 @@ uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
  *
  * All values are returned in units of 512b sectors.
  */
-uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
-					 uint64_t *start);
+int dm_stats_get_current_area_start(const struct dm_stats *dms,
+				    uint64_t *start);
 
-uint64_t dm_stats_get_current_area_offset(const struct dm_stats *dms,
-					  uint64_t *offset);
+int dm_stats_get_current_area_offset(const struct dm_stats *dms,
+				     uint64_t *offset);
 
-uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
+int dm_stats_get_current_area_len(const struct dm_stats *dms,
 				       uint64_t *start);
 
 /*
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 50492f3..f8d0012 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1280,7 +1280,7 @@ uint64_t dm_stats_get_current_area(const struct dm_stats *dms)
 	return dms->cur_area;
 }
 
-uint64_t dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
+int dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
 			      uint64_t region_id)
 {
 	if (!dms || !dms->regions)
@@ -1289,7 +1289,7 @@ uint64_t dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
 	return 1;
 }
 
-uint64_t dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
+int dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
 			    uint64_t region_id)
 {
 	if (!dms || !dms->regions)
@@ -1298,35 +1298,35 @@ uint64_t dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
 	return 1;
 }
 
-uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms, uint64_t *step,
-			    uint64_t region_id)
+int dm_stats_get_region_area_len(const struct dm_stats *dms, uint64_t *len,
+				 uint64_t region_id)
 {
 	if (!dms || !dms->regions)
 		return_0;
-	*step = dms->regions[region_id].step;
+	*len = dms->regions[region_id].step;
 	return 1;
 }
 
-uint64_t dm_stats_get_current_region_start(const struct dm_stats *dms,
-					   uint64_t *start)
+int dm_stats_get_current_region_start(const struct dm_stats *dms,
+				      uint64_t *start)
 {
 	return dm_stats_get_region_start(dms, start, dms->cur_region);
 }
 
-uint64_t dm_stats_get_current_region_len(const struct dm_stats *dms,
-					 uint64_t *len)
+int dm_stats_get_current_region_len(const struct dm_stats *dms,
+				    uint64_t *len)
 {
 	return dm_stats_get_region_len(dms, len, dms->cur_region);
 }
 
-uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
-					      uint64_t *step)
+int dm_stats_get_current_region_area_len(const struct dm_stats *dms,
+					 uint64_t *step)
 {
 	return dm_stats_get_region_area_len(dms, step, dms->cur_region);
 }
 
-uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
-				 uint64_t region_id, uint64_t area_id)
+int dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
+			    uint64_t region_id, uint64_t area_id)
 {
 	struct dm_stats_region *region = &dms->regions[region_id];
 	if (!dms || !dms->regions)
@@ -1335,8 +1335,8 @@ uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
 	return 1;
 }
 
-uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
-				  uint64_t region_id, uint64_t area_id)
+int dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
+			     uint64_t region_id, uint64_t area_id)
 {
 	if (!dms || !dms->regions)
 		return_0;
@@ -1344,22 +1344,22 @@ uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
 	return 1;
 }
 
-uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
-					 uint64_t *start)
+int dm_stats_get_current_area_start(const struct dm_stats *dms,
+				    uint64_t *start)
 {
 	return dm_stats_get_area_start(dms, start,
 				       dms->cur_region, dms->cur_area);
 }
 
-uint64_t dm_stats_get_current_area_offset(const struct dm_stats *dms,
+int dm_stats_get_current_area_offset(const struct dm_stats *dms,
 					  uint64_t *offset)
 {
 	return dm_stats_get_area_offset(dms, offset,
 				       dms->cur_region, dms->cur_area);
 }
 
-uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
-				       uint64_t *len)
+int dm_stats_get_current_area_len(const struct dm_stats *dms,
+				  uint64_t *len)
 {
 	return dm_stats_get_region_area_len(dms, len, dms->cur_region);
 }


