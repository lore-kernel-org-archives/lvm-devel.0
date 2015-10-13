From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:26 +0000 (UTC)
Subject: master - dmeventd: less locking mirror
Message-ID: <20151013140426.6290261164@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=256e432e78b720b929a285f5809b1d875b01861a
Commit:        256e432e78b720b929a285f5809b1d875b01861a
Parent:        51ff7d5ed8a7afe4e986a08025da9ef294aea479
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:35:44 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:18 2015 +0200

dmeventd: less locking mirror

Rework mirror plugin to use per-thread mem-pool.
This allows to use locking only for lvm2 library calls.
---
 WHATS_NEW_DM                                      |    1 +
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   33 ++++++---------------
 2 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f838b98..30ce2cd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Use local mem pool and lock only lvm2 execution for mirror dmeventd plugin.
   Lock protect only lvm2 execution for snapshot and thin dmeventd plugin.
   Use local mempool for raid and mirror plugins.
   Reworked thread initialization for dmeventd plugins.
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index e8761d9..62ad331 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -131,47 +131,33 @@ out_parse:
 	return ME_IGNORE;
 }
 
-static int _remove_failed_devices(const char *device)
+static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert)
 {
 	int r;
-#define CMD_SIZE 256	/* FIXME Use system restriction */
-	char cmd_str[CMD_SIZE];
 
-	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
-				   "lvscan --cache", device))
-		return -1;
-
-	r = dmeventd_lvm2_run(cmd_str);
-
-	if (!r)
-		log_info("Re-scan of mirror device %s failed.", device);
-
-	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
-				  "lvconvert --config devices{ignore_suspended_devices=1} "
-				  "--repair --use-policies", device))
-		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
+	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
+		log_info("Re-scan of mirrored device failed.");
 
 	/* if repair goes OK, report success even if lvscan has failed */
-	r = dmeventd_lvm2_run(cmd_str);
+	r = dmeventd_lvm2_run_with_lock(cmd_lvconvert);
 
-	log_info("Repair of mirrored device %s %s.", device,
+	log_info("Repair of mirrored device %s.",
 		 (r) ? "finished successfully" : "failed");
 
-	return (r) ? 0 : -1;
+	return r;
 }
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
 		   void **user)
 {
+	struct dso_state *state = *user;
 	void *next = NULL;
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
 	const char *device = dm_task_get_name(dmt);
 
-	dmeventd_lvm2_lock();
-
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
@@ -196,7 +182,8 @@ void process_event(struct dm_task *dmt,
 			break;
 		case ME_FAILURE:
 			log_error("Device failure in %s.", device);
-			if (_remove_failed_devices(device))
+			if (!_remove_failed_devices(state->cmd_lvscan,
+						    state->cmd_lvconvert))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				log_error("Failed to remove faulty devices in %s.",
 					  device);
@@ -213,8 +200,6 @@ void process_event(struct dm_task *dmt,
 			log_info("Unknown event received.");
 		}
 	} while (next);
-
-	dmeventd_lvm2_unlock();
 }
 
 int register_device(const char *device,


