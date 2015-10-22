From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:39 +0000 (UTC)
Subject: master - dmeventd: thin plugin update
Message-ID: <20151022213339.4867D610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa9e41d2e373e7e8017b158f60eb3e77a582f532
Commit:        fa9e41d2e373e7e8017b158f60eb3e77a582f532
Parent:        6b0bc5b2d9cc2f160b14d34e764bff99cd3c595f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 14:19:35 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:33:07 2015 +0200

dmeventd: thin plugin update

Use  dm_make_percent for percentage calculation like lvm2 command.

Use a single call for resize.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   86 ++++++++++++------------
 2 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ba22f1e..2b87e4b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Thin plugin for dmeventd improved percentage usage.
   Snapshot plugin for dmeventd improved percentage usage.
   Add dm_hold_control_dev to allow holding of control device open.
   Add dm_report_compact_given_fields to remove given empty fields from report.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 4f08d5b..888cc0c 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -28,11 +28,11 @@
 #endif
 
 /* First warning when thin data or metadata is 80% full. */
-#define WARNING_THRESH 80
+#define WARNING_THRESH	(DM_PERCENT_1 * 80)
 /* Run a check every 5%. */
-#define CHECK_STEP 5
+#define CHECK_STEP	(DM_PERCENT_1 *  5)
 /* Do not bother checking thin data or metadata is less than 50% full. */
-#define CHECK_MINIMUM 50
+#define CHECK_MINIMUM	(DM_PERCENT_1 * 50)
 
 #define UMOUNT_COMMAND "/bin/umount"
 
@@ -138,14 +138,6 @@ out:
 	return r;
 }
 
-static int _extend(struct dso_state *state)
-{
-#if THIN_DEBUG
-	log_info("dmeventd executes: %s.", state->cmd_str);
-#endif
-	return dmeventd_lvm2_run_with_lock(state->cmd_str);
-}
-
 static int _run(const char *cmd, ...)
 {
 	va_list ap;
@@ -188,9 +180,9 @@ static int _run(const char *cmd, ...)
 }
 
 struct mountinfo_s {
+	const char *device;
 	struct dm_info info;
 	dm_bitset_t minors; /* Bitset for active thin pool minors */
-	const char *device;
 };
 
 static int _umount_device(char *buffer, unsigned major, unsigned minor,
@@ -213,24 +205,24 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
  * Find all thin pool users and try to umount them.
  * TODO: work with read-only thin pool support
  */
-static void _umount(struct dm_task *dmt, const char *device)
+static void _umount(struct dm_task *dmt)
 {
 	/* TODO: Convert to use hash to reduce memory usage */
 	static const size_t MINORS = (1U << 20); /* 20 bit */
-	struct mountinfo_s data = {
-		.device = device,
-	};
+	struct mountinfo_s data = { NULL };
 
 	if (!dm_task_get_info(dmt, &data.info))
 		return;
 
+	data.device = dm_task_get_name(dmt);
+
 	if (!(data.minors = dm_bitset_create(NULL, MINORS))) {
-		log_error("Failed to allocate bitset. Not unmounting %s.", device);
+		log_error("Failed to allocate bitset. Not unmounting %s.", data.device);
 		goto out;
 	}
 
 	if (!_find_all_devs(data.minors, data.info.major, data.info.minor)) {
-		log_error("Failed to detect mounted volumes for %s.", device);
+		log_error("Failed to detect mounted volumes for %s.", data.device);
 		goto out;
 	}
 
@@ -244,6 +236,18 @@ out:
 		dm_bitset_destroy(data.minors);
 }
 
+static void _use_policy(struct dm_task *dmt, struct dso_state *state)
+{
+#if THIN_DEBUG
+	log_info("dmeventd executes: %s.", state->cmd_str);
+#endif
+	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
+		log_error("Failed to extend thin pool %s.",
+			  dm_task_get_name(dmt));
+		_umount(dmt);
+	}
+}
+
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
 		   void **user)
@@ -256,12 +260,19 @@ void process_event(struct dm_task *dmt,
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
+	int needs_policy = 0;
 
 #if 0
 	/* No longer monitoring, waiting for remove */
 	if (!state->meta_percent_check && !state->data_percent_check)
 		return;
 #endif
+	if (event & DM_EVENT_DEVICE_ERROR) {
+		/* Error -> no need to check and do instant resize */
+		_use_policy(dmt, state);
+		return;
+	}
+
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 
 	if (!target_type || (strcmp(target_type, "thin-pool") != 0)) {
@@ -271,13 +282,13 @@ void process_event(struct dm_task *dmt,
 
 	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
 		log_error("Failed to parse status.");
-		_umount(dmt, device);
+		_umount(dmt);
 		goto out;
 	}
 
 #if THIN_DEBUG
-	log_debug("%p: Got status " FMTu64 " / " FMTu64 " " FMTu64
-		  " / " FMTu64 ".", state,
+	log_debug("Thin pool status " FMTu64 "/" FMTu64 "  "
+		  FMTu64 "/" FMTu64 ".",
 		  tps->used_metadata_blocks, tps->total_metadata_blocks,
 		  tps->used_data_blocks, tps->total_data_blocks);
 #endif
@@ -293,7 +304,7 @@ void process_event(struct dm_task *dmt,
 		state->known_data_size = tps->total_data_blocks;
 	}
 
-	percent = 100 * tps->used_metadata_blocks / tps->total_metadata_blocks;
+	percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
 	if (percent >= state->metadata_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since the last
@@ -303,18 +314,12 @@ void process_event(struct dm_task *dmt,
 
 		/* FIXME: extension of metadata needs to be written! */
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			log_warn("WARNING: Thin metadata %s is now %i%% full.",
-				 device, percent);
-		 /* Try to extend the metadata, in accord with user-set policies */
-		if (!_extend(state)) {
-			log_error("Failed to extend thin metadata %s.",
-				  device);
-			_umount(dmt, device);
-		}
-		/* FIXME: hmm READ-ONLY switch should happen in error path */
+			log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
+				 device, dm_percent_to_float(percent));
+		needs_policy = 1;
 	}
 
-	percent = 100 * tps->used_data_blocks / tps->total_data_blocks;
+	percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
 	if (percent >= state->data_percent_check) {
 		/*
 		 * Usage has raised more than CHECK_STEP since
@@ -323,21 +328,16 @@ void process_event(struct dm_task *dmt,
 		state->data_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			log_warn("WARNING: Thin %s is now %i%% full.",
-				 device, percent);
-		/* Try to extend the thin data, in accord with user-set policies */
-		if (!_extend(state)) {
-			log_error("Failed to extend thin %s.", device);
-			state->data_percent_check = 0;
-			_umount(dmt, device);
-		}
-		/* FIXME: hmm READ-ONLY switch should happen in error path */
+			log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
+				 device, dm_percent_to_float(percent));
+		needs_policy = 1;
 	}
+
+	if (needs_policy)
+		_use_policy(dmt, state);
 out:
 	if (tps)
 		dm_pool_free(state->mem, tps);
-
-	dmeventd_lvm2_unlock();
 }
 
 int register_device(const char *device,


