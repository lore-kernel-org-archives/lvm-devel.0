From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Aug 2016 14:40:55 +0000 (UTC)
Subject: master - alloc: Move _log_parallel_areas.
Message-ID: <20160824144055.BC8C460A91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=157fbd9699b1a03ab73c0fefdb524c68785ebe5b
Commit:        157fbd9699b1a03ab73c0fefdb524c68785ebe5b
Parent:        7837fbc1c191925ebe6bef74845d61396c1050e6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 24 15:39:56 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 24 15:40:26 2016 +0100

alloc: Move _log_parallel_areas.

---
 WHATS_NEW               |    2 +-
 lib/metadata/lv_manip.c |   86 +++++++++++++++++++++++-----------------------
 2 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 315e7f9..b94810c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.165 - 
 ===================================
-  Disallow segtype and mirror conversions of raid10 volumes.
+  Disallow mirror conversions of raid10 volumes.
   Fix dmeventd unmonitoring when segment type (and dso) changes.
   Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cb7e6b7..b13e924 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1674,49 +1674,6 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 		alloc_parms->flags |= A_CAN_SPLIT;
 }
 
-static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas)
-{
-	struct seg_pvs *spvs;
-	struct pv_list *pvl;
-	char *pvnames;
-
-	if (!parallel_areas)
-		return 1;
-
-	dm_list_iterate_items(spvs, parallel_areas) {
-		if (!dm_pool_begin_object(mem, 256)) {
-			log_error("dm_pool_begin_object failed");
-			return 0;
-		}
-
-		dm_list_iterate_items(pvl, &spvs->pvs) {
-			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
-				log_error("dm_pool_grow_object failed");
-				dm_pool_abandon_object(mem);
-				return 0;
-			}
-			if (!dm_pool_grow_object(mem, " ", 1)) {
-				log_error("dm_pool_grow_object failed");
-				dm_pool_abandon_object(mem);
-				return 0;
-			}
-		}
-
-		if (!dm_pool_grow_object(mem, "\0", 1)) {
-			log_error("dm_pool_grow_object failed");
-			dm_pool_abandon_object(mem);
-			return 0;
-		}
-
-		pvnames = dm_pool_end_object(mem);
-		log_debug_alloc("Parallel PVs at LE %" PRIu32 " length %" PRIu32 ": %s",
-				spvs->le, spvs->len, pvnames);
-		dm_pool_free(mem, pvnames);
-	}
-
-	return 1;
-}
-
 /* Handles also stacking */
 static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
 {
@@ -2212,6 +2169,49 @@ static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct
 	return 1;
 }
 
+static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas)
+{
+	struct seg_pvs *spvs;
+	struct pv_list *pvl;
+	char *pvnames;
+
+	if (!parallel_areas)
+		return 1;
+
+	dm_list_iterate_items(spvs, parallel_areas) {
+		if (!dm_pool_begin_object(mem, 256)) {
+			log_error("dm_pool_begin_object failed");
+			return 0;
+		}
+
+		dm_list_iterate_items(pvl, &spvs->pvs) {
+			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
+				log_error("dm_pool_grow_object failed");
+				dm_pool_abandon_object(mem);
+				return 0;
+			}
+			if (!dm_pool_grow_object(mem, " ", 1)) {
+				log_error("dm_pool_grow_object failed");
+				dm_pool_abandon_object(mem);
+				return 0;
+			}
+		}
+
+		if (!dm_pool_grow_object(mem, "\0", 1)) {
+			log_error("dm_pool_grow_object failed");
+			dm_pool_abandon_object(mem);
+			return 0;
+		}
+
+		pvnames = dm_pool_end_object(mem);
+		log_debug_alloc("Parallel PVs at LE %" PRIu32 " length %" PRIu32 ": %s",
+				spvs->le, spvs->len, pvnames);
+		dm_pool_free(mem, pvnames);
+	}
+
+	return 1;
+}
+
 static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
 			  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {


