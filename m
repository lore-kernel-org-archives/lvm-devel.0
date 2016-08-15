From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon, 15 Aug 2016 16:22:56 +0000 (UTC)
Subject: master - pvmove: prohibit non-resilient collocation of RAID SubLVs
Message-ID: <20160815162256.C1C8A60D22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e
Commit:        8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e
Parent:        c7bd33d9516dd6d146a02b4af43eb142a4f0aa26
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 15 18:22:32 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 15 18:22:32 2016 +0200

pvmove: prohibit non-resilient collocation of RAID SubLVs

'pvmove -n name pv1 pv2' allows to collocate multiple RAID SubLVs
on pv2 (e.g. results in collocated raidlv_rimage_0 and raidlv_rimage_1),
thus causing loss of resilence and/or performance of the RaidLV.

Fix this pvmove flaw leading to potential data loss in case of PV failure
by preventing any SubLVs from collocation on any PVs of the RaidLV.
Still allow to collocate any DataLVs of a RaidLV with their sibling MetaLVs
and vice-versa though (e.g. raidlv_rmeta_0 on pv1 may still be moved to pv2
already holding raidlv_rimage_0).

Because access to the top-level RaidLV name is needed,
promote local _top_level_lv_name() from raid_manip.c
to global top_level_lv_name().

- resolves rhbz1202497
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |    9 ++--
 tools/pvmove.c                   |   85 ++++++++++++++++++++++++++++++++++++--
 4 files changed, 88 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d78b281..60bdc4f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Fix 'pvmove -n name ...' to prohibit collocation of RAID SubLVs
 
 Version 2.02.164 - 15th August 2016
 ===================================
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3329535..97692dc 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1272,6 +1272,7 @@ uint32_t find_free_lvnum(struct logical_volume *lv);
 dm_percent_t copy_percent(const struct logical_volume *lv_mirr);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
+char *top_level_lv_name(struct volume_group *vg, const char *lv_name);
 
 struct generic_logical_volume *get_or_create_glv(struct dm_pool *mem, struct logical_volume *lv, int *glv_created);
 struct glv_list *get_or_create_glvl(struct dm_pool *mem, struct logical_volume *lv, int *glv_created);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a7814a8..d0934f4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -109,16 +109,17 @@ static void _check_and_adjust_region_size(const struct logical_volume *lv)
 }
 
 /* Strip any raid suffix off LV name */
-static char *_top_level_raid_lv_name(struct logical_volume *lv)
+char *top_level_lv_name(struct volume_group *vg, const char *lv_name)
 {
 	char *new_lv_name, *suffix;
 
-	if (!(new_lv_name = dm_pool_strdup(lv->vg->vgmem, lv->name))) {
+	if (!(new_lv_name = dm_pool_strdup(vg->vgmem, lv_name))) {
 		log_error("Failed to allocate string for new LV name.");
 		return NULL;
 	}
         
-	if ((suffix = first_substring(new_lv_name, "_rimage_", "_mimage_", NULL)))
+	if ((suffix = first_substring(new_lv_name, "_rimage_", "_rmeta_",
+						   "_mimage_", "_mlog_", NULL)))
 		*suffix = '\0';
 
 	return new_lv_name;
@@ -731,7 +732,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-	if (!(base_name = _top_level_raid_lv_name(data_lv)))
+	if (!(base_name = top_level_lv_name(data_lv->vg, data_lv->name)))
 		return_0;
 
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index f937c12..f491d58 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -145,6 +145,74 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 }
 
 /*
+ * If @lv_name's a RAID SubLV, check for any PVs
+ * on @trim_list holding it's sibling (rimage/rmeta)
+ * and remove it from the @trim_list in order to allow
+ * for pvmove collocation of DataLV/MetaLV pairs.
+ */
+static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
+					      const char *lv_name,
+					      struct dm_list *trim_list)
+{
+	char *idx, *suffix, *sublv_name;
+	size_t len;
+	struct logical_volume *sublv;
+	struct dm_list untrim_list, *pvh1, *pvh2;
+	struct pv_list *pvl1, *pvl2;
+
+	/* Give up with success unless @lv_name _and_ valid raid segment type */
+	if (!lv_name || !*lv_name ||
+	    !seg_is_raid(first_seg(lv)) ||
+	    seg_is_raid0(first_seg(lv)))
+		return 1;
+
+	dm_list_init(&untrim_list);
+
+	if (!(suffix = first_substring(lv_name, "_rimage_", "_rmeta_", NULL)))
+		return 0;
+
+	if (!(idx = strstr(suffix + 1, "_")))
+		return 0;
+	idx++;
+
+	/* + 2 for the longer rimage string */
+	if (!(sublv_name = dm_pool_alloc(lv->vg->cmd->mem, strlen(lv_name + 2))))
+		return_0;
+
+	/* Create the siblings name (e.g. "raidlv_rmeta_N" -> "raidlv_rimage_N" */
+	len = suffix - lv_name;
+	strncpy(sublv_name, lv_name, len);
+	sprintf(sublv_name + len, strstr(suffix, "_rimage_") ? "_rmeta_%s" : "_rimage_%s", idx);
+
+	if (!(sublv = find_lv(lv->vg, sublv_name))) {
+		log_error("Can't find sub LV %s?", sublv_name);
+		return_0;
+	}
+
+	if (!get_pv_list_for_lv(lv->vg->cmd->mem, sublv, &untrim_list)) {
+		log_error("Can't find PVs for sub LV %s?", sublv_name);
+		return_0;
+	}
+
+	dm_list_iterate(pvh1, &untrim_list) {
+		pvl1 = dm_list_item(pvh1, struct pv_list);
+
+		dm_list_iterate(pvh2, trim_list) {
+			pvl2 = dm_list_item(pvh2, struct pv_list);
+
+			if (pvl1->pv == pvl2->pv) {
+				log_debug("Removing PV %s from trim list",
+					  pvl2->pv->dev->pvid);
+				dm_list_del(&pvl2->list);
+				break;
+			}
+		}
+	}
+
+	return 1;
+}
+
+/*
  * _trim_allocatable_pvs
  * @alloc_list
  * @trim_list
@@ -324,7 +392,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv == lv_mirr)
 			continue;
 
-		if (lv_name && strcmp(lv->name, lv_name))
+		if (lv_name && strcmp(lv->name, top_level_lv_name(vg, lv_name)))
 			continue;
 
 		/*
@@ -334,7 +402,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		 *
 		 * Allow clustered mirror, but not raid mirror.
 		 */
-		if (vg_is_clustered(lv->vg) && !lv_is_mirror_type(lv))
+		if (vg_is_clustered(vg) && !lv_is_mirror_type(lv))
 			continue;
 
 		if (!lv_is_on_pvs(lv, source_pvl))
@@ -351,8 +419,16 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		    seg_is_mirrored(first_seg(lv))) {
 			dm_list_init(&trim_list);
 
-			if (!get_pv_list_for_lv(lv->vg->cmd->mem,
-						lv, &trim_list))
+			if (!get_pv_list_for_lv(vg->cmd->mem, lv, &trim_list))
+				return_NULL;
+
+			/*
+ 			 * Remove any PVs holding SubLV siblings to allow
+ 			 * for collocation (e.g. *rmeta_0 -> *rimage_0).
+ 			 *
+ 			 * Callee checks for lv_name and valid raid segment type.
+ 			 */
+			if (!_remove_sibling_pvs_from_trim_list(lv, lv_name, &trim_list))
 				return_NULL;
 
 			if (!_trim_allocatable_pvs(allocatable_pvs,
@@ -370,6 +446,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		lv = lvl->lv;
 		if (lv == lv_mirr)
 			continue;
+
 		if (lv_name) {
 			if (strcmp(lv->name, lv_name) && !sub_lv_of(lv, lv_name))
 				continue;


