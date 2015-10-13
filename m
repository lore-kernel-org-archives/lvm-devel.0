From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:24 +0000 (UTC)
Subject: master - dmeventd: less locking for snapshot and thin
Message-ID: <20151013140424.4FA896073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51ff7d5ed8a7afe4e986a08025da9ef294aea479
Commit:        51ff7d5ed8a7afe4e986a08025da9ef294aea479
Parent:        49e11102c78ddf74bead6020fc51cae0e78e2ad2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:35:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:01:41 2015 +0200

dmeventd: less locking for snapshot and thin

Use lvm lock for lvm library calls.

dm functions in-use are 'thread-safe' since we use
local per-thread mem pool.
---
 WHATS_NEW_DM                                       |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   20 +++++++++-----------
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    7 +------
 3 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 902a485..f838b98 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Lock protect only lvm2 execution for snapshot and thin dmeventd plugin.
   Use local mempool for raid and mirror plugins.
   Reworked thread initialization for dmeventd plugins.
   Dmeventd handles snapshot overflow for now equally as invalid.
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 56fb7c2..aebe5f9 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -80,7 +80,8 @@ static int _run(const char *cmd, ...)
 
 static int _extend(const char *cmd)
 {
-	return dmeventd_lvm2_run(cmd);
+	log_debug("Extending snapshot via %s.", cmd);
+	return dmeventd_lvm2_run_with_lock(cmd);
 }
 
 static void _umount(const char *device, int major, int minor)
@@ -141,22 +142,21 @@ void process_event(struct dm_task *dmt,
 	if (!state->percent_check)
 		return;
 
-	dmeventd_lvm2_lock();
-
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-	if (!target_type)
-		goto out;
+	if (!target_type || strcmp(target_type, "snapshot")) {
+		log_error("Target %s is not snapshot.", target_type);
+		return;
+	}
 
 	if (!dm_get_status_snapshot(state->mem, params, &status))
-		goto out;
+		return;
 
 	if (status->invalid || status->overflow) {
 		struct dm_info info;
 		log_error("Snapshot %s is lost.", device);
 		if (dm_task_get_info(dmt, &info)) {
-			dmeventd_lvm2_unlock();
 			_umount(device, info.major, info.minor);
-			return;
+			goto_out;
 		} /* else; too bad, but this is best-effort thing... */
 	}
 
@@ -190,9 +190,7 @@ void process_event(struct dm_task *dmt,
 			log_error("Failed to extend snapshot %s.", device);
 	}
 out:
-	if (status)
-		dm_pool_free(state->mem, status);
-	dmeventd_lvm2_unlock();
+	dm_pool_free(state->mem, status);
 }
 
 int register_device(const char *device,
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 15af254..4f08d5b 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -143,7 +143,7 @@ static int _extend(struct dso_state *state)
 #if THIN_DEBUG
 	log_info("dmeventd executes: %s.", state->cmd_str);
 #endif
-	return dmeventd_lvm2_run(state->cmd_str);
+	return dmeventd_lvm2_run_with_lock(state->cmd_str);
 }
 
 static int _run(const char *cmd, ...)
@@ -224,8 +224,6 @@ static void _umount(struct dm_task *dmt, const char *device)
 	if (!dm_task_get_info(dmt, &data.info))
 		return;
 
-	dmeventd_lvm2_unlock();
-
 	if (!(data.minors = dm_bitset_create(NULL, MINORS))) {
 		log_error("Failed to allocate bitset. Not unmounting %s.", device);
 		goto out;
@@ -244,7 +242,6 @@ static void _umount(struct dm_task *dmt, const char *device)
 out:
 	if (data.minors)
 		dm_bitset_destroy(data.minors);
-	dmeventd_lvm2_lock();
 }
 
 void process_event(struct dm_task *dmt,
@@ -265,8 +262,6 @@ void process_event(struct dm_task *dmt,
 	if (!state->meta_percent_check && !state->data_percent_check)
 		return;
 #endif
-	dmeventd_lvm2_lock();
-
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 
 	if (!target_type || (strcmp(target_type, "thin-pool") != 0)) {


