From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 10:59:01 +0000 (UTC)
Subject: master - thin: check runtime table line for merging
Message-ID: <20160418105901.A60B261B7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2cd882f2eef93f02711c34a741bd85d6313eb6e
Commit:        e2cd882f2eef93f02711c34a741bd85d6313eb6e
Parent:        662090e3587d248f1c53bd8dc2989ba0b1960085
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 17 14:51:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 11:18:35 2016 +0200

thin: check runtime table line for merging

To recognize in runtime if we are merging or not
to make consistent decision between suspend and resume
add function to parse thin table line when add
merging thin device to the table.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   65 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 123c383..863fe30 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Recognize in-progress snapshot merge for thin volumes from dm table.
   Avoid deciding to initiate a pending snapshot merge during resume.
   Improve retrying lvmetad requests while lvmetad is being updated.
   Read devices instead of using the lvmetad cache if rescan fails.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 92f2a05..6659190 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -840,6 +840,67 @@ bad:
 	return r;
 }
 
+static int _thin_lv_has_device_id(struct dm_pool *mem, const struct logical_volume *lv,
+				  const char *layer, unsigned device_id)
+{
+	char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	void *next = NULL;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	unsigned id = ~0;
+
+	if (!(dlid = build_dm_uuid(mem, lv, layer)))
+		return_0;
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
+		goto_bad;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	/* If there is a preloaded table, use that in preference. */
+	if (info.inactive_table) {
+		dm_task_destroy(dmt);
+
+		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
+			goto_bad;
+
+		if (!dm_task_query_inactive_table(dmt))
+			goto_out;
+
+		if (!dm_task_run(dmt))
+			goto_out;
+
+		if (!dm_task_get_info(dmt, &info) || !info.exists || !info.inactive_table)
+			goto_out;
+	}
+
+	(void) dm_get_next_target(dmt, next, &start, &length, &type, &params);
+
+	if (!type || strcmp(type, TARGET_NAME_THIN))
+		goto_out;
+
+	if (!params || sscanf(params, "%*u:%*u %u", &id) != 1)
+		goto_out;
+
+	log_debug_activation("%soaded thin volume %s with id %u is %smatching id %u.",
+			     info.inactive_table  ? "Prel" : "L",
+			     display_lvname(lv), id,
+			     (device_id != id) ? "not " : "", device_id);
+out:
+	dm_task_destroy(dmt);
+bad:
+	dm_pool_free(mem, dlid);
+
+	return (device_id == id);
+}
+
 int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t extent_size, int use_linear_target, const char *vgname, const char *lvname)
 {
 	uint32_t page_size;
@@ -2719,7 +2780,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* Preload considers open devices. */
 		/* Resume looks at the table that will be the live one after the operation. */
 		if ((!laopts->resuming && snap_dev_is_open && (seg_is_thin_volume(seg) || !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) ||
-		    (laopts->resuming && !seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+		    (laopts->resuming &&
+		     ((!seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE)) ||
+		      (seg_is_thin_volume(seg) && !_thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id))))) {
 			log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
 			laopts->no_merging = 1;
 		}


