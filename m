From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:18 +0000 (UTC)
Subject: master - dmeventd_thin: rework failure handling
Message-ID: <20170120230418.2D86860DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43e3268adacbb3cd7b173e24c3423cf9d6807526
Commit:        43e3268adacbb3cd7b173e24c3423cf9d6807526
Parent:        46c23dfb874ab8cebf1b335ef517095ff7bfdd81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 22:53:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:56:39 2017 +0100

dmeventd_thin: rework failure handling

Instead of stopping monitoring after couple failing retries,
keep monitoring forever, just make larger delays between command
retries (ATM upto ~42 minutes).

So syslog is not spammed too often, yet commands have a chance to
be retried and succeed eventually...
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   28 +++++++++++++++++-------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index bdccac6..e1b1f77 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -40,7 +40,7 @@
 
 #define UMOUNT_COMMAND "/bin/umount"
 
-#define MAX_FAILS	(10)
+#define MAX_FAILS	(256)  /* ~42 mins between cmd call retry with 10s delay */
 
 #define THIN_DEBUG 0
 
@@ -55,6 +55,7 @@ struct dso_state {
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
+	unsigned max_fails;
 	int restore_sigset;
 	sigset_t old_sigset;
 	pid_t pid;
@@ -475,11 +476,13 @@ void process_event(struct dm_task *dmt,
 	if (state->known_metadata_size != tps->total_metadata_blocks) {
 		state->metadata_percent_check = CHECK_MINIMUM;
 		state->known_metadata_size = tps->total_metadata_blocks;
+		state->fails = 0;
 	}
 
 	if (state->known_data_size != tps->total_data_blocks) {
 		state->data_percent_check = CHECK_MINIMUM;
 		state->known_data_size = tps->total_data_blocks;
+		state->fails = 0;
 	}
 
 	state->metadata_percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
@@ -520,6 +523,22 @@ void process_event(struct dm_task *dmt,
 			needs_umount = 1;
 	}
 
+	/* Reduce number of _use_policy() calls by power-of-2 factor till frequency of MAX_FAILS is reached.
+	 * Avoids too high number of error retries, yet shows some status messages in log regularly.
+	 * i.e. PV could have been pvmoved and VG/LV was locked for a while...
+	 */
+	if (state->fails) {
+		if (state->fails++ <= state->max_fails) {
+			log_debug("Postponing frequently failing policy (%u <= %u).",
+				  state->fails - 1, state->max_fails);
+			return;
+		}
+		if (state->max_fails < MAX_FAILS)
+			state->max_fails <<= 1;
+		state->fails = needs_policy = 1; /* Retry failing command */
+	} else
+		state->max_fails = 1; /* Reset on success */
+
 	if (needs_policy &&
 	    _use_policy(dmt, state))
 		needs_umount = 0; /* No umount when command was successful */
@@ -533,13 +552,6 @@ out:
 	if (tps)
 		dm_pool_free(state->mem, tps);
 
-	if (state->fails >= MAX_FAILS) {
-		log_warn("WARNING: Dropping monitoring of %s. "
-			 "lvm2 command fails too often (%u times in row).",
-			 device, state->fails);
-		pthread_kill(pthread_self(), SIGALRM);
-	}
-
 	if (new_dmt)
 		dm_task_destroy(new_dmt);
 }


