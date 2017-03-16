From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 16:05:51 -0400
Subject: master - dmeventd: adjust mirror/raid DSOs to new repair design
Message-ID: <201703162005.v2GK5pKV008077@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a37bb7b2a509f2d27800470af1a7a339a7c73794
Commit:        a37bb7b2a509f2d27800470af1a7a339a7c73794
Parent:        73d028023a47a254b9762545222ca3eb778a620b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 21:03:51 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 21:05:05 2017 +0100

dmeventd: adjust mirror/raid DSOs to new repair design

Previous commit 506d88a2ec8c introduced disabling lvmetad on repairs.

Avoid calling lvscan and use of any --config options altogether
in the mirror and raid DSOs.

Related: rhbz1380521
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   18 ++++--------------
 daemons/dmeventd/plugins/raid/dmeventd_raid.c     |    9 ++-------
 2 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index d3bd12a..071fb16 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -25,7 +25,6 @@
 
 struct dso_state {
 	struct dm_pool *mem;
-	char cmd_lvscan[512];
 	char cmd_lvconvert[512];
 };
 
@@ -99,21 +98,14 @@ static int _get_mirror_event(struct dso_state *state, char *params)
 	return r;
 }
 
-static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert,
-				  const char *device)
+static int _remove_failed_devices(const char *cmd_lvconvert, const char *device)
 {
-	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
-		log_warn("WARNING: Re-scan of mirrored device %s failed.", device);
-
 	/* if repair goes OK, report success even if lvscan has failed */
 	if (!dmeventd_lvm2_run_with_lock(cmd_lvconvert)) {
 		log_error("Repair of mirrored device %s failed.", device);
 		return 0;
 	}
 
-	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
-		log_warn("WARNING: Re-scan of mirrored device %s failed.", device);
-
 	log_info("Repair of mirrored device %s finished successfully.", device);
 
 	return 1;
@@ -154,9 +146,7 @@ void process_event(struct dm_task *dmt,
 			break;
 		case ME_FAILURE:
 			log_error("Device failure in %s.", device);
-			if (!_remove_failed_devices(state->cmd_lvscan,
-						    state->cmd_lvconvert,
-						    device))
+			if (!_remove_failed_devices(state->cmd_lvconvert, device))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				log_error("Failed to remove faulty devices in %s.",
 					  device);
@@ -188,7 +178,7 @@ int register_device(const char *device,
 
         /* CANNOT use --config as this disables cached content */
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --config global{use_lvmetad = 0}' --repair --use-policies", device))
+				   "lvconvert --repair --use-policies", device))
 		goto_bad;
 
 	*user = state;
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index ae3fc86..4f204bf 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -22,7 +22,6 @@
 
 struct dso_state {
 	struct dm_pool *mem;
-	char cmd_lvscan[512];
 	char cmd_lvconvert[512];
 	uint64_t raid_devs[RAID_DEVS_ELEMS];
 	int failed;
@@ -74,8 +73,6 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 			goto out; /* already reported */
 
 		state->failed = 1;
-		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvscan))
-			log_warn("WARNING: Re-scan of RAID device %s failed.", device);
 
 		/* if repair goes OK, report success even if lvscan has failed */
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvconvert)) {
@@ -136,9 +133,7 @@ int register_device(const char *device,
 	if (!dmeventd_lvm2_init_with_pool("raid_state", state))
 		goto_bad;
 
-	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvscan, sizeof(state->cmd_lvscan),
-				   "lvscan --cache", device) ||
-	    !dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
+	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
 				   "lvconvert --config devices{ignore_suspended_devices=1} "
 				   "--repair --use-policies", device))
 		goto_bad;


