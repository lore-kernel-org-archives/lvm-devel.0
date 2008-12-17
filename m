From: Milan Broz <mbroz@redhat.com>
Date: Wed, 17 Dec 2008 18:03:45 +0100
Subject: [LVM2 PATCH] libdm: Fail to add tree node when requested major/minor is used.
Message-ID: <494930F1.1030607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fail to add tree node when requested major/minor is used.

(_info_by_dev() is just moved for definition before use here)

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=204992

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/libdm-deptree.c |   64 ++++++++++++++++++++++++++++----------------------
 1 file changed, 36 insertions(+), 28 deletions(-)

Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c	2008-12-17 16:28:33.000000000 +0100
+++ LVM2/libdm/libdm-deptree.c	2008-12-17 17:39:51.000000000 +0100
@@ -544,6 +544,35 @@ static int _node_clear_table(struct dm_t
 	return r;
 }
 
+static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
+			struct dm_info *info)
+{
+	struct dm_task *dmt;
+	int r;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+		log_error("_info_by_dev: dm_task creation failed");
+		return 0;
+	}
+
+	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
+		log_error("_info_by_dev: Failed to set device number");
+		dm_task_destroy(dmt);
+		return 0;
+	}
+
+	if (!with_open_count && !dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if ((r = dm_task_run(dmt)))
+		r = dm_task_get_info(dmt, info);
+
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+
 struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
 					    const char *name,
 					    const char *uuid,
@@ -559,6 +588,13 @@ struct dm_tree_node *dm_tree_add_new_dev
 
 	/* Do we need to add node to tree? */
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
+
+		if (major && minor && _info_by_dev(major, minor, 0, &info) && info.exists) {
+			log_error("Requested major:minor %i:%i number is already used.",
+				  major, minor);
+			return NULL;
+		}
+
 		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {
 			log_error("name pool_strdup failed");
 			return NULL;
@@ -778,34 +814,6 @@ struct dm_tree_node *dm_tree_next_child(
 /*
  * Deactivate a device with its dependencies if the uuid prefix matches.
  */
-static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
-			struct dm_info *info)
-{
-	struct dm_task *dmt;
-	int r;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_info_by_dev: dm_task creation failed");
-		return 0;
-	}
-
-	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("_info_by_dev: Failed to set device number");
-		dm_task_destroy(dmt);
-		return 0;
-	}
-
-	if (!with_open_count && !dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
-	if ((r = dm_task_run(dmt)))
-		r = dm_task_get_info(dmt, info);
-
-	dm_task_destroy(dmt);
-
-	return r;
-}
-
 static int _deactivate_node(const char *name, uint32_t major, uint32_t minor)
 {
 	struct dm_task *dmt;



