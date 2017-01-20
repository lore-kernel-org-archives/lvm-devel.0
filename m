From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:07 +0000 (UTC)
Subject: master - dmeventd_thin: better warning logic
Message-ID: <20170120230407.BF86060D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5bef508275f7d9889062f8e15e39aa63a9a938e
Commit:        e5bef508275f7d9889062f8e15e39aa63a9a938e
Parent:        0d945ddbad82686aa590a2e566807723d66be1a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 21:53:13 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: better warning logic

When fullness is passing WARN_THRESHOLD, print warning,
when it drops bellow and crossed again, we should print
warning again, but always only once.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index ff127be..b436524 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -48,8 +48,10 @@ struct dso_state {
 	struct dm_pool *mem;
 	int metadata_percent_check;
 	int metadata_percent;
+	int metadata_warn_once;
 	int data_percent_check;
 	int data_percent;
+	int data_warn_once;
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
@@ -400,6 +402,11 @@ void process_event(struct dm_task *dmt,
 	}
 
 	state->metadata_percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
+	if (state->metadata_percent <= WARNING_THRESH)
+		state->metadata_warn_once = 0; /* Dropped bellow threshold, reset warn once */
+	else if (!state->metadata_warn_once++) /* Warn once when raised above threshold */
+		log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
+			 device, dm_percent_to_float(state->metadata_percent));
 	if (state->metadata_percent >= state->metadata_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since the last
@@ -407,10 +414,6 @@ void process_event(struct dm_task *dmt,
 		 */
 		state->metadata_percent_check = (state->metadata_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
-		/* FIXME: extension of metadata needs to be written! */
-		if (state->metadata_percent >= WARNING_THRESH)
-			log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
-				 device, dm_percent_to_float(state->metadata_percent));
 		needs_policy = 1;
 
 		if (state->metadata_percent >= UMOUNT_THRESH)
@@ -418,6 +421,11 @@ void process_event(struct dm_task *dmt,
 	}
 
 	state->data_percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
+	if (state->data_percent <= WARNING_THRESH)
+		state->data_warn_once = 0;
+	else if (!state->data_warn_once++)
+		log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
+			 device, dm_percent_to_float(state->data_percent));
 	if (state->data_percent >= state->data_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since
@@ -425,9 +433,6 @@ void process_event(struct dm_task *dmt,
 		 */
 		state->data_percent_check = (state->data_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
-		if (state->data_percent >= WARNING_THRESH)
-			log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
-				 device, dm_percent_to_float(state->data_percent));
 		needs_policy = 1;
 
 		if (state->data_percent >= UMOUNT_THRESH)


