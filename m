From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:35 +0000 (UTC)
Subject: master - dmeventd: snapshot plugin updates
Message-ID: <20151022213335.0B79F610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ff5b03e5e82b31ed332ee95631cede836224621
Commit:        7ff5b03e5e82b31ed332ee95631cede836224621
Parent:        91350f5c6ad149a565402254688c6bd1700c5bf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 15:35:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:29:50 2015 +0200

dmeventd: snapshot plugin updates

Improve test for invalid snapshot.

Use dm_make_percent() to manipulate with exactly same percentage
as lvm2 command is using.
---
 WHATS_NEW_DM                                       |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   42 +++++++++----------
 2 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 653e32d..ba22f1e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Snapshot plugin for dmeventd improved percentage usage.
   Add dm_hold_control_dev to allow holding of control device open.
   Add dm_report_compact_given_fields to remove given empty fields from report.
   Use libdm status parsing and local mem raid dmeventd plugin.
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index d5575f3..f864bb4 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -20,17 +20,17 @@
 #include <stdarg.h>
 
 /* First warning when snapshot is 80% full. */
-#define WARNING_THRESH 80
+#define WARNING_THRESH	(DM_PERCENT_1 * 80)
 /* Run a check every 5%. */
-#define CHECK_STEP 5
+#define CHECK_STEP	(DM_PERCENT_1 *  5)
 /* Do not bother checking snapshots less than 50% full. */
-#define CHECK_MINIMUM 50
+#define CHECK_MINIMUM	(DM_PERCENT_1 * 50)
 
 #define UMOUNT_COMMAND "/bin/umount"
 
 struct dso_state {
 	struct dm_pool *mem;
-	int percent_check;
+	dm_percent_t percent_check;
 	uint64_t known_size;
 	char cmd_lvextend[512];
 };
@@ -137,6 +137,7 @@ void process_event(struct dm_task *dmt,
 	struct dm_status_snapshot *status = NULL;
 	const char *device = dm_task_get_name(dmt);
 	int percent;
+	struct dm_info info;
 
 	/* No longer monitoring, waiting for remove */
 	if (!state->percent_check)
@@ -148,22 +149,9 @@ void process_event(struct dm_task *dmt,
 		return;
 	}
 
-	if (!dm_get_status_snapshot(state->mem, params, &status))
+	if (!dm_get_status_snapshot(state->mem, params, &status)) {
+		log_error("Cannot parse snapshot %s state: %s.", device, params);
 		return;
-
-	if (status->invalid || status->overflow) {
-		struct dm_info info;
-		log_error("Snapshot %s is lost.", device);
-		if (dm_task_get_info(dmt, &info)) {
-			_umount(device, info.major, info.minor);
-			goto_out;
-		} /* else; too bad, but this is best-effort thing... */
-	}
-
-	/* Snapshot size had changed. Clear the threshold. */
-	if (state->known_size != status->total_sectors) {
-		state->percent_check = CHECK_MINIMUM;
-		state->known_size = status->total_sectors;
 	}
 
 	/*
@@ -171,19 +159,29 @@ void process_event(struct dm_task *dmt,
 	 * the status string. Report the full status string to syslog.
 	 */
 	if (status->invalid || status->overflow || !status->total_sectors) {
-		log_error("Snapshot %s changed state to: %s.", device, params);
+		log_warn("WARNING: Snapshot %s changed state to: %s and should be removed.",
+			 device, params);
 		state->percent_check = 0;
+		if (dm_task_get_info(dmt, &info))
+			_umount(device, info.major, info.minor);
 		goto out;
 	}
 
-	percent = (int) (100 * status->used_sectors / status->total_sectors);
+	/* Snapshot size had changed. Clear the threshold. */
+	if (state->known_size != status->total_sectors) {
+		state->percent_check = CHECK_MINIMUM;
+		state->known_size = status->total_sectors;
+	}
+
+	percent = dm_make_percent(status->used_sectors, status->total_sectors);
 	if (percent >= state->percent_check) {
 		/* Usage has raised more than CHECK_STEP since the last
 		   time. Run actions. */
 		state->percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			log_warn("WARNING: Snapshot %s is now %i%% full.", device, percent);
+			log_warn("WARNING: Snapshot %s is now %.2f%% full.",
+				 device, dm_percent_to_float(percent));
 
 		/* Try to extend the snapshot, in accord with user-set policies */
 		if (!_extend(state->cmd_lvextend))


