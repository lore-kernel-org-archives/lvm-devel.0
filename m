From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 19 Oct 2009 13:46:42 +0200
Subject: [PATCH 2/4] Use udev flags in LVM
Message-ID: <4ADC51A2.6010901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We don't want to create the symlinks in /dev/<vgname> and /dev/disk for invisible or
non-top-level devices. However, we still need some of them to be initialised, so we
need them to be visible for a while (for example the "_mlog"). But we can't distinguish
this situation without any further information in udev rules (so we don't know when
the symlinks should be and when it should not be created). Therefore, we use the udev
flags encoded in the cookie value to pass this information into the udev rules.

Also, we need to increase the symlink priority for origin devices so they won't be
overwritten by snapshots when the symlink has the same name (e.g. a symlink name
based on FS UUID in /dev/disk/by-uuid directory).

I've added and exported a function called "dm_tree_add_new_dev_udev_flags" which 
is a wrapper around "dm_tree_add_new_dev". The flags are stored in tree node
structure (for each device separately) so when the tree is traversed we can
pass this information into dm_task_set_cookie then.

Peter


diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 13cec36..96928f6 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1003,6 +1003,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
+	uint16_t udev_flags = DM_UDEV_FLAG_NULL;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -1022,18 +1023,26 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	lvlayer->lv = lv;
 
+	if (layer || !lv_is_visible(lv))
+		udev_flags |= DM_UDEV_FLAG_DISABLE_SUBSYSTEM_RULES |
+			      DM_UDEV_FLAG_DISABLE_DISK_RULES;
+
+	if (lv->origin_count)
+		udev_flags |= DM_UDEV_FLAG_HIGH_SYMLINK_PRIORITY;
+
 	/*
 	 * Add LV to dtree.
 	 * If we're working with precommitted metadata, clear any
 	 * existing inactive table left behind.
 	 * Major/minor settings only apply to the visible layer.
 	 */
-	if (!(dnode = dm_tree_add_new_dev(dtree, name, dlid,
+	if (!(dnode = dm_tree_add_new_dev_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
 					     _read_only_lv(lv),
 					     (lv->vg->status & PRECOMMITTED) ? 1 : 0,
-					     lvlayer)))
+					     lvlayer,
+					     udev_flags)))
 		return_0;
 
 	/* Store existing name so we can do rename later */
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index c357131..733804c 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -50,6 +50,7 @@ dm_tree_create
 dm_tree_free
 dm_tree_add_dev
 dm_tree_add_new_dev
+dm_tree_add_new_dev_udev_flags
 dm_tree_node_get_name
 dm_tree_node_get_uuid
 dm_tree_node_get_info
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a40a843..6640268 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -277,6 +277,14 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *tree,
 					 int read_only,
 					 int clear_inactive,
 					 void *context);
+struct dm_tree_node *dm_tree_add_new_dev_udev_flags(struct dm_tree *tree,
+						    const char *name,
+						    const char *uuid,
+						    uint32_t major, uint32_t minor,
+						    int read_only,
+						    int clear_inactive,
+						    void *context,
+						    uint16_t udev_flags);
 
 /*
  * Search for a node in the tree.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 4b8ffc9..8511c03 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -130,6 +130,8 @@ struct dm_tree_node {
 
 	int activation_priority;	/* 0 gets activated first */
 
+	uint16_t udev_flags;		/* Udev control flags */
+
 	void *context;			/* External supplied context */
 
 	struct load_properties props;	/* For creation/table (re)load */
@@ -301,7 +303,8 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 						 const char *name,
 						 const char *uuid,
 						 struct dm_info *info,
-						 void *context)
+						 void *context,
+						 uint16_t udev_flags)
 {
 	struct dm_tree_node *node;
 	uint64_t dev;
@@ -317,6 +320,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	node->uuid = uuid;
 	node->info = *info;
 	node->context = context;
+	node->udev_flags = udev_flags;
 	node->activation_priority = 0;
 
 	dm_list_init(&node->uses);
@@ -466,8 +470,8 @@ static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
 		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, &info, &deps))
 			return_NULL;
 
-		if (!(node = _create_dm_tree_node(dtree, name, uuid,
-						  &info, NULL)))
+		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
+						  NULL, DM_UDEV_FLAG_NULL)))
 			goto_out;
 		new = 1;
 	}
@@ -585,8 +589,8 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
 		info.inactive_table = 0;
 		info.read_only = 0;
 
-		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2,
-						   &info, context)))
+		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
+						   context, DM_UDEV_FLAG_NULL)))
 			return_NULL;
 
 		/* Attach to root node until a table is supplied */
@@ -613,10 +617,30 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
 		return_NULL;
 
 	dnode->context = context;
+	dnode->udev_flags = DM_UDEV_FLAG_NULL;
 
 	return dnode;
 }
 
+struct dm_tree_node *dm_tree_add_new_dev_udev_flags(struct dm_tree *dtree,
+						    const char *name,
+						    const char *uuid,
+						    uint32_t major, uint32_t minor,
+						    int read_only,
+						    int clear_inactive,
+						    void *context,
+						    uint16_t udev_flags)
+{
+	struct dm_tree_node *node;
+
+	if ((node = dm_tree_add_new_dev(dtree, name, uuid, major, minor, read_only,
+				       clear_inactive, context)))
+		node->udev_flags = udev_flags;
+
+	return node;
+}
+
+
 void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 				 uint32_t read_ahead,
 				 uint32_t read_ahead_flags)
@@ -821,7 +845,8 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	return r;
 }
 
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, uint32_t *cookie)
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
+			    uint32_t *cookie, uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -841,7 +866,7 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, ui
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -858,7 +883,7 @@ out:
 }
 
 static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
-			uint32_t minor, uint32_t *cookie)
+			uint32_t minor, uint32_t *cookie, uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -881,7 +906,7 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -895,7 +920,8 @@ out:
 /* FIXME Merge with _suspend_node? */
 static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 			uint32_t read_ahead, uint32_t read_ahead_flags,
-			struct dm_info *newinfo, uint32_t *cookie)
+			struct dm_info *newinfo, uint32_t *cookie,
+			uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -924,7 +950,7 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
-	if (!dm_task_set_cookie(dmt, cookie, DM_UDEV_FLAG_NULL))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	if ((r = dm_task_run(dmt)))
@@ -1011,7 +1037,8 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 		    !info.exists || info.open_count)
 			continue;
 
-		if (!_deactivate_node(name, info.major, info.minor, &dnode->dtree->cookie)) {
+		if (!_deactivate_node(name, info.major, info.minor,
+				      &dnode->dtree->cookie, dnode->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -1156,7 +1183,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			/* Rename? */
 			if (child->props.new_name) {
 				if (!_rename_node(name, child->props.new_name, child->info.major,
-						  child->info.minor, &child->dtree->cookie)) {
+						  child->info.minor, &child->dtree->cookie,
+						  child->udev_flags)) {
 					log_error("Failed to rename %s (%" PRIu32
 						  ":%" PRIu32 ") to %s", name, child->info.major,
 						  child->info.minor, child->props.new_name);
@@ -1171,7 +1199,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead, child->props.read_ahead_flags,
-					  &newinfo, &child->dtree->cookie)) {
+					  &newinfo, &child->dtree->cookie, child->udev_flags)) {
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
@@ -1622,7 +1650,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
 				  child->props.read_ahead, child->props.read_ahead_flags,
-				  &newinfo, &child->dtree->cookie)) {
+				  &newinfo, &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);


