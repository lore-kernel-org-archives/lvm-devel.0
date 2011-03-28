From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:13 +0200
Subject: [PATCH 2/6] Remove double brackets
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <d05e374206ce6c4ba00dcae04d296eb24ea53e17.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These are not needed - and clang is able to give some note about those.
So clean them.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-io.c     |    2 +-
 lib/metadata/lv_manip.c |    6 +++---
 lib/metadata/pv_manip.c |    2 +-
 libdm/libdm-deptree.c   |    4 ++--
 tools/pvmove.c          |    4 ++--
 tools/vgreduce.c        |    4 ++--
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 887d732..3de6cd1 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -126,7 +126,7 @@ static int _get_block_size(struct device *dev, unsigned int *size)
 {
 	const char *name = dev_name(dev);
 
-	if ((dev->block_size == -1)) {
+	if (dev->block_size == -1) {
 		if (ioctl(dev_fd(dev), BLKBSZGET, &dev->block_size) < 0) {
 			log_sys_error("ioctl BLKBSZGET", name);
 			return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 015c481..a07421c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -736,11 +736,11 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 
 	/* Are there any preceding segments we must follow on from? */
 	if (alloc_parms->prev_lvseg) {
-		if ((alloc_parms->alloc == ALLOC_CONTIGUOUS))
+		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS;
-		else if ((alloc_parms->alloc == ALLOC_CLING))
+		else if (alloc_parms->alloc == ALLOC_CLING)
 			alloc_parms->flags |= A_CLING;
-		else if ((alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) {
+		else if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS) {
 			alloc_parms->flags |= A_CLING;
 			alloc_parms->flags |= A_CLING_BY_TAGS;
 		}
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index cb37745..fdba91d 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -468,7 +468,7 @@ int pv_resize(struct physical_volume *pv,
 			return 0;
 		}
 
-		if ((new_pe_count == old_pe_count)) {
+		if (new_pe_count == old_pe_count) {
 			pv->pe_count = old_pe_count;
 			log_verbose("No change to size of physical volume %s.",
 				    pv_dev_name(pv));
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 2449240..345257b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -329,13 +329,13 @@ static void _remove_from_bottomlevel(struct dm_tree_node *node)
 static int _link_tree_nodes(struct dm_tree_node *parent, struct dm_tree_node *child)
 {
 	/* Don't link to root node if child already has a parent */
-	if ((parent == &parent->dtree->root)) {
+	if (parent == &parent->dtree->root) {
 		if (dm_tree_node_num_children(child, 1))
 			return 1;
 	} else
 		_remove_from_toplevel(child);
 
-	if ((child == &child->dtree->root)) {
+	if (child == &child->dtree->root) {
 		if (dm_tree_node_num_children(parent, 0))
 			return 1;
 	} else
diff --git a/tools/pvmove.c b/tools/pvmove.c
index c661e62..965a9eb 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -121,7 +121,7 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 		}
 
 		/* Remove PV if full */
-		if ((pvl->pv->pe_count == pvl->pv->pe_alloc_count))
+		if (pvl->pv->pe_count == pvl->pv->pe_alloc_count)
 			dm_list_del(&pvl->list);
 	}
 
@@ -202,7 +202,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	/* Find segments to be moved and set up mirrors */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
-		if ((lv == lv_mirr))
+		if (lv == lv_mirr)
 			continue;
 		if (lv_name) {
 			if (strcmp(lv->name, lv_name))
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 1cabc8d..5697947 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -287,8 +287,8 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 			if (mirrored_seg->log_lv) {
 				dm_list_iterate_items(seg, &mirrored_seg->log_lv->segments) {
 					/* FIXME: The second test shouldn't be required */
-					if ((seg->segtype ==
-					     get_segtype_from_string(vg->cmd, "error"))) {
+					if (seg->segtype ==
+					    get_segtype_from_string(vg->cmd, "error")) {
 						log_print("The log device for %s/%s has failed.",
 							  vg->name, mirrored_seg->lv->name);
 						remove_log = 1;
-- 
1.7.4.1


