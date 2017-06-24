From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 11:59:46 -0400
Subject: master - libdm: use rounded float for percent print
Message-ID: <201706241559.v5OFxkgp026779@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=feed61f3fa17a94140ba91ae5df844ee4ad34248
Commit:        feed61f3fa17a94140ba91ae5df844ee4ad34248
Parent:        2ef8da61eb968acb3c5c51cdfdc997e8bed90352
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 16:39:50 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:42 2017 +0200

libdm: use rounded float for percent print

Use new added  dm_percent_to_round_float to enhance print
of percentage values.
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    2 +-
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    8 ++++----
 libdm/libdm-report.c                               |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index bab7f0e..93697a0 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -231,7 +231,7 @@ void process_event(struct dm_task *dmt,
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
 			log_warn("WARNING: Snapshot %s is now %.2f%% full.",
-				 device, dm_percent_to_float(percent));
+				 device, dm_percent_to_round_float(percent, 2));
 
 		/* Try to extend the snapshot, in accord with user-set policies */
 		if (!_extend(state->cmd_lvextend))
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 7fd7b0e..4dfd6c7 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -172,8 +172,8 @@ void process_event(struct dm_task *dmt,
 
 #if THIN_DEBUG
 	log_debug("Watch for tp-data:%.2f%%  tp-metadata:%.2f%%.",
-		  dm_percent_to_float(state->data_percent_check),
-		  dm_percent_to_float(state->metadata_percent_check));
+		  dm_percent_to_round_float(state->data_percent_check, 2),
+		  dm_percent_to_round_float(state->metadata_percent_check, 2));
 #endif
 	if (!_wait_for_pid(state)) {
 		log_warn("WARNING: Skipping event, child %d is still running (%s).",
@@ -254,7 +254,7 @@ void process_event(struct dm_task *dmt,
 	if ((state->metadata_percent > WARNING_THRESH) &&
 	    (state->metadata_percent > state->metadata_percent_check))
 		log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
-			 device, dm_percent_to_float(state->metadata_percent));
+			 device, dm_percent_to_round_float(state->metadata_percent, 2));
 	if (state->metadata_percent > CHECK_MINIMUM) {
 		/* Run action when usage raised more than CHECK_STEP since the last time */
 		if (state->metadata_percent > state->metadata_percent_check)
@@ -269,7 +269,7 @@ void process_event(struct dm_task *dmt,
 	if ((state->data_percent > WARNING_THRESH) &&
 	    (state->data_percent > state->data_percent_check))
 		log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
-			 device, dm_percent_to_float(state->data_percent));
+			 device, dm_percent_to_round_float(state->data_percent, 2));
 	if (state->data_percent > CHECK_MINIMUM) {
 		/* Run action when usage raised more than CHECK_STEP since the last time */
 		if (state->data_percent > state->data_percent_check)
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0a5d464..0017ac3 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -373,7 +373,7 @@ int dm_report_field_percent(struct dm_report *rh,
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 7, "%.2f", dm_percent_to_float(*data)) < 0) {
+	if (dm_snprintf(repstr, 7, "%.2f", dm_percent_to_round_float(*data, 2)) < 0) {
 		dm_pool_free(rh->mem, sortval);
 		log_error("dm_report_field_percent: percentage too large.");
 		return 0;


