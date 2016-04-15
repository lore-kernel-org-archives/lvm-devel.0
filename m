From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Apr 2016 01:34:51 +0000 (UTC)
Subject: master - activate: Improve snapshot merge initiation
Message-ID: <20160415013451.3756260F5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6954de22e2281876506c0db1c98972242de977fb
Commit:        6954de22e2281876506c0db1c98972242de977fb
Parent:        150cff9cce019e3211d99dbdceaccf77db1e503a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 15 02:21:27 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 15 02:33:38 2016 +0100

activate: Improve snapshot merge initiation

A snapshot merge into its origin cannot be initiated while the devices
are in use.  If there is outside interference (such as from udev),
the suspend (preload) and resume stages can reach conflicting decisions
about whether or not to proceed.

Try to make the logic more robust by checking the inactive or live
table during resume.  (This is still not perfect.)
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    1 +
 lib/activate/activate.h    |    1 +
 lib/activate/dev_manager.c |   40 +++++++++++++++++++++++++++++-----------
 4 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8c58c8d..123c383 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Avoid deciding to initiate a pending snapshot merge during resume.
   Improve retrying lvmetad requests while lvmetad is being updated.
   Read devices instead of using the lvmetad cache if rescan fails.
   Move lvmetad token/filter check and device rescan to the start of commands.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8e6ee33..ac547ce 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2063,6 +2063,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	laopts->read_only = _passes_readonly_filter(cmd, lv);
+	laopts->resuming = 1;
 
 	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 64c026e..880689c 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -81,6 +81,7 @@ struct lv_activate_opts {
 				 * set of flags to avoid any scanning in udev. These udev
 				 * flags are persistent in udev db for any spurious event
 				 * that follows. */
+	unsigned resuming;	/* Set when resuming after a suspend. */
 };
 
 void set_activation(int activation, int silent);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d25c07e..92f2a05 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -806,13 +806,28 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
 		goto_out;
 
+	/* If there is a preloaded table, use that in preference. */
+	if (info.inactive_table) {
+		dm_task_destroy(dmt);
+
+		if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
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
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &type, &params);
-		if (type && strncmp(type, target_type,
-				    strlen(target_type)) == 0) {
-			if (info.live_table)
-				r = 1;
+		if (type && !strncmp(type, target_type, strlen(target_type))) {
+			r = 1;
 			break;
 		}
 	} while (next);
@@ -2665,6 +2680,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	int save_pending_delete = dm->track_pending_delete;
+	int snap_dev_is_open = 0;
 
 	/* LV with pending delete is never put new into a table */
 	if (lv_is_pending_delete(lv) && !_cached_dm_info(dm->mem, dtree, lv, NULL))
@@ -2697,13 +2713,15 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    ((dinfo = _cached_dm_info(dm->mem, dtree,
 					      seg_is_thin_volume(seg) ?
 					      seg->lv : seg->cow, NULL)) &&
-		     dinfo->open_count)) {
-			if (seg_is_thin_volume(seg) ||
-			    /* FIXME Is there anything simpler to check for instead? */
-			    !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
-				log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
-				laopts->no_merging = 1;
-			}
+		     dinfo->open_count))
+			snap_dev_is_open = 1;
+
+		/* Preload considers open devices. */
+		/* Resume looks at the table that will be the live one after the operation. */
+		if ((!laopts->resuming && snap_dev_is_open && (seg_is_thin_volume(seg) || !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) ||
+		    (laopts->resuming && !seg_is_thin_volume(seg) && !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+			log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
+			laopts->no_merging = 1;
 		}
 	}
 


