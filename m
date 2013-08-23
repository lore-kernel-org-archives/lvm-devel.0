From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 23 Aug 2013 13:41:42 +0000 (UTC)
Subject: master - Misc: Make get_pv_list_for_lv() available to more than just RAID
Message-ID: <20130823134142.725C460520@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1e3640df31d0593e47ed82f3bb2f7e976b6569c
Commit:        f1e3640df31d0593e47ed82f3bb2f7e976b6569c
Parent:        be9f4c77c93f347131f46a128013b0f4af8e5b32
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 23 08:40:13 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 23 08:40:13 2013 -0500

Misc: Make get_pv_list_for_lv() available to more than just RAID

The function 'get_pv_list_for_lv' will assemble all the PVs that are
used by the specified LV.  It uses 'for_each_sub_lv' to traverse all
of the sub-lvs which may compose it.
---
 lib/metadata/lv_manip.c          |   74 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/raid_manip.c        |   45 ++---------------------
 3 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 24c66ef..ef64d12 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -161,6 +161,80 @@ int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 	return 0;
 }
 
+struct dm_list_and_mempool {
+	struct dm_list *list;
+	struct dm_pool *mem;
+};
+static int _get_pv_list_for_lv(struct cmd_context *cmd,
+			       struct logical_volume *lv, void *data)
+{
+	int dup_found;
+	uint32_t s;
+	struct pv_list *pvl;
+	struct lv_segment *seg;
+	struct dm_list *pvs = ((struct dm_list_and_mempool *)data)->list;
+	struct dm_pool *mem = ((struct dm_list_and_mempool *)data)->mem;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			dup_found = 0;
+
+			if (seg_type(seg, s) != AREA_PV)
+				continue;
+
+			/* do not add duplicates */
+			dm_list_iterate_items(pvl, pvs)
+				if (pvl->pv == seg_pv(seg, s))
+					dup_found = 1;
+
+			if (dup_found)
+				continue;
+
+			if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
+				log_error("Failed to allocate memory");
+				return 0;
+			}
+
+			pvl->pv = seg_pv(seg, s);
+			log_debug_metadata("  %s/%s uses %s", lv->vg->name,
+					   lv->name, pv_dev_name(pvl->pv));
+
+			dm_list_add(pvs, &pvl->list);
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * get_pv_list_for_lv
+ * @mem - mempool to allocate the list from.
+ * @lv
+ * @pvs - The list to add pv_list items to.
+ *
+ * 'pvs' is filled with 'pv_list' items for PVs that compose the LV.
+ * If the 'pvs' list already has items in it, duplicates will not be
+ * added.  So, it is safe to repeatedly call this function for different
+ * LVs and build up a list of PVs for them all.
+ *
+ * Memory to create the list is obtained from the mempool provided.
+ *
+ * Returns: 1 on success, 0 on error
+ */
+int get_pv_list_for_lv(struct dm_pool *mem,
+		       struct logical_volume *lv, struct dm_list *pvs)
+{
+	struct dm_list_and_mempool context = { pvs, mem };
+
+	log_debug_metadata("Generating list of PVs that %s/%s uses:",
+			   lv->vg->name, lv->name);
+
+	if (!_get_pv_list_for_lv(lv->vg->cmd, lv, &context))
+		return_0;
+
+	return for_each_sub_lv(lv->vg->cmd, lv, &_get_pv_list_for_lv, &context);
+}
+
 /*
  * get_default_region_size
  * @cmd
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d214fd2..0df710c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -828,6 +828,8 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 
 int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv);
 int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs);
+int get_pv_list_for_lv(struct dm_pool *mem,
+		       struct logical_volume *lv, struct dm_list *pvs);
 
 
 /* Find LV segment containing given LE */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 05f509a..47c2788 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -93,45 +93,6 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 	return 1;
 }
 
-static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
-{
-	uint32_t s;
-	struct pv_list *pvl;
-	struct lv_segment *seg = first_seg(lv);
-
-	if (!seg_is_linear(seg)) {
-		log_error(INTERNAL_ERROR
-			  "_get_pv_list_for_lv only handles linear volumes");
-		return 0;
-	}
-
-	log_debug_metadata("Getting list of PVs that %s/%s is on:",
-			   lv->vg->name, lv->name);
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV) {
-				log_error(INTERNAL_ERROR
-					  "Linear seg_type should be AREA_PV");
-				return 0;
-			}
-
-			if (!(pvl = dm_pool_zalloc(lv->vg->cmd->mem,
-						   sizeof(*pvl)))) {
-				log_error("Failed to allocate memory");
-				return 0;
-			}
-
-			pvl->pv = seg_pv(seg, s);
-			log_debug_metadata("  %s/%s is on %s", lv->vg->name, lv->name,
-					   pv_dev_name(pvl->pv));
-			dm_list_add(pvs, &pvl->list);
-		}
-	}
-
-	return 1;
-}
-
 /*
  * _raid_in_sync
  * @lv
@@ -528,7 +489,8 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	if ((p = strstr(base_name, "_mimage_")))
 		*p = '\0';
 
-	if (!_get_pv_list_for_lv(data_lv, &allocatable_pvs)) {
+	if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
+				data_lv, &allocatable_pvs)) {
 		log_error("Failed to build list of PVs for %s/%s",
 			  data_lv->vg->name, data_lv->name);
 		return 0;
@@ -1147,7 +1109,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 			/* Ensure we only split the tracking image */
 			dm_list_init(&tracking_pvs);
 			splittable_pvs = &tracking_pvs;
-			if (!_get_pv_list_for_lv(tracking, splittable_pvs))
+			if (!get_pv_list_for_lv(tracking->vg->cmd->mem,
+						tracking, splittable_pvs))
 				return_0;
 		}
 	}


