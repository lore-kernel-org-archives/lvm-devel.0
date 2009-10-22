From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Oct 2009 13:00:09 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20091022130009.5546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-22 13:00:08

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Use udev flags support in LVM and provide dm_tree_add_new_dev_with_udev_flags wrapper for dm_tree_add_new_dev.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1298&r2=1.1299
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2009/10/22 11:25:46	1.1298
+++ LVM2/WHATS_NEW	2009/10/22 13:00:07	1.1299
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Use udev flags support in LVM.
   Delay announcing mirror monitoring to syslog until initialisation succeeded.
   Handle metadata with unknown segment types more gracefully.
   Set default owner and group to null.
--- LVM2/lib/activate/dev_manager.c	2009/10/01 00:35:29	1.159
+++ LVM2/lib/activate/dev_manager.c	2009/10/22 13:00:07	1.160
@@ -1003,6 +1003,7 @@
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
+	uint16_t udev_flags = 0;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -1022,18 +1023,26 @@
 
 	lvlayer->lv = lv;
 
+	if (layer || !lv_is_visible(lv))
+		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
+			      DM_UDEV_DISABLE_DISK_RULES_FLAG;
+
+	if (lv_is_cow(lv))
+		udev_flags |= DM_UDEV_LOW_PRIORITY_FLAG;
+
 	/*
 	 * Add LV to dtree.
 	 * If we're working with precommitted metadata, clear any
 	 * existing inactive table left behind.
 	 * Major/minor settings only apply to the visible layer.
 	 */
-	if (!(dnode = dm_tree_add_new_dev(dtree, name, dlid,
+	if (!(dnode = dm_tree_add_new_dev_with_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
 					     _read_only_lv(lv),
 					     (lv->vg->status & PRECOMMITTED) ? 1 : 0,
-					     lvlayer)))
+					     lvlayer,
+					     udev_flags)))
 		return_0;
 
 	/* Store existing name so we can do rename later */
--- LVM2/libdm/.exported_symbols	2009/08/06 17:08:01	1.43
+++ LVM2/libdm/.exported_symbols	2009/10/22 13:00:07	1.44
@@ -50,6 +50,7 @@
 dm_tree_free
 dm_tree_add_dev
 dm_tree_add_new_dev
+dm_tree_add_new_dev_with_udev_flags
 dm_tree_node_get_name
 dm_tree_node_get_uuid
 dm_tree_node_get_info
--- LVM2/libdm/libdevmapper.h	2009/10/22 12:55:47	1.98
+++ LVM2/libdm/libdevmapper.h	2009/10/22 13:00:07	1.99
@@ -277,6 +277,15 @@
 					 int read_only,
 					 int clear_inactive,
 					 void *context);
+struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *tree,
+							 const char *name,
+							 const char *uuid,
+							 uint32_t major,
+							 uint32_t minor,
+							 int read_only,
+							 int clear_inactive,
+							 void *context,
+							 uint16_t udev_flags);
 
 /*
  * Search for a node in the tree.
--- LVM2/libdm/libdm-deptree.c	2009/10/22 12:55:48	1.59
+++ LVM2/libdm/libdm-deptree.c	2009/10/22 13:00:07	1.60
@@ -130,6 +130,8 @@
 
 	int activation_priority;	/* 0 gets activated first */
 
+	uint16_t udev_flags;		/* Udev control flags */
+
 	void *context;			/* External supplied context */
 
 	struct load_properties props;	/* For creation/table (re)load */
@@ -301,7 +303,8 @@
 						 const char *name,
 						 const char *uuid,
 						 struct dm_info *info,
-						 void *context)
+						 void *context,
+						 uint16_t udev_flags)
 {
 	struct dm_tree_node *node;
 	uint64_t dev;
@@ -317,6 +320,7 @@
 	node->uuid = uuid;
 	node->info = *info;
 	node->context = context;
+	node->udev_flags = udev_flags;
 	node->activation_priority = 0;
 
 	dm_list_init(&node->uses);
@@ -466,8 +470,8 @@
 		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, &info, &deps))
 			return_NULL;
 
-		if (!(node = _create_dm_tree_node(dtree, name, uuid,
-						  &info, NULL)))
+		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
+						  NULL, 0)))
 			goto_out;
 		new = 1;
 	}
@@ -585,8 +589,8 @@
 		info.inactive_table = 0;
 		info.read_only = 0;
 
-		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2,
-						   &info, context)))
+		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
+						   context, 0)))
 			return_NULL;
 
 		/* Attach to root node until a table is supplied */
@@ -613,10 +617,31 @@
 		return_NULL;
 
 	dnode->context = context;
+	dnode->udev_flags = 0;
 
 	return dnode;
 }
 
+struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
+							 const char *name,
+							 const char *uuid,
+							 uint32_t major,
+							 uint32_t minor,
+							 int read_only,
+							 int clear_inactive,
+							 void *context,
+							 uint16_t udev_flags)
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
@@ -821,7 +846,8 @@
 	return r;
 }
 
-static int _deactivate_node(const char *name, uint32_t major, uint32_t minor, uint32_t *cookie)
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
+			    uint32_t *cookie, uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -841,7 +867,7 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie, 0))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -858,7 +884,7 @@
 }
 
 static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
-			uint32_t minor, uint32_t *cookie)
+			uint32_t minor, uint32_t *cookie, uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -881,7 +907,7 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie, 0))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -895,7 +921,8 @@
 /* FIXME Merge with _suspend_node? */
 static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 			uint32_t read_ahead, uint32_t read_ahead_flags,
-			struct dm_info *newinfo, uint32_t *cookie)
+			struct dm_info *newinfo, uint32_t *cookie,
+			uint16_t udev_flags)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -924,7 +951,7 @@
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
 		log_error("Failed to set read ahead");
 
-	if (!dm_task_set_cookie(dmt, cookie, 0))
+	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
 	if ((r = dm_task_run(dmt)))
@@ -1011,7 +1038,8 @@
 		    !info.exists || info.open_count)
 			continue;
 
-		if (!_deactivate_node(name, info.major, info.minor, &dnode->dtree->cookie)) {
+		if (!_deactivate_node(name, info.major, info.minor,
+				      &dnode->dtree->cookie, dnode->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
@@ -1156,7 +1184,8 @@
 			/* Rename? */
 			if (child->props.new_name) {
 				if (!_rename_node(name, child->props.new_name, child->info.major,
-						  child->info.minor, &child->dtree->cookie)) {
+						  child->info.minor, &child->dtree->cookie,
+						  child->udev_flags)) {
 					log_error("Failed to rename %s (%" PRIu32
 						  ":%" PRIu32 ") to %s", name, child->info.major,
 						  child->info.minor, child->props.new_name);
@@ -1171,7 +1200,7 @@
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead, child->props.read_ahead_flags,
-					  &newinfo, &child->dtree->cookie)) {
+					  &newinfo, &child->dtree->cookie, child->udev_flags)) {
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
@@ -1622,7 +1651,7 @@
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
 				  child->props.read_ahead, child->props.read_ahead_flags,
-				  &newinfo, &child->dtree->cookie)) {
+				  &newinfo, &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);


