From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:36 +0000 (UTC)
Subject: master - mirror: add prepare_mirror_log
Message-ID: <20161211223436.B653A60C2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31564834db7610b37f52040fbba89f4c71de4c34
Commit:        31564834db7610b37f52040fbba89f4c71de4c34
Parent:        b9f9ce52ecb0de3b33b1d0e2294a1b13c744e655
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 19:54:09 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:16:16 2016 +0100

mirror: add prepare_mirror_log

Function prepares new mirror log LV in-sync optionaly.
This is useful to have such device ready when converting
raid1 to mirror.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    4 +++
 lib/metadata/mirror.c            |   43 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 37a0dc7..274430f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add internal function for separate mirror log preparation.
   Fix segfault in lvmetad from missing NULL in daemon_reply_simple.
   Simplify internal _info_run() and use _setup_task_run() for mknod.
   Better API for internal function _setup_task_run.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cdd4984..4bf466b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1157,6 +1157,10 @@ struct logical_volume *detach_mirror_log(struct lv_segment *seg);
 int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct dm_list *removable_pvs, int force);
+struct logical_volume *prepare_mirror_log(struct logical_volume *lv,
+					  int in_sync, uint32_t region_size,
+					  struct dm_list *allocatable_pvs,
+					  alloc_policy_t alloc);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
 		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index e84916e..73b1110 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1912,6 +1912,49 @@ int attach_mirror_log(struct lv_segment *seg, struct logical_volume *log_lv)
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
+/* Prepare disk mirror log for raid1->mirror conversion */
+struct logical_volume *prepare_mirror_log(struct logical_volume *lv,
+					  int in_sync, uint32_t region_size,
+					  struct dm_list *allocatable_pvs,
+					  alloc_policy_t alloc)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	const struct segment_type *segtype;
+	struct dm_list *parallel_areas;
+	struct alloc_handle *ah;
+	struct logical_volume *log_lv;
+
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
+		return_NULL;
+
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
+		return_NULL;
+
+	/* Allocate destination extents */
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype,
+				    0, 0, 1, region_size,
+				    lv->le_count, allocatable_pvs,
+				    alloc, 0, parallel_areas))) {
+		log_error("Unable to allocate extents for mirror log.");
+		return NULL;
+	}
+
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name, "_mlog"))) {
+		log_error("Failed to create mirror log.");
+		goto out;
+	}
+
+	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
+		log_error("Failed to initialise mirror log.");
+		log_lv = NULL;
+		goto out;
+	}
+out:
+	alloc_destroy(ah);
+
+	return log_lv;
+}
+
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
 		   struct dm_list *allocatable_pvs, alloc_policy_t alloc)


