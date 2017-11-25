From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 25 Nov 2017 18:38:27 -0500
Subject: master - pvmove: enhance delayed_resume logic
Message-ID: <201711252338.vAPNcRfu005298@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f70404addb0f46b7dd281c2e7e0f944aa7f27ae5
Commit:        f70404addb0f46b7dd281c2e7e0f944aa7f27ae5
Parent:        8c6fd0933fa4ee9b79ae5edbb90afe6a3d893b18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 26 00:28:33 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 26 00:36:48 2017 +0100

pvmove: enhance delayed_resume logic

ATM we want to support delayed resume purely in pvmove case.
So have libdm logic internal to recognize difference beween
pvmove and other targets that do use delayed resume.

This fixes problem introduced with commit aa68b898ff9c51dcb
for mirror-on-mirror or snapshot-on-mirror problem.

TODO: likely added new API call and let libdm user select
delayed nodes explicitely.
---
 lib/mirror/mirrored.c |    2 +-
 libdm/libdm-deptree.c |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 4891fb7..602c30a 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -303,7 +303,7 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 		}
 	} else {
 		/* If core log, use mirror's UUID and set DM_CORELOG flag */
-		if (!(log_dlid = build_dm_uuid(mem, seg->lv, NULL))) {
+		if (!(log_dlid = build_dm_uuid(mem, seg->lv, lv_is_pvmove(seg->lv) ? "pvmove" : NULL))) {
 			log_error("Failed to build uuid for mirror LV %s.",
 				  seg->lv->name);
 			return 0;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 547904f..d460ce1 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2963,8 +2963,8 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 		/* Propagate delay of resume from parent node */
-		if (dnode->props.delay_resume_if_new)
-			child->props.delay_resume_if_new = 1;
+		if (dnode->props.delay_resume_if_new > 1)
+			child->props.delay_resume_if_new = dnode->props.delay_resume_if_new;
 
 		/* Skip existing non-device-mapper devices */
 		if (!child->info.exists && child->info.major)
@@ -3342,7 +3342,8 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 		}
 		if ((flags & DM_CORELOG))
 			/* For pvmove: immediate resume (for size validation) isn't needed. */
-			node->props.delay_resume_if_new = 1;
+			/* pvmove flag passed via unused UUID and its suffix */
+			node->props.delay_resume_if_new = strstr(log_uuid, "pvmove") ? 2 : 1;
 		else {
 			if (!(log_node = dm_tree_find_node_by_uuid(node->dtree, log_uuid))) {
 				log_error("Couldn't find mirror log uuid %s.", log_uuid);


