From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 09:41:51 -0400
Subject: master - RAID (lvconvert/dmeventd): Cleanly handle primary failure during 'recover' op
Message-ID: <201706141341.v5EDfp1n012493@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c0e908b0ac012a5517e61420ea1eccc6193c00a
Commit:        4c0e908b0ac012a5517e61420ea1eccc6193c00a
Parent:        d34d2068ddf20b7d683ee06205c31ec673b32813
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 08:39:50 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 08:39:50 2017 -0500

RAID (lvconvert/dmeventd):  Cleanly handle primary failure during 'recover' op

Add the checks necessary to distiguish the state of a RAID when the primary
source for syncing fails during the "recover" process.

It has been possible to hit this condition before (like when converting from
2-way RAID1 to 3-way and having the first two devices die during the "recover"
process).  However, this condition is now more likely since we treat linear ->
RAID1 conversions as "recover" now - so it is especially important we cleanly
handle this condition.
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   16 +++++++
 lib/metadata/raid_manip.c                     |   60 +++++++++++++++++++++++++
 2 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 4f204bf..afeac28 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -58,6 +58,22 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 		dead = 1;
 	}
 
+	/*
+	 * if we are converting from non-RAID to RAID (e.g. linear -> raid1)
+	 * and too many original devices die, such that we cannot continue
+	 * the "recover" operation, the sync action will go to "idle", the
+	 * unsynced devs will remain at 'a', and the original devices will
+	 * NOT SWITCH TO 'D', but will remain at 'A' - hoping to be revived.
+	 *
+	 * This is simply the way the kernel works...
+	 */
+	if (!strcmp(status->sync_action, "idle") &&
+	    strchr(status->dev_health, 'a')) {
+		log_error("Primary sources for new RAID, %s, have failed.",
+			  device);
+		dead = 1; /* run it through LVM repair */
+	}
+
 	if (dead) {
 		if (status->insync_regions < status->total_regions) {
 			if (!state->warned) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ac0b8f1..0925594 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6408,6 +6408,39 @@ has_enough_space:
 }
 
 /*
+ * _lv_raid_has_primary_failure_on_recover
+ * @lv
+ *
+ * The kernel behaves strangely in the presense of a primary failure
+ * during a "recover" sync operation.  It's not technically a bug, I
+ * suppose, but the output of the status line can make it difficult
+ * to determine that we are in this state.  The sync ratio will be
+ * 100% and the sync action will be "idle", but the health characters
+ * will be e.g. "Aaa" or "Aa", where the 'A' is the dead
+ * primary source that cannot be marked dead by the kernel b/c
+ * it is the only source for the remainder of data.
+ *
+ * This function helps to detect that condition.
+ *
+ * Returns: 1 if the state is detected, 0 otherwise.
+ * FIXME: would be better to return -1,0,1 to allow error report.
+ */
+int _lv_raid_has_primary_failure_on_recover(struct logical_volume *lv)
+{
+	char *tmp_dev_health;
+	char *tmp_sync_action;
+
+	if (!lv_raid_sync_action(lv, &tmp_sync_action) ||
+	    !lv_raid_dev_health(lv, &tmp_dev_health))
+		return_0;
+
+	if (!strcmp(tmp_sync_action, "idle") && strchr(tmp_dev_health, 'a'))
+		return 1;
+
+	return 0;
+}
+
+/*
  * Helper:
  *
  * _lv_raid_rebuild_or_replace
@@ -6458,11 +6491,38 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	}
 
 	if (!_raid_in_sync(lv)) {
+		/*
+		 * FIXME: There is a bug in the kernel that prevents 'rebuild'
+		 *        from being specified when the array is not in-sync.
+		 *        There are conditions where this should be allowed,
+		 *        but only when we are doing a repair - as indicated by
+		 *        'lv->vg->cmd->handles_missing_pvs'.  The above
+		 *        conditional should be:
+		 (!lv->vg->cmd->handles_missing_pvs && !_raid_in_sync(lv))
+		 */
 		log_error("Unable to replace devices in %s while it is "
 			  "not in-sync.", display_lvname(lv));
 		return 0;
 	}
 
+	if (_lv_raid_has_primary_failure_on_recover(lv)) {
+		/*
+		 * I hate having multiple error lines, but this
+		 * seems to work best for syslog and CLI.
+		 */
+		log_error("Unable to repair %s/%s.  Source devices failed"
+			  " before the RAID could synchronize.",
+			  lv->vg->name, lv->name);
+		log_error("You should choose one of the following:");
+		log_error("  1) deactivate %s/%s, revive failed "
+			  "device, re-activate LV, and proceed.",
+			  lv->vg->name, lv->name);
+		log_error("  2) remove the LV (all data is lost).");
+		log_error("  3) Seek expert advice to attempt to salvage any"
+			  " data from remaining devices.");
+		return 0;
+	}
+
 	/*
 	 * How many sub-LVs are being removed?
 	 */


