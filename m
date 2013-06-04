From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:39 +0000 (UTC)
Subject: dev-mornfall-activate - RAID: Revert previous commit that allowed identical table loads.
Message-ID: <20130604192339.E5AC661188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=faeea370571b6525d9d95d2904aaacbdb9552e00
Commit:        faeea370571b6525d9d95d2904aaacbdb9552e00
Parent:        ff64e3500f6acf93dce017388445c4828111d06f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Apr 11 15:57:14 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Apr 11 15:57:14 2013 -0500

RAID:  Revert previous commit that allowed identical table loads.

Revert commit 31c24dd9f2ad7b5f7913a18c9f11a00d7b3474a1.  This commit
was used to force a RAID device-mapper table to be loaded into the
kernel despite the fact that it was identical to the one already
loaded.  The effect allowed a RAID array with a transiently failed
device to refresh and reintegrate the failed device.  This operation
is better done in the kernel on a 'resume'.  Since,
'lvchange --refresh' already performs a suspend/resume cycle, the
above commit is not needed once the kernel change is made.  Reverting
the commit removes an unnecessary (at least for now) change to the
device-mapper interface.
---
 lib/raid/raid.c       |   15 ---------------
 libdm/libdevmapper.h  |    3 +--
 libdm/libdm-deptree.c |   20 +-------------------
 3 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 69b6ee3..1e28c73 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -161,7 +161,6 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	uint32_t s;
 	uint64_t flags = 0;
 	uint64_t rebuilds = 0;
-	char *raid_health = NULL;
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
@@ -191,20 +190,6 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;
 
-	/*
-	 * If the RAID LV is not 'PARTIAL' and the status indicates
-	 * that the array has failed devices, it means that the
-	 * failed devices have returned and can be reintegrated.
-	 *
-	 * We reload the (potentially identical) table to force the
-	 * kernel to re-read the RAID superblocks - possibly restoring
-	 * transiently failed devices.
-	 */
-	if (!(seg->lv->status & PARTIAL_LV) &&
-	    lv_raid_dev_health(seg->lv, &raid_health) &&
-	    strchr(raid_health, 'D'))
-		dm_tree_node_force_identical_table_reload(node);
-
 	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
 					  seg->region_size, seg->stripe_size,
 					  rebuilds, flags))
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2f2c77d..172976f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -501,14 +501,13 @@ struct dm_tree_node *dm_tree_next_child(void **handle,
 					uint32_t inverted);
 
 /*
- * Get and set properties of a node.
+ * Get properties of a node.
  */
 const char *dm_tree_node_get_name(const struct dm_tree_node *node);
 const char *dm_tree_node_get_uuid(const struct dm_tree_node *node);
 const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node);
 void *dm_tree_node_get_context(const struct dm_tree_node *node);
 int dm_tree_node_size_changed(const struct dm_tree_node *dnode);
-int dm_tree_node_force_identical_table_reload(struct dm_tree_node *dnode);
 
 /*
  * Returns the number of children of the given node (excluding the root node).
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 750f494..9f82174 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -232,16 +232,6 @@ struct load_properties {
 
 	/* Send messages for this node in preload */
 	unsigned send_messages;
-
-	/*
-	 * If a mapping table is replacing an existing identical table,
-	 * the load is suppressed by default - avoiding the construction
-	 * of an unnecessary in-kernel table.  Sometimes we want to avoid
-	 * this optimization and load the identical table anyway.  This
-	 * field is used to indicate that we desire identical tables to be
-	 * loaded and not suppressed.
-	 */
-	unsigned force_identical_table_reload;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -597,13 +587,6 @@ int dm_tree_node_size_changed(const struct dm_tree_node *dnode)
 	return dnode->props.size_changed;
 }
 
-int dm_tree_node_force_identical_table_reload(struct dm_tree_node *dnode)
-{
-	dnode->props.force_identical_table_reload = 1;
-	return 1;
-}
-
-
 int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted)
 {
 	if (inverted) {
@@ -2426,8 +2409,7 @@ static int _load_node(struct dm_tree_node *dnode)
 				   seg, &seg_start))
 			goto_out;
 
-	if (!dnode->props.force_identical_table_reload &&
-	    !dm_task_suppress_identical_reload(dmt))
+	if (!dm_task_suppress_identical_reload(dmt))
 		log_error("Failed to suppress reload of identical tables.");
 
 	if ((r = dm_task_run(dmt))) {


