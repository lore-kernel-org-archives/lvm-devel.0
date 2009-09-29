From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 11:22:56 -0400
Subject: [PATCH 3/4] Define new periodic polling method: poll_progress
In-Reply-To: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254237777-30501-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Define new polling method poll_progress that is called periodically. The method
can return:
0 --- error
PROGRESS_TRY_AGAIN --- should be called again after specified interval
PROGRESS_UPDATE_METADATA --- should call update_metadata method and continue
			     polling
PROGRESS_FINISHED --- should call finish_copy and exit polling

The hard-coded mirror-specific code in polldaemon was moved to function
poll_mirror_progress. The rest of the polldaemon is mirror-free so it can be
used for merging snapshots as well.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 tools/lvconvert.c  |    1 +
 tools/polldaemon.c |   49 +++++++++++++++++++++++++++++++++++++------------
 tools/polldaemon.h |   31 +++++++++++++++++++++----------
 tools/pvmove.c     |    1 +
 4 files changed, 60 insertions(+), 22 deletions(-)

Index: lvm2/tools/lvconvert.c
===================================================================
--- lvm2.orig/tools/lvconvert.c
+++ lvm2/tools/lvconvert.c
@@ -316,6 +316,7 @@ static struct poll_functions _lvconvert_
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
 	.update_metadata = _update_lvconvert_mirror,
+	.poll_progress = poll_mirror_progress,
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -63,6 +63,38 @@ static int _become_daemon(struct cmd_con
 	return 1;
 }
 
+int poll_mirror_progress(struct cmd_context *cmd, struct volume_group *vg,
+			 struct logical_volume *lv, struct daemon_parms *parms)
+{
+	float segment_percent = 0.0, overall_percent = 0.0;
+	int status, overall_status;
+	uint32_t event_nr = 0;
+
+	if (!(status = lv_mirror_percent(cmd, lv, !parms->interval,
+					 &segment_percent, &event_nr))) {
+		log_error("ABORTING: Mirror percentage check failed.");
+		return 0;
+	}
+
+	overall_status = copy_percent(lv, &overall_percent);
+	if (parms->progress_display)
+		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title,
+			  overall_percent);
+	else
+		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
+			    overall_percent);
+
+	if (status < TARGET_STATUS_FINISHED) {
+		/* The only case the caller *should* try again later */
+		return PROGRESS_TRY_AGAIN;
+	}
+
+	if (overall_status == TARGET_STATUS_FINISHED)
+		return PROGRESS_FINISHED;
+	else
+		return PROGRESS_UPDATE_METADATA;
+}
+
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
@@ -70,9 +102,7 @@ static int _check_lv_status(struct cmd_c
 			    int *finished)
 {
 	struct dm_list *lvs_changed;
-	float segment_percent = 0.0, overall_percent = 0.0;
-	int status, overall_status;
-	uint32_t event_nr = 0;
+	int r;
 
 	/* By default, caller should not retry */
 	*finished = 1;
@@ -87,16 +117,11 @@ static int _check_lv_status(struct cmd_c
 		return 0;
 	}
 
-	if (!(status = lv_mirror_percent(cmd, lv, !parms->interval,
-					 &segment_percent, &event_nr))) {
-		log_error("ABORTING: Mirror percentage check failed.");
+	r = parms->poll_fns->poll_progress(cmd, vg, lv, parms);
+	if (!r)
 		return 0;
-	}
 
-	overall_status = copy_percent(lv, &overall_percent);
-
-	if (status < TARGET_STATUS_FINISHED) {
-		/* The only case the caller *should* try again later */
+	if (r == PROGRESS_TRY_AGAIN) {
 		*finished = 0;
 		return 1;
 	}
@@ -107,7 +132,7 @@ static int _check_lv_status(struct cmd_c
 	}
 
 	/* Finished? Or progress to next segment? */
-	if (overall_status == TARGET_STATUS_FINISHED) {
+	if (r == PROGRESS_FINISHED) {
 		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
 			return 0;
 	} else {
Index: lvm2/tools/polldaemon.h
===================================================================
--- lvm2.orig/tools/polldaemon.h
+++ lvm2/tools/polldaemon.h
@@ -18,6 +18,19 @@
 
 #include "metadata-exported.h"
 
+struct poll_functions;
+
+struct daemon_parms {
+	unsigned interval;
+	unsigned aborting;
+	unsigned background;
+	unsigned outstanding_count;
+	unsigned progress_display;
+	const char *progress_title;
+	uint32_t lv_type;
+	struct poll_functions *poll_fns;
+};
+
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
@@ -28,6 +41,8 @@ struct poll_functions {
 					       const char *name,
 					       const char *uuid,
 					       uint32_t lv_type);
+	int (*poll_progress) (struct cmd_context *cmd, struct volume_group *vg,
+			 struct logical_volume *lv, struct daemon_parms *parms);
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
 				struct logical_volume *lv,
@@ -38,16 +53,12 @@ struct poll_functions {
 			    struct dm_list *lvs_changed);
 };
 
-struct daemon_parms {
-	unsigned interval;
-	unsigned aborting;
-	unsigned background;
-	unsigned outstanding_count;
-	unsigned progress_display;
-	const char *progress_title;
-	uint32_t lv_type;
-	struct poll_functions *poll_fns;
-};
+int poll_mirror_progress(struct cmd_context *cmd, struct volume_group *vg,
+			 struct logical_volume *lv, struct daemon_parms *parms);
+
+#define PROGRESS_TRY_AGAIN		1
+#define PROGRESS_UPDATE_METADATA	2
+#define PROGRESS_FINISHED		3
 
 int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		unsigned background,
Index: lvm2/tools/pvmove.c
===================================================================
--- lvm2.orig/tools/pvmove.c
+++ lvm2/tools/pvmove.c
@@ -562,6 +562,7 @@ static struct poll_functions _pvmove_fns
 	.get_copy_name_from_lv = get_pvmove_pvname_from_lv_mirr,
 	.get_copy_vg = _get_move_vg,
 	.get_copy_lv = find_pvmove_lv_from_pvname,
+	.poll_progress = poll_mirror_progress,
 	.update_metadata = _update_metadata,
 	.finish_copy = _finish_pvmove,
 };


