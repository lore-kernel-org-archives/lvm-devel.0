From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:33 +0000 (UTC)
Subject: master - metadata: also look at historical LVs when checking LV name availability
Message-ID: <20160303132033.7C1F460310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc628e92ba1b403988a0b058d0d3283d23bab5bf
Commit:        fc628e92ba1b403988a0b058d0d3283d23bab5bf
Parent:        0ab111016470d694abf8bbd89df0360061f2736e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:31:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

metadata: also look at historical LVs when checking LV name availability

Live LVs and historical LVs are in one namespace and the name needs to
be unique in whole VG.
---
 lib/metadata/lv_manip.c          |   39 +++++++++++++++++++++++++++----------
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   19 ++++++++++++++++++
 lib/metadata/mirror.c            |    8 ++++--
 lib/metadata/pool_manip.c        |    2 +-
 lib/metadata/raid_manip.c        |   14 +++++++-----
 liblvm/lvm_vg.c                  |    6 +++-
 7 files changed, 67 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 85f61a1..136d232 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4028,10 +4028,12 @@ out:
 static int _rename_single_lv(struct logical_volume *lv, char *new_name)
 {
 	struct volume_group *vg = lv->vg;
+	int historical;
 
-	if (find_lv_in_vg(vg, new_name)) {
-		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", new_name, vg->name);
+	if (lv_name_is_used_in_vg(vg, new_name, &historical)) {
+		log_error("%sLogical Volume \"%s\" already exists in "
+			  "volume group \"%s\"", historical ? "historical " : "",
+			   new_name, vg->name);
 		return 0;
 	}
 
@@ -4194,6 +4196,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names = { .old = lv->name };
+	int historical;
 
 	/*
 	 * rename is not allowed on sub LVs except for pools
@@ -4205,9 +4208,10 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (find_lv_in_vg(vg, new_name)) {
-		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", new_name, vg->name);
+	if (lv_name_is_used_in_vg(vg, new_name, &historical)) {
+		log_error("%sLogical Volume \"%s\" already exists in "
+			  "volume group \"%s\"", historical ? "historical " : "",
+			  new_name, vg->name);
 		return 0;
 	}
 
@@ -5365,6 +5369,7 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len)
 {
 	struct lv_list *lvl;
+	struct glv_list *glvl;
 	int high = -1, i;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -5375,6 +5380,14 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 			high = i;
 	}
 
+	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+		if (sscanf(glvl->glv->historical->name, format, &i) != 1)
+			continue;
+
+		if (i > high)
+			high = i;
+	}
+
 	if (dm_snprintf(buffer, len, format, high + 1) < 0)
 		return NULL;
 
@@ -5506,6 +5519,7 @@ struct logical_volume *lv_create_empty(const char *name,
 	struct format_instance *fi = vg->fid;
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
+	int historical;
 
 	if (vg_max_lv_reached(vg))
 		stack;
@@ -5515,9 +5529,10 @@ struct logical_volume *lv_create_empty(const char *name,
 		log_error("Failed to generate unique name for the new "
 			  "logical volume");
 		return NULL;
-	} else if (find_lv_in_vg(vg, name)) {
+	} else if (lv_name_is_used_in_vg(vg, name, &historical)) {
 		log_error("Unable to create LV %s in Volume Group %s: "
-			  "name already in use.", name, vg->name);
+			  "name already in use%s.", name, vg->name,
+			  historical ? " by historical LV" : "");
 		return NULL;
 	}
 
@@ -7010,10 +7025,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct logical_volume *tmp_lv;
 	struct lv_segment *seg, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
+	int historical;
 
-	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
-		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", new_lv_name, vg->name);
+	if (new_lv_name && lv_name_is_used_in_vg(vg, new_lv_name, &historical)) {
+		log_error("%sLogical Volume \"%s\" already exists in "
+			  "volume group \"%s\"", historical ? "historical " : "",
+			  new_lv_name, vg->name);
 		return NULL;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index dc95995..ecca418 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1035,6 +1035,8 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 						    int check_removed_list,
 						    struct glv_list **glvl_found);
 
+int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical);
+
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name,
 					int allow_orphan, int allow_unformatted);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a5cb15a..5ab6f8e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2149,6 +2149,25 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 	return NULL;
 }
 
+int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical)
+{
+	struct generic_logical_volume *historical_lv;
+	struct logical_volume *lv;
+	int found = 0;
+
+	if ((lv = find_lv(vg, name))) {
+		found = 1;
+		if (historical)
+			*historical = 0;
+	} else if ((historical_lv = find_historical_glv(vg, name, 0, NULL))) {
+		found = 1;
+		if (historical)
+			*historical = 1;
+	}
+
+	return found;
+}
+
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 {
 	struct pv_list *pvl;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 2a72209..da7be6c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2213,10 +2213,12 @@ int lv_split_mirror_images(struct logical_volume *lv, const char *split_name,
 			   uint32_t split_count, struct dm_list *removable_pvs)
 {
 	int r;
+	int historical;
 
-	if (find_lv_in_vg(lv->vg, split_name)) {
-		log_error("Logical Volume \"%s\" already exists in "
-			  "volume group \"%s\"", split_name, lv->vg->name);
+	if (lv_name_is_used_in_vg(lv->vg, split_name, &historical)) {
+		log_error("%sLogical Volume \"%s\" already exists in "
+			  "volume group \"%s\"", historical ? "historical " : "",
+			  split_name, lv->vg->name);
 		return 0;
 	}
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index d2856ae..87ca992 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -867,7 +867,7 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 	*c = 0;
 
 	/* If the name is in use, generate new lvol%d */
-	if (find_lv_in_vg(vg, new_name) &&
+	if (lv_name_is_used_in_vg(vg, new_name, NULL) &&
 	    !generate_lv_name(vg, "lvol%d", new_name, sizeof(new_name))) {
 		log_error("Failed to generate unique name for "
 			  "pool metadata spare logical volume.");
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e66b533..3b9f81c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -339,6 +339,7 @@ static char *_generate_raid_name(struct logical_volume *lv,
 	const char *format = (count >= 0) ? "%s_%s_%u" : "%s_%s";
 	size_t len = strlen(lv->name) + strlen(suffix) + ((count >= 0) ? 5 : 2);
 	char *name;
+	int historical;
 
 	if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
 		log_error("Failed to allocate new name.");
@@ -353,9 +354,9 @@ static char *_generate_raid_name(struct logical_volume *lv,
 		return NULL;
 	}
 
-	if (find_lv_in_vg(lv->vg, name)) {
-		log_error("Logical volume %s already exists in volume group %s.",
-			  name, lv->vg->name);
+	if (lv_name_is_used_in_vg(lv->vg, name, &historical)) {
+		log_error("%sLogical Volume %s already exists in volume group %s.",
+			  historical ? "historical " : "", name, lv->vg->name);
 		return NULL;
 	}
 
@@ -1093,6 +1094,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	uint32_t old_count = lv_raid_image_count(lv);
 	struct logical_volume *tracking;
 	struct dm_list tracking_pvs;
+	int historical;
 
 	dm_list_init(&removal_list);
 	dm_list_init(&data_list);
@@ -1116,9 +1118,9 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
-	if (find_lv_in_vg(lv->vg, split_name)) {
-		log_error("Logical Volume \"%s\" already exists in %s",
-			  split_name, lv->vg->name);
+	if (lv_name_is_used_in_vg(lv->vg, split_name, &historical)) {
+		log_error("%sLogical Volume \"%s\" already exists in %s",
+			  historical ? "historical " : "", split_name, lv->vg->name);
 		return 0;
 	}
 
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 7e48df0..8b3fc91 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -523,6 +523,7 @@ int lvm_lv_name_validate(const vg_t vg, const char *name)
 {
 	int rc = -1;
 	name_error_t name_error;
+	int historical;
 
 	struct saved_env e = store_user_env(vg->cmd);
 
@@ -530,10 +531,11 @@ int lvm_lv_name_validate(const vg_t vg, const char *name)
 
 	if (NAME_VALID == name_error) {
 		if (apply_lvname_restrictions(name)) {
-			if (!find_lv_in_vg(vg, name)) {
+			if (!lv_name_is_used_in_vg(vg, name, &historical)) {
 				rc = 0;
 			} else {
-				log_errno(EINVAL, "LV name exists in VG");
+				log_errno(EINVAL, "%sLV name exists in VG",
+					  historical ? "historical " : "");
 			}
 		}
 	} else {


