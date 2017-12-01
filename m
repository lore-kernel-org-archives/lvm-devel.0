From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:38 -0500
Subject: master - cleanup: simplify _deps code
Message-ID: <201712011120.vB1BKch7029486@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e177cc7c90139441530fc065125fa510671e610
Commit:        0e177cc7c90139441530fc065125fa510671e610
Parent:        4dc81848034f4f5edb02335af03e50f45c3977f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 30 12:53:34 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

cleanup: simplify _deps code

Make _deps to always return name & uuid,
and postpone duplication of name and uuid into _create_dm_tree_node().
Saves some duplicated code.
---
 libdm/libdm-deptree.c |   42 +++++++++++-------------------------------
 1 files changed, 11 insertions(+), 31 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d460ce1..8c623bf 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -523,15 +523,14 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	struct dm_tree_node *node;
 	dev_t dev;
 
-	if (!(node = dm_pool_zalloc(dtree->mem, sizeof(*node)))) {
-		log_error("_create_dm_tree_node alloc failed");
+	if (!(node = dm_pool_zalloc(dtree->mem, sizeof(*node))) ||
+	    !(node->name = dm_pool_strdup(dtree->mem, name)) ||
+	    !(node->uuid = dm_pool_strdup(dtree->mem, uuid))) {
+		log_error("_create_dm_tree_node alloc failed.");
 		return NULL;
 	}
 
 	node->dtree = dtree;
-
-	node->name = name;
-	node->uuid = uuid;
 	node->info = *info;
 	node->context = context;
 	node->udev_flags = udev_flags;
@@ -882,10 +881,8 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 	}
 
 	if (!info->exists) {
-		if (name)
-			*name = "";
-		if (uuid)
-			*uuid = "";
+		*name = "";
+		*uuid = "";
 		*deps = NULL;
 	} else {
 		if (info->major != major) {
@@ -898,14 +895,8 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 				  minor, info->minor);
 			goto failed;
 		}
-		if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(*dmt)))) {
-			log_error("name pool_strdup failed");
-			goto failed;
-		}
-		if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(*dmt)))) {
-			log_error("uuid pool_strdup failed");
-			goto failed;
-		}
+		*name = dm_task_get_name(*dmt);
+		*uuid = dm_task_get_uuid(*dmt);
 		*deps = dm_task_get_deps(*dmt);
 	}
 
@@ -1081,7 +1072,7 @@ static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 	struct dm_task *dmt = NULL, *deps_dmt = NULL;
 	struct dm_info *info, deps_info;
 	struct dm_deps *deps = NULL;
-	const char *name, *uuid;
+	const char *name, *uuid, *depname, *depuuid;
 	const char *default_uuid_prefix;
 	size_t default_uuid_prefix_len;
 	uint32_t i;
@@ -1102,7 +1093,7 @@ static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 		return 1;
 
 	/* Get devices used by inactive table that's about to be deleted. */
-	if (!_deps(&deps_dmt, dnode->dtree->mem, info->major, info->minor, NULL, NULL, 1, info, &deps)) {
+	if (!_deps(&deps_dmt, dnode->dtree->mem, info->major, info->minor, &depname, &depuuid, 1, info, &deps)) {
 		log_error("Failed to obtain dependencies for %s before clearing table.", name);
 		return 0;
 	}
@@ -1185,8 +1176,6 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 {
 	struct dm_tree_node *dnode;
 	struct dm_info info = { 0 };
-	const char *name2;
-	const char *uuid2;
 
 	if (!name || !uuid) {
 		log_error("Cannot add device without name and uuid.");
@@ -1195,16 +1184,7 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 
 	/* Do we need to add node to tree? */
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
-		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {
-			log_error("name pool_strdup failed");
-			return NULL;
-		}
-		if (!(uuid2 = dm_pool_strdup(dtree->mem, uuid))) {
-			log_error("uuid pool_strdup failed");
-			return NULL;
-		}
-
-		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
+		if (!(dnode = _create_dm_tree_node(dtree, name, uuid, &info,
 						   context, 0)))
 			return_NULL;
 


