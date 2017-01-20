From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:22 +0000 (UTC)
Subject: master - dmeventd_thin: new logic for calling commands
Message-ID: <20170120230422.588A260DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c4f3633ac460f24342a83e98afa6e8186d453a3
Commit:        8c4f3633ac460f24342a83e98afa6e8186d453a3
Parent:        8b95551ade0af5c1ef93f044c4508134f359e242
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 23:07:05 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:58:56 2017 +0100

dmeventd_thin: new logic for calling commands

For more advanced support we need to ensure better logic for calling
external much more advanced script for maintanance of thin-pool.

So this new code ensures:

When thin-pool data or metadata is bigger then 50%,
then with each 5% increment, action is called.
This is independent from autoextend_threshold.
This action always happens when thin-pool is over threshold,
(so no action when it's exactly i.e. 60%).
The only exception is 100% full thin-pool - which invokes 'last'
action.

Since thin-pool occupancy may change also downward, code needs
to also handle possibly reduction of occupancy  of thin-pool.
So when usage drop from 90% to 50%, thin-pool will start to call
again action when it will pass 55% threshold.

This give external commands lot of option i.e. to call 'fstrim'
before actual resize is needed.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   44 +++++++++++++-----------
 1 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index bd70e78..2367bde 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -243,21 +243,27 @@ void process_event(struct dm_task *dmt,
 		state->fails = 0;
 	}
 
+	/*
+	 * Trigger action when threshold boundary is exceeded.
+	 * Report 80% threshold warning when it's used above 80%.
+	 * Only 100% is exception as it cannot be surpased so policy
+	 * action is called for:  >50%, >55% ... >95%, 100%
+	 */
 	state->metadata_percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
 	if (state->metadata_percent <= WARNING_THRESH)
 		state->metadata_warn_once = 0; /* Dropped bellow threshold, reset warn once */
 	else if (!state->metadata_warn_once++) /* Warn once when raised above threshold */
 		log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
 			 device, dm_percent_to_float(state->metadata_percent));
-	if (state->metadata_percent >= state->metadata_percent_check) {
-		/*
-		 * Usage has raised more than CHECK_STEP since the last
-		 * time. Run actions.
-		 */
-		state->metadata_percent_check = (state->metadata_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
-
-		needs_policy = 1;
-	}
+	if (state->metadata_percent > CHECK_MINIMUM) {
+		/* Run action when usage raised more than CHECK_STEP since the last time */
+		if (state->metadata_percent > state->metadata_percent_check)
+			needs_policy = 1;
+		state->metadata_percent_check = (state->metadata_percent / CHECK_STEP + 1) * CHECK_STEP;
+		if (state->metadata_percent_check == DM_PERCENT_100)
+			state->metadata_percent_check--; /* Can't get bigger then 100% */
+	} else
+		state->metadata_percent_check = CHECK_MINIMUM;
 
 	state->data_percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
 	if (state->data_percent <= WARNING_THRESH)
@@ -265,15 +271,15 @@ void process_event(struct dm_task *dmt,
 	else if (!state->data_warn_once++)
 		log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
 			 device, dm_percent_to_float(state->data_percent));
-	if (state->data_percent >= state->data_percent_check) {
-		/*
-		 * Usage has raised more than CHECK_STEP since
-		 * the last time. Run actions.
-		 */
-		state->data_percent_check = (state->data_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
-
-		needs_policy = 1;
-	}
+	if (state->data_percent > CHECK_MINIMUM) {
+		/* Run action when usage raised more than CHECK_STEP since the last time */
+		if (state->data_percent > state->data_percent_check)
+			needs_policy = 1;
+		state->data_percent_check = (state->data_percent / CHECK_STEP + 1) * CHECK_STEP;
+		if (state->data_percent_check == DM_PERCENT_100)
+			state->data_percent_check--; /* Can't get bigger then 100% */
+	} else
+		state->data_percent_check = CHECK_MINIMUM;
 
 	/* Reduce number of _use_policy() calls by power-of-2 factor till frequency of MAX_FAILS is reached.
 	 * Avoids too high number of error retries, yet shows some status messages in log regularly.
@@ -372,8 +378,6 @@ int register_device(const char *device,
 		_init_thread_signals(state);
 	}
 
-	state->metadata_percent_check = CHECK_MINIMUM;
-	state->data_percent_check = CHECK_MINIMUM;
 	state->pid = -1;
 	*user = state;
 


