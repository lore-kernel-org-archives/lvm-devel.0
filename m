From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:23 +0000 (UTC)
Subject: master - metadata: add historical_glv_remove
Message-ID: <20160303132023.0CCF860308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f833a6d074979813e8bd9980b719b09758bd833a
Commit:        f833a6d074979813e8bd9980b719b09758bd833a
Parent:        ccebf3100deec6196c1a66301a36cad6892ff0aa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:26:57 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:57 2016 +0100

metadata: add historical_glv_remove

---
 lib/format_text/import_vsn1.c    |    4 +-
 lib/metadata/lv_manip.c          |   68 ++++++++++++++++++++++++++++++++++++-
 lib/metadata/metadata-exported.h |    4 ++
 lib/metadata/metadata.c          |    5 ++-
 lib/metadata/vg.c                |    1 +
 lib/metadata/vg.h                |    5 +++
 6 files changed, 82 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 163ea38..3bf5f7b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -788,7 +788,7 @@ static int _read_historical_lvnames_interconnections(struct format_instance *fid
 	historical_lv_name = hlvn->key;
 	hlvn = hlvn->child;
 
-	if (!(glv = find_historical_glv(vg, historical_lv_name, NULL))) {
+	if (!(glv = find_historical_glv(vg, historical_lv_name, 0, NULL))) {
 		log_error("Unknown historical logical volume %s/%s%s",
 			  vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
 		goto bad;
@@ -828,7 +828,7 @@ static int _read_historical_lvnames_interconnections(struct format_instance *fid
 		glvl->glv = glv;
 
 		if (!strncmp(origin_name, HISTORICAL_LV_PREFIX, strlen(HISTORICAL_LV_PREFIX))) {
-			if (!(origin_glv = find_historical_glv(vg, origin_name + strlen(HISTORICAL_LV_PREFIX), NULL))) {
+			if (!(origin_glv = find_historical_glv(vg, origin_name + strlen(HISTORICAL_LV_PREFIX), 0, NULL))) {
 				log_error("Unknown origin %s for historical logical volume %s/%s%s",
 					  origin_name, vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
 				goto bad;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e355cc4..c612873 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1398,11 +1398,75 @@ int lv_reduce(struct logical_volume *lv, uint32_t extents)
 	return _lv_reduce(lv, extents, 1);
 }
 
+int historical_glv_remove(struct generic_logical_volume *glv)
+{
+	struct generic_logical_volume *origin_glv;
+	struct glv_list *glvl, *user_glvl;
+	struct historical_logical_volume *hlv;
+	int reconnected;
+
+	if (!glv || !glv->is_historical)
+		return_0;
+
+	hlv = glv->historical;
+
+	if (!(glv = find_historical_glv(hlv->vg, hlv->name, 0, &glvl))) {
+		if (!(find_historical_glv(hlv->vg, hlv->name, 1, NULL))) {
+			log_error(INTERNAL_ERROR "historical_glv_remove: historical LV %s/-%s not found ",
+				  hlv->vg->name, hlv->name);
+			return 0;
+		} else {
+			log_verbose("Historical LV %s/-%s already on removed list ",
+				    hlv->vg->name, hlv->name);
+			return 1;
+		}
+	}
+
+	if ((origin_glv = hlv->indirect_origin) &&
+	    !remove_glv_from_indirect_glvs(origin_glv, glv))
+		return_0;
+
+	dm_list_iterate_items(user_glvl, &hlv->indirect_glvs) {
+		reconnected = 0;
+		if ((origin_glv && !origin_glv->is_historical) && !user_glvl->glv->is_historical)
+			log_verbose("Removing historical connection between %s and %s.",
+				     origin_glv->live->name, user_glvl->glv->live->name);
+		else if (hlv->vg->cmd->record_historical_lvs) {
+			if (!add_glv_to_indirect_glvs(hlv->vg->vgmem, origin_glv, user_glvl->glv))
+				return_0;
+			reconnected = 1;
+		}
+
+		if (!reconnected) {
+			/*
+			 * Break ancestry chain if we're removing historical LV and tracking
+			 * historical LVs is switched off either via:
+			 *   - "metadata/record_lvs_history=0" config
+			 *   - "--nohistory" cmd line option
+			 *
+			 * Also, break the chain if we're unable to store such connection at all
+			 * because we're removing the very last historical LV that was in between
+			 * live LVs - pure live LVs can't store any indirect origin relation in
+			 * metadata - we need at least one historical LV to do that!
+			 */
+			if (user_glvl->glv->is_historical)
+				user_glvl->glv->historical->indirect_origin = NULL;
+			else
+				first_seg(user_glvl->glv->live)->indirect_origin = NULL;
+		}
+	}
+
+	dm_list_move(&hlv->vg->removed_historical_lvs, &glvl->list);
+	return 1;
+}
+
 /*
  * Completely remove an LV.
  */
 int lv_remove(struct logical_volume *lv)
 {
+	if (lv_is_historical(lv))
+		return historical_glv_remove(lv->this_glv);
 
 	if (!lv_reduce(lv, lv->le_count))
 		return_0;
@@ -5740,9 +5804,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		is_last_pool = 1;
 	}
 
-	/* Used cache pool or COW cannot be activated */
+	/* Used cache pool, COW or historical LV cannot be activated */
 	if ((!lv_is_cache_pool(lv) || dm_list_empty(&lv->segs_using_this_lv)) &&
-	    !lv_is_cow(lv) &&
+	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
 	    !deactivate_lv(cmd, lv)) {
 		/* FIXME Review and fix the snapshot error paths! */
 		log_error("Unable to deactivate logical volume %s.",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b8699f7..d81166d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -807,6 +807,9 @@ int lv_extend(struct logical_volume *lv,
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
 
+/* historical_glv must be part of lv->vg->historical_lvs */
+int historical_glv_remove(struct generic_logical_volume *historical_glv);
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     force_t force, int suppress_remove_message);
 
@@ -1029,6 +1032,7 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 
 struct generic_logical_volume *find_historical_glv(const struct volume_group *vg,
 						    const char *historical_lv_name,
+						    int check_removed_list,
 						    struct glv_list **glvl_found);
 
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8b3c53c..c37c7ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2122,10 +2122,13 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 
 struct generic_logical_volume *find_historical_glv(const struct volume_group *vg,
 					       const char *historical_lv_name,
+					       int check_removed_list,
 					       struct glv_list **glvl_found)
 {
 	struct glv_list *glvl;
 	const char *ptr;
+	const struct dm_list *list = check_removed_list ? &vg->removed_historical_lvs
+							: &vg->historical_lvs;
 
 	/* Use last component */
 	if ((ptr = strrchr(historical_lv_name, '/')))
@@ -2133,7 +2136,7 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 	else
 		ptr = historical_lv_name;
 
-	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+	dm_list_iterate_items(glvl, list) {
 		if (!strcmp(glvl->glv->historical->name, ptr)) {
 			if (glvl_found)
 				*glvl_found = glvl;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 90c459e..7ac1a2c 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -67,6 +67,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->historical_lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_lvs);
+	dm_list_init(&vg->removed_historical_lvs);
 	dm_list_init(&vg->removed_pvs);
 
 	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index c5197cb..069cdc8 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -142,6 +142,11 @@ struct volume_group {
 	struct dm_list removed_lvs;
 
 	/*
+	 * List of removed historical logical volumes by historical_glv_remove.
+	 */
+	struct dm_list removed_historical_lvs;
+
+	/*
 	 * List of removed physical volumes by pvreduce.
 	 * They have to get cleared on vg_commit.
 	 */


