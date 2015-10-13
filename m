From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:20 +0000 (UTC)
Subject: master - dmeventd: use new macros to init mempool
Message-ID: <20151013140420.16C4661164@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a11cd2ca2d4edbf16c61f8066b1f745fa2fe7d4b
Commit:        a11cd2ca2d4edbf16c61f8066b1f745fa2fe7d4b
Parent:        f9926e7e6c102319575c186e8eef0012cb9c36cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:30:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:56:03 2015 +0200

dmeventd: use new macros to init mempool

For thin and snapshot use new macros
to simplify mempool init and destroy
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   33 +++++++------------
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |   19 +++--------
 2 files changed, 18 insertions(+), 34 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 8d5bce1..56fb7c2 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -32,7 +32,7 @@ struct dso_state {
 	struct dm_pool *mem;
 	int percent_check;
 	uint64_t known_size;
-	char cmd_str[1024];
+	char cmd_lvextend[512];
 };
 
 DM_EVENT_LOG_FN("snap")
@@ -184,11 +184,11 @@ void process_event(struct dm_task *dmt,
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
 			log_warn("WARNING: Snapshot %s is now %i%% full.", device, percent);
+
 		/* Try to extend the snapshot, in accord with user-set policies */
-		if (!_extend(state->cmd_str))
+		if (!_extend(state->cmd_lvextend))
 			log_error("Failed to extend snapshot %s.", device);
 	}
-
 out:
 	if (status)
 		dm_pool_free(state->mem, status);
@@ -201,22 +201,18 @@ int register_device(const char *device,
 		    int minor __attribute__((unused)),
 		    void **user)
 {
-	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
 
-	if (!dmeventd_lvm2_init())
-		goto out;
-
-	if (!(statemem = dm_pool_create("snapshot_state", 512)) ||
-	    !(state = dm_pool_zalloc(statemem, sizeof(*state))))
-		goto bad;
+	if (dmeventd_lvm2_init_with_pool("snapshot_state", state))
+		goto_bad;
 
-	if (!dmeventd_lvm2_command(statemem, state->cmd_str,
-				   sizeof(state->cmd_str),
-				   "lvextend --use-policies", device))
-		goto bad;
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvextend,
+				   sizeof(state->cmd_lvextend),
+				   "lvextend --use-policies", device)) {
+		dmeventd_lvm2_exit_with_pool(state);
+		goto_bad;
+	}
 
-	state->mem = statemem;
 	state->percent_check = CHECK_MINIMUM;
 	*user = state;
 
@@ -224,10 +220,6 @@ int register_device(const char *device,
 
 	return 1;
 bad:
-	if (statemem)
-		dm_pool_destroy(statemem);
-	dmeventd_lvm2_exit();
-out:
 	log_error("Failed to monitor snapshot %s.", device);
 
 	return 0;
@@ -241,9 +233,8 @@ int unregister_device(const char *device,
 {
 	struct dso_state *state = *user;
 
+	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring snapshot %s.", device);
-	dm_pool_destroy(state->mem);
-	dmeventd_lvm2_exit();
 
 	return 1;
 }
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index d21e65b..15af254 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -351,25 +351,19 @@ int register_device(const char *device,
 		    int minor __attribute__((unused)),
 		    void **user)
 {
-	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
 
-	if (!dmeventd_lvm2_init())
-		goto bad;
+	if (!dmeventd_lvm2_init_with_pool("thin_pool_state", state))
+		goto_bad;
 
-	if (!(statemem = dm_pool_create("thin_pool_state", 2048)) ||
-	    !(state = dm_pool_zalloc(statemem, sizeof(*state))) ||
-	    !dmeventd_lvm2_command(statemem, state->cmd_str,
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_str,
 				   sizeof(state->cmd_str),
 				   "lvextend --use-policies",
 				   device)) {
-		if (statemem)
-			dm_pool_destroy(statemem);
-		dmeventd_lvm2_exit();
-		goto bad;
+		dmeventd_lvm2_exit_with_pool(state);
+		goto_bad;
 	}
 
-	state->mem = statemem;
 	state->metadata_percent_check = CHECK_MINIMUM;
 	state->data_percent_check = CHECK_MINIMUM;
 	*user = state;
@@ -391,9 +385,8 @@ int unregister_device(const char *device,
 {
 	struct dso_state *state = *user;
 
+	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring thin %s.", device);
-	dm_pool_destroy(state->mem);
-	dmeventd_lvm2_exit();
 
 	return 1;
 }


