From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:28 +0000 (UTC)
Subject: master - dmeventd: rework raid plugin
Message-ID: <20151013140428.7A5B560D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b586ad3c26be5eaaeff38d767d5f2421ee1151b
Commit:        4b586ad3c26be5eaaeff38d767d5f2421ee1151b
Parent:        256e432e78b720b929a285f5809b1d875b01861a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:37:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:19 2015 +0200

dmeventd: rework raid plugin

Switch to per-thread mem-pool and lock only for lvm2 calls.
Use libdm parser for raid status line.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |  116 ++++++-------------------
 2 files changed, 29 insertions(+), 88 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 30ce2cd..dffcd34 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Use libdm status parsing and local mem raid dmeventd plugin.
   Use local mem pool and lock only lvm2 execution for mirror dmeventd plugin.
   Lock protect only lvm2 execution for snapshot and thin dmeventd plugin.
   Use local mempool for raid and mirror plugins.
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 714832b..f00ffa4 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -27,112 +27,54 @@ DM_EVENT_LOG_FN("raid")
 
 /* FIXME Reformat to 80 char lines. */
 
-/*
- * run_repair is a close copy to
- * plugins/mirror/dmeventd_mirror.c:_remove_failed_devices()
- */
-static int run_repair(const char *device)
+static int _process_raid_event(struct dso_state *state, char *params, const char *device)
 {
-	int r;
-#define CMD_SIZE 256	/* FIXME Use system restriction */
-	char cmd_str[CMD_SIZE];
-
-	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
-				  "lvscan --cache", device))
-		return -1;
-
-	r = dmeventd_lvm2_run(cmd_str);
-
-	if (!r)
-		log_info("Re-scan of RAID device %s failed.", device);
-
-	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
-				  "lvconvert --config devices{ignore_suspended_devices=1} "
-				  "--repair --use-policies", device))
-		return -1;
-
-	/* if repair goes OK, report success even if lvscan has failed */
-	r = dmeventd_lvm2_run(cmd_str);
-
-	if (!r)
-		log_info("Repair of RAID device %s failed.", device);
-
-	return (r) ? 0 : -1;
-}
+	struct dm_status_raid *status;
+	const char *d;
 
-static int _process_raid_event(char *params, const char *device)
-{
-	int i, n, failure = 0;
-	char *p, *a[4];
-	char *raid_type;
-	char *num_devices;
-	char *health_chars;
-	char *resync_ratio;
-
-	/*
-	 * RAID parms:     <raid_type> <#raid_disks> \
-	 *                 <health chars> <resync ratio>
-	 */
-	if (!dm_split_words(params, 4, 0, a)) {
+	if (!dm_get_status_raid(state->mem, params, &status)) {
 		log_error("Failed to process status line for %s.", device);
-		return -EINVAL;
-	}
-	raid_type = a[0];
-	num_devices = a[1];
-	health_chars = a[2];
-	resync_ratio = a[3];
-
-	if (!(n = atoi(num_devices))) {
-		log_error("Failed to parse number of devices for %s: %s.",
-			  device, num_devices);
-		return -EINVAL;
+		return 0;
 	}
 
-	for (i = 0; i < n; i++) {
-		switch (health_chars[i]) {
-		case 'A':
-			/* Device is 'A'live and well */
-		case 'a':
-			/* Device is 'a'live, but not yet in-sync */
-			break;
-		case 'D':
-			log_error("Device #%d of %s array, %s, has failed.",
-				  i, raid_type, device);
-			failure++;
-			break;
-		default:
-			/* Unhandled character returned from kernel */
-			break;
+	if ((d = strchr(status->dev_health, 'D')) && !state->failed) {
+		log_error("Device #%d of %s array, %s, has failed.",
+			 (int)(d - status->dev_health),
+			 status->raid_type, device);
+
+		state->failed = 1;
+		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvscan))
+			log_info("Re-scan of RAID device %s failed.", device);
+
+		/* if repair goes OK, report success even if lvscan has failed */
+		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvconvert)) {
+			log_info("Repair of RAID device %s failed.", device);
+			dm_pool_free(state->mem, status);
+			return 0;
 		}
-		if (failure)
-			return run_repair(device);
+	} else {
+		state->failed = 0;
+		log_info("%s array, %s, is %s in-sync.",
+			 status->raid_type, device,
+			 (status->insync_regions == status->total_regions) ? "now" : "not");
 	}
 
-	p = strstr(resync_ratio, "/");
-	if (!p) {
-		log_error("Failed to parse resync_ratio for %s: %s.",
-			  device, resync_ratio);
-		return -EINVAL;
-	}
-	p[0] = '\0';
-	log_info("%s array, %s, is %s in-sync.",
-		 raid_type, device, strcmp(resync_ratio, p+1) ? "not" : "now");
+	dm_pool_free(state->mem, status);
 
-	return 0;
+	return 1;
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
@@ -147,12 +89,10 @@ void process_event(struct dm_task *dmt,
 			continue;
 		}
 
-		if (_process_raid_event(params, device))
+		if (!_process_raid_event(state, params, device))
 			log_error("Failed to process event for %s.",
 				  device);
 	} while (next);
-
-	dmeventd_lvm2_unlock();
 }
 
 int register_device(const char *device,


