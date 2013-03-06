From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  6 Mar 2013 16:22:13 +0000 (UTC)
Subject: master - RAID: Code changes missing from previous commit (bbc6378)
Message-ID: <20130306162213.8D9CF761@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31c24dd9f2ad7b5f7913a18c9f11a00d7b3474a1
Commit:        31c24dd9f2ad7b5f7913a18c9f11a00d7b3474a1
Parent:        ed6f3945fd86385c172da5d6884c01d8c0b6a51b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 6 10:17:11 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 6 10:17:11 2013 -0600

RAID:  Code changes missing from previous commit (bbc6378)

Previous commit included changes to WHATSNEW, but the code changes
were missing.  Here is the description from the previous commit:
commit bbc6378b73246d7ef00c16274fea38118531ae95
Author: Jonathan Brassow <jbrassow@redhat.com>
Date:   Thu Feb 21 11:31:36 2013 -0600

    RAID:  Make 'lvchange --refresh' restore transiently failed RAID PVs

    A new function (dm_tree_node_force_identical_table_reload) was added to
    avoid the suppression of identical table reloads.  This allows RAID LVs
    to reload the on-disk superblock information that contains which devices
    have failed and the bitmaps.  If the failed device has returned, this has
    the effect of restoring the device and initiating recovery.  Without this
    patch, the user had to completely deactivate their RAID LV and re-activate
    it in order to restore the failed device.  Now they simply need to
    suspend and resume (which is done by 'lvchange --refresh').

    The identical table suppression is only avoided if the LV is not PARTAIL
    (i.e. all of it's devices can be seen and read by LVM) and the kernel
    status of the array contains failed devices.  In other words, the function
    will only be called in the case where we may have success in restoring
    a failed device in the array.
---
 lib/raid/raid.c       |   15 +++++++++++++++
 libdm/libdevmapper.h  |    3 ++-
 libdm/libdm-deptree.c |   20 +++++++++++++++++++-
 3 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 1e28c73..69b6ee3 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -161,6 +161,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	uint32_t s;
 	uint64_t flags = 0;
 	uint64_t rebuilds = 0;
+	char *raid_health = NULL;
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
@@ -190,6 +191,20 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;
 
+	/*
+	 * If the RAID LV is not 'PARTIAL' and the status indicates
+	 * that the array has failed devices, it means that the
+	 * failed devices have returned and can be reintegrated.
+	 *
+	 * We reload the (potentially identical) table to force the
+	 * kernel to re-read the RAID superblocks - possibly restoring
+	 * transiently failed devices.
+	 */
+	if (!(seg->lv->status & PARTIAL_LV) &&
+	    lv_raid_dev_health(seg->lv, &raid_health) &&
+	    strchr(raid_health, 'D'))
+		dm_tree_node_force_identical_table_reload(node);
+
 	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
 					  seg->region_size, seg->stripe_size,
 					  rebuilds, flags))
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0460afa..184615f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -491,13 +491,14 @@ struct dm_tree_node *dm_tree_next_child(void **handle,
 					uint32_t inverted);
 
 /*
- * Get properties of a node.
+ * Get and set properties of a node.
  */
 const char *dm_tree_node_get_name(const struct dm_tree_node *node);
 const char *dm_tree_node_get_uuid(const struct dm_tree_node *node);
 const struct dm_info *dm_tree_node_get_info(const struct dm_tree_node *node);
 void *dm_tree_node_get_context(const struct dm_tree_node *node);
 int dm_tree_node_size_changed(const struct dm_tree_node *dnode);
+int dm_tree_node_force_identical_table_reload(struct dm_tree_node *dnode);
 
 /*
  * Returns the number of children of the given node (excluding the root node).
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5e938d7..e702a25 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -232,6 +232,16 @@ struct load_properties {
 
 	/* Send messages for this node in preload */
 	unsigned send_messages;
+
+	/*
+	 * If a mapping table is replacing an existing identical table,
+	 * the load is suppressed by default - avoiding the construction
+	 * of an unnecessary in-kernel table.  Sometimes we want to avoid
+	 * this optimization and load the identical table anyway.  This
+	 * field is used to indicate that we desire identical tables to be
+	 * loaded and not suppressed.
+	 */
+	unsigned force_identical_table_reload;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -587,6 +597,13 @@ int dm_tree_node_size_changed(const struct dm_tree_node *dnode)
 	return dnode->props.size_changed;
 }
 
+int dm_tree_node_force_identical_table_reload(struct dm_tree_node *dnode)
+{
+	dnode->props.force_identical_table_reload = 1;
+	return 1;
+}
+
+
 int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted)
 {
 	if (inverted) {
@@ -2409,7 +2426,8 @@ static int _load_node(struct dm_tree_node *dnode)
 				   seg, &seg_start))
 			goto_out;
 
-	if (!dm_task_suppress_identical_reload(dmt))
+	if (!dnode->props.force_identical_table_reload &&
+	    !dm_task_suppress_identical_reload(dmt))
 		log_error("Failed to suppress reload of identical tables.");
 
 	if ((r = dm_task_run(dmt))) {


