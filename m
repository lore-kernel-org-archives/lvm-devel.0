From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:05 +0000 (UTC)
Subject: master - dmeventd_thin: switch to struct percent
Message-ID: <20170120230405.A0F4460D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d945ddbad82686aa590a2e566807723d66be1a7
Commit:        0d945ddbad82686aa590a2e566807723d66be1a7
Parent:        eca964b554e371f699758ebfa0837f2e7a8cba87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 14:06:29 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: switch to struct percent

Later we can use stored percent values to pass them
to executed commands.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   33 +++++++++++-------------
 1 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 65de465..ff127be 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -47,7 +47,9 @@
 struct dso_state {
 	struct dm_pool *mem;
 	int metadata_percent_check;
+	int metadata_percent;
 	int data_percent_check;
+	int data_percent;
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
@@ -319,7 +321,6 @@ void process_event(struct dm_task *dmt,
 		   void **user)
 {
 	const char *device = dm_task_get_name(dmt);
-	int percent;
 	struct dso_state *state = *user;
 	struct dm_status_thin_pool *tps = NULL;
 	void *next = NULL;
@@ -336,13 +337,9 @@ void process_event(struct dm_task *dmt,
 		  dm_percent_to_float(state->metadata_percent_check));
 #endif
 
-#if 0
-	/* No longer monitoring, waiting for remove */
-	if (!state->meta_percent_check && !state->data_percent_check)
-		return;
-#endif
 	if (event & DM_EVENT_DEVICE_ERROR) {
 		/* Error -> no need to check and do instant resize */
+		state->data_percent = state->metadata_percent = 0;
 		if (_use_policy(dmt, state))
 			goto out;
 
@@ -402,38 +399,38 @@ void process_event(struct dm_task *dmt,
 		state->known_data_size = tps->total_data_blocks;
 	}
 
-	percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
-	if (percent >= state->metadata_percent_check) {
+	state->metadata_percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
+	if (state->metadata_percent >= state->metadata_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since the last
 		 * time. Run actions.
 		 */
-		state->metadata_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+		state->metadata_percent_check = (state->metadata_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		/* FIXME: extension of metadata needs to be written! */
-		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
+		if (state->metadata_percent >= WARNING_THRESH)
 			log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
-				 device, dm_percent_to_float(percent));
+				 device, dm_percent_to_float(state->metadata_percent));
 		needs_policy = 1;
 
-		if (percent >= UMOUNT_THRESH)
+		if (state->metadata_percent >= UMOUNT_THRESH)
 			needs_umount = 1;
 	}
 
-	percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
-	if (percent >= state->data_percent_check) {
+	state->data_percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
+	if (state->data_percent >= state->data_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since
 		 * the last time. Run actions.
 		 */
-		state->data_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+		state->data_percent_check = (state->data_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
-		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
+		if (state->data_percent >= WARNING_THRESH)
 			log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
-				 device, dm_percent_to_float(percent));
+				 device, dm_percent_to_float(state->data_percent));
 		needs_policy = 1;
 
-		if (percent >= UMOUNT_THRESH)
+		if (state->data_percent >= UMOUNT_THRESH)
 			needs_umount = 1;
 	}
 


