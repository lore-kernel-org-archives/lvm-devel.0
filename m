From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:16 +0000 (GMT)
Subject: main - lvpoll: improve merge polling
Message-ID: <20210315101416.1430C3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eadd58a97dd9a199b74260e8a2bdb5657bf7a88d
Commit:        eadd58a97dd9a199b74260e8a2bdb5657bf7a88d
Parent:        1a451207b8ddbd15519ff9556c59287023ab50fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 22:03:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

lvpoll: improve merge polling

When multiple polling tasks are watching for same LV, clearly
when some of them wins the game - other polling tasks will fail.
Improve the logic and report success if the merged LV is
actually not a merging origin anymore (since likely someone
else has already finished merging).
---
 tools/lvconvert_poll.c | 11 +++++++----
 tools/polldaemon.c     |  9 +++++++--
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 5adb14506..b64cffe21 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -111,9 +111,9 @@ int lvconvert_merge_finish(struct cmd_context *cmd,
 	struct lv_segment *snap_seg = find_snapshot(lv);
 
 	if (!lv_is_merging_origin(lv)) {
-		log_error("Logical volume %s has no merging snapshot.",
+		log_print("Logical volume %s is no longer merging origin, polling has finished.",
 			  display_lvname(lv));
-		return 0;
+		return 1;
 	}
 
 	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.",
@@ -141,8 +141,11 @@ progress_t poll_merge_progress(struct cmd_context *cmd,
 {
 	dm_percent_t percent = DM_PERCENT_0;
 
-	if (!lv_is_merging_origin(lv) ||
-	    !lv_snapshot_percent(lv, &percent)) {
+	if (!lv_is_merging_origin(lv))
+		/* Nothing to monitor here */
+		return PROGRESS_FINISHED_ALL;
+
+	if (!lv_snapshot_percent(lv, &percent)) {
 		log_error("%s: Failed query for merging percentage. Aborting merge.",
 			  display_lvname(lv));
 		return PROGRESS_CHECK_FAILED;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 32733b8ea..c182e548e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -172,8 +172,13 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
 		if (!vg) {
 			/* What more could we do here? */
-			log_error("ABORTING: Can't reread VG for %s error flags %x.", id->display_name, error_flags);
-			ret = 0;
+			if (error_flags & FAILED_NOTFOUND) {
+				log_print_unless_silent("Can't find VG %s. No longer active.", id->display_name);
+				ret = 1;
+			} else {
+				log_error("ABORTING: Can't reread VG for %s error flags %x.", id->display_name, error_flags);
+				ret = 0;
+			}
 			goto out;
 		}
 


