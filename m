From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:29 +0000 (UTC)
Subject: master - metadata: add infrastructure to track LV history
Message-ID: <20160303131929.124EB61B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e573eca554374ba6889a7f89fcb9850ae13c793e
Commit:        e573eca554374ba6889a7f89fcb9850ae13c793e
Parent:        5e718ec66679aad42773901a40e168ba4c3f3f50
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:18:42 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 11:26:51 2016 +0100

metadata: add infrastructure to track LV history

Add new structures and new fields in existing structures to support
tracking history of LVs (the LVs which don't exist - the have been
removed already):

  - new "struct historical_logical_volume"
    This structure keeps information specific to historical LVs
    (historical LV is very reduced form of struct logical_volume +
     it contains a few specific fields to track historical LV
     properties like removal time and connections among other LVs).

  - new "struct generic_logical_volume"
    Wrapper for "struct historical_logical_volume" and
    "struct logical_volume" to make it possible to handle volumes
    in uniform way, no matter if it's live or historical one.

  - new "struct glv_list"
    Wrapper for "struct generic_logical_volume" so it can be
    added to a list.

  - new "indirect_glvs" field in "struct logical_volume"
    List that stores references to all indirect users of this LV - this
    interconnects live LV with historical descendant LVs or even live
    descendant LVs.

  - new "indirect_origin" field in "struct lv_segment"
    Reference to indirect origin of this segment - this interconnects
    live LV (segment) with historical ancestor.

  - new "this_glv" field in "struct logical_volume"
    This references an existing generic_logical_volume wrapper for this
    LV, if used. It can be NULL if not needed - which means we're not
    handling historical LVs at all.

  - new "historical_lvs" field in "struct volume group
    List of all historical LVs read from VG metadata.
---
 lib/metadata/lv.h                |   48 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c          |    1 +
 lib/metadata/metadata-exported.h |    6 ++++
 lib/metadata/vg.c                |    1 +
 lib/metadata/vg.h                |    1 +
 lib/report/report.c              |    2 +
 tools/reporter.c                 |    2 +
 7 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 4b42eb7..f554bce 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -49,6 +49,15 @@ struct logical_volume {
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
+	struct dm_list indirect_glvs; /* For keeping track of historical LVs in ancestry chain */
+
+	/*
+	 * this_glv variable is used as a helper for handling historical LVs.
+	 * If this LVs has no role at all in keeping track of historical LVs,
+	 * the this_glv variable is NULL. See also comments for struct
+	 * generic_logical_volume and struct historical_logical_volume below.
+	 */
+	struct generic_logical_volume *this_glv;
 
 	uint64_t timestamp;
 	unsigned new_lock_args:1;
@@ -56,6 +65,45 @@ struct logical_volume {
 	const char *lock_args;
 };
 
+/*
+ * With the introduction of tracking historical LVs, we need to make
+ * a difference between live LV (struct logical_volume) and historical LV
+ * (struct historical_logical_volume). To minimize the impact of this change
+ * and to minimize the changes needed in the existing  code, we use a
+ * little trick here - when processing LVs (e.g. while reporting LV
+ * properties), each historical LV is represented as dummy LV which is
+ * an instance of struct logical_volume with all its properties set to
+ * blank (hence "dummy LV") and with this_glv pointing to the struct
+ * historical_logical_volume. This way all the existing code working with
+ * struct logical_volume will see this historical LV as dummy live LV while
+ * the code that needs to recognize between live and historical LV will
+ * check this_glv first and then it will work either with the live
+ * or historical LV properties appropriately.
+ */
+struct generic_logical_volume;
+
+/*
+ * historical logical volume is an LV that has been removed already.
+ * This is used to keep track of LV history.
+ */
+struct historical_logical_volume {
+	union lvid lvid;
+	const char *name;
+	struct volume_group *vg;
+	uint64_t timestamp;
+	uint64_t timestamp_removed;
+	struct generic_logical_volume *indirect_origin;
+	struct dm_list indirect_glvs; /* list of struct generic_logical_volume */
+};
+
+struct generic_logical_volume {
+	int is_historical;
+	union {
+		struct logical_volume *live;			/* is_historical=0 */
+		struct historical_logical_volume *historical;	/* is_historical=1 */
+	};
+};
+
 struct lv_with_info_and_seg_status;
 
 /* LV dependencies */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1b431c1..069042c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5320,6 +5320,7 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
 	dm_list_init(&lv->segs_using_this_lv);
+	dm_list_init(&lv->indirect_glvs);
 	dm_list_init(&lv->rsites);
 
 	return lv;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8376a54..97cba51 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -447,6 +447,7 @@ struct lv_segment {
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
 				/* For thin_pool, 128..2097152. */
 	struct logical_volume *origin;	/* snap and thin */
+	struct generic_logical_volume *indirect_origin;
 	struct logical_volume *merge_lv; /* thin, merge descendent lv into this ancestor */
 	struct logical_volume *cow;
 	struct dm_list origin_list;
@@ -505,6 +506,11 @@ struct lv_list {
 	struct logical_volume *lv;
 };
 
+struct glv_list {
+	struct dm_list list;
+	struct generic_logical_volume *glv;
+};
+
 struct vg_list {
 	struct dm_list list;
 	struct volume_group *vg;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 1456fbb..90c459e 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -64,6 +64,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->pv_write_list);
 	dm_list_init(&vg->pvs_outdated);
 	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->historical_lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_lvs);
 	dm_list_init(&vg->removed_pvs);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index f41def8..c5197cb 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -128,6 +128,7 @@ struct volume_group {
 	 * - one for the user-visible mirror LV
 	 */
 	struct dm_list lvs;
+	struct dm_list historical_lvs;
 
 	struct dm_list tags;
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 43987b1..056afd2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3386,6 +3386,7 @@ static struct volume_group _dummy_vg = {
 	.lvm1_system_id = (char *) "",
 	.pvs = DM_LIST_HEAD_INIT(_dummy_vg.pvs),
 	.lvs = DM_LIST_HEAD_INIT(_dummy_vg.lvs),
+	.historical_lvs = DM_LIST_HEAD_INIT(_dummy_vg.historical_lvs),
 	.tags = DM_LIST_HEAD_INIT(_dummy_vg.tags),
 };
 
@@ -3396,6 +3397,7 @@ static struct volume_group _unknown_vg = {
 	.lvm1_system_id = (char *) "",
 	.pvs = DM_LIST_HEAD_INIT(_unknown_vg.pvs),
 	.lvs = DM_LIST_HEAD_INIT(_unknown_vg.lvs),
+	.historical_lvs = DM_LIST_HEAD_INIT(_unknown_vg.historical_lvs),
 	.tags = DM_LIST_HEAD_INIT(_unknown_vg.tags),
 };
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 1a24698..0c73a09 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -244,6 +244,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.name = "",
 		.pvs = DM_LIST_HEAD_INIT(_free_vg.pvs),
 		.lvs = DM_LIST_HEAD_INIT(_free_vg.lvs),
+		.historical_lvs = DM_LIST_HEAD_INIT(_free_vg.historical_lvs),
 		.tags = DM_LIST_HEAD_INIT(_free_vg.tags),
 	};
 
@@ -256,6 +257,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.tags = DM_LIST_HEAD_INIT(_free_logical_volume.tags),
 		.segments = DM_LIST_HEAD_INIT(_free_logical_volume.segments),
 		.segs_using_this_lv = DM_LIST_HEAD_INIT(_free_logical_volume.segs_using_this_lv),
+		.indirect_glvs = DM_LIST_HEAD_INIT(_free_logical_volume.indirect_glvs),
 		.snapshot_segs = DM_LIST_HEAD_INIT(_free_logical_volume.snapshot_segs),
 	};
 


