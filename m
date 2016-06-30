From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:00 +0000 (UTC)
Subject: master - dmeventd: thin plugin umount over 95%
Message-ID: <20160630224600.B5DCD611BD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f638e07e814617152d617a2ca7c8acdae41968a
Commit:        2f638e07e814617152d617a2ca7c8acdae41968a
Parent:        103c188681fce748ef193115c126bfbbc65fbab9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 29 15:56:29 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:43:45 2016 +0200

dmeventd: thin plugin umount over 95%

Run umount code only when either thin data or metadata are
above 95% - so if there are resize failures with 60%.
system fill keep running.

Also umount will only be tried with lvm2 LVs.
Foreign users are ATM unsuppored.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   99 ++++++++++++++++++++++---
 2 files changed, 89 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5043c23..30d6d82 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.129 - 
 =================================
+  Thin dmeventd plugin umounts lvm2 volume only when pool is 95% or more.
 
 Version 1.02.128 - 25th June 2016
 =================================
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 0cef168..c27cf50 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -30,6 +30,9 @@
 
 /* First warning when thin data or metadata is 80% full. */
 #define WARNING_THRESH	(DM_PERCENT_1 * 80)
+/* Umount thin LVs when thin data or metadata LV is >=
+ * and lvextend --use-policies has failed. */
+#define UMOUNT_THRESH	(DM_PERCENT_1 * 95)
 /* Run a check every 5%. */
 #define CHECK_STEP	(DM_PERCENT_1 *  5)
 /* Do not bother checking thin data or metadata is less than 50% full. */
@@ -53,6 +56,53 @@ struct dso_state {
 
 DM_EVENT_LOG_FN("thin")
 
+#define UUID_PREFIX "LVM-"
+
+/* Figure out device UUID has LVM- prefix and is OPEN */
+static int _has_unmountable_prefix(int major, int minor)
+{
+	struct dm_task *dmt;
+	struct dm_info info;
+	const char *uuid;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return_0;
+
+	if (!dm_task_set_major_minor(dmt, major, minor, 1))
+		goto_out;
+
+	if (!dm_task_no_flush(dmt))
+		stack;
+
+	if (!dm_task_run(dmt))
+		goto out;
+
+	if (!dm_task_get_info(dmt, &info))
+		goto out;
+
+	if (!info.exists || !info.open_count)
+		goto out; /* Not open -> not mounted */
+
+	if (!(uuid = dm_task_get_uuid(dmt)))
+		goto out;
+
+	/* Check it's public mountable LV
+	 * has prefix  LVM-  and UUID size is 68 chars */
+	if (memcmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1) ||
+	    strlen(uuid) != 68)
+		goto out;
+
+#if THIN_DEBUG
+	log_debug("Found LV (%u:%u) %s.",  major, minor, uuid);
+#endif
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 /* Get dependencies for device, and try to find matching device */
 static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_minor)
 {
@@ -90,6 +140,9 @@ static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_mino
 
 	*dev_minor = info.minor;
 
+	if (!_has_unmountable_prefix(major, info.minor))
+		goto out;
+
 #if THIN_DEBUG
 	{
 		char dev_name[PATH_MAX];
@@ -206,7 +259,7 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
 }
 
 /*
- * Find all thin pool users and try to umount them.
+ * Find all thin pool LV users and try to umount them.
  * TODO: work with read-only thin pool support
  */
 static void _umount(struct dm_task *dmt)
@@ -240,7 +293,7 @@ out:
 		dm_bitset_destroy(data.minors);
 }
 
-static void _use_policy(struct dm_task *dmt, struct dso_state *state)
+static int _use_policy(struct dm_task *dmt, struct dso_state *state)
 {
 #if THIN_DEBUG
 	log_info("dmeventd executes: %s.", state->cmd_str);
@@ -248,10 +301,12 @@ static void _use_policy(struct dm_task *dmt, struct dso_state *state)
 	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
 		log_error("Failed to extend thin pool %s.",
 			  dm_task_get_name(dmt));
-		_umount(dmt);
 		state->fails++;
-	} else
-		state->fails = 0;
+		return 0;
+	}
+
+	state->fails = 0;
+	return 1;
 }
 
 void process_event(struct dm_task *dmt,
@@ -267,6 +322,13 @@ void process_event(struct dm_task *dmt,
 	char *target_type = NULL;
 	char *params;
 	int needs_policy = 0;
+	int needs_umount = 0;
+
+#if THIN_DEBUG
+	log_debug("Watch for tp-data:%.2f%%  tp-metadata:%.2f%%.",
+		  dm_percent_to_float(state->data_percent_check),
+		  dm_percent_to_float(state->metadata_percent_check));
+#endif
 
 #if 0
 	/* No longer monitoring, waiting for remove */
@@ -275,8 +337,10 @@ void process_event(struct dm_task *dmt,
 #endif
 	if (event & DM_EVENT_DEVICE_ERROR) {
 		/* Error -> no need to check and do instant resize */
-		_use_policy(dmt, state);
-		goto out;
+		if (_use_policy(dmt, state))
+			goto out;
+
+		stack;
 	}
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
@@ -288,7 +352,7 @@ void process_event(struct dm_task *dmt,
 
 	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
 		log_error("Failed to parse status.");
-		_umount(dmt);
+		needs_umount = 1;
 		goto out;
 	}
 
@@ -323,6 +387,9 @@ void process_event(struct dm_task *dmt,
 			log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
 				 device, dm_percent_to_float(percent));
 		needs_policy = 1;
+
+		if (percent >= UMOUNT_THRESH)
+			needs_umount = 1;
 	}
 
 	percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
@@ -337,11 +404,21 @@ void process_event(struct dm_task *dmt,
 			log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
 				 device, dm_percent_to_float(percent));
 		needs_policy = 1;
+
+		if (percent >= UMOUNT_THRESH)
+			needs_umount = 1;
 	}
 
-	if (needs_policy)
-		_use_policy(dmt, state);
+	if (needs_policy &&
+	    _use_policy(dmt, state))
+		needs_umount = 0; /* No umount when command was successful */
 out:
+	if (needs_umount) {
+		_umount(dmt);
+		/* Until something changes, do not retry any more actions */
+		state->data_percent_check = state->metadata_percent_check = (DM_PERCENT_1 * 101);
+	}
+
 	if (tps)
 		dm_pool_free(state->mem, tps);
 


