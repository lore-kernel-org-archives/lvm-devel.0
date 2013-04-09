From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 08 Apr 2013 20:42:05 -0500
Subject: [PATCH 1 of 4] LVM RAID: Add ability to scrub RAID LVs
Message-ID: <1365471725.13988.1.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID: Implement the LVM interface to the dm-raid sync actions for scrubbing

New operations:
	lvchange --syncaction {check|repair) vg/raid_lv

RAID scrubbing is the process of reading all the data and parity blocks in
an array and checking to see whether they are coherent.  'lvchange' can
now initaite the two scrubbing operations: "check" and "repair".  "check"
will go over the array and recored the number of discrepancies but not
repair them.  "repair" will correct the discrepancies as it finds them.

'lvchange --syncaction repair vg/raid_lv' is not to be confused with
'lvconvert --repair vg/raid_lv'.  The former initiates a background
synchronization operation on the array, while the latter is designed to
repair/replace failed devices in a mirror or RAID logical volume.

Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -1066,6 +1066,55 @@ out:
 	return r;
 }
 
+int dev_manager_raid_message(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     const char *msg)
+{
+	int r = 0;
+	const char *dlid;
+	struct dm_task *dmt;
+	const char *layer = lv_layer(lv);
+
+	if (!(lv->status & RAID)) {
+		log_error(INTERNAL_ERROR "%s/%s is not a RAID logical volume",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/* These are the supported RAID messages for dm-raid v1.5.0 */
+	if (!strcmp(msg, "idle") &&
+	    !strcmp(msg, "frozen") &&
+	    !strcmp(msg, "resync") &&
+	    !strcmp(msg, "recover") &&
+	    !strcmp(msg, "check") &&
+	    !strcmp(msg, "repair") &&
+	    !strcmp(msg, "reshape")) {
+		log_error("Unknown RAID message: %s", msg);
+		return 0;
+	}
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+		return_0;
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count.");
+
+	if (!dm_task_set_message(dmt, msg))
+		goto_out;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 #if 0
 	log_very_verbose("%s %s", sus ? "Suspending" : "Resuming", name);
 
Index: lvm2/man/lvchange.8.in
===================================================================
--- lvm2.orig/man/lvchange.8.in
+++ lvm2/man/lvchange.8.in
@@ -26,6 +26,8 @@ lvchange \- change attributes of a logic
 .RI { y | n }]
 .RB [ \-\-poll
 .RI { y | n }]
+.RB [ \-\-syncaction
+.RI { check | repair }]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-M | \-\-persistent
@@ -107,6 +109,18 @@ process from its last checkpoint.  Howev
 immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
+.BR \-\-syncaction " {" \fIcheck | \fIrepair }
+This argument is used to initiate various RAID synchronization operations.
+The \fIcheck\fP and \fIrepair\fP options provide a way to check the
+integrity of a RAID logical volume (often referred to as "scrubbing").
+These options cause the RAID logical volume to
+read all of the data and parity blocks in the array and check for any
+discrepancies (e.g. mismatches between mirrors or incorrect parity values).
+If \fIcheck\fP is used, the discrepancies will be counted but not repaired.
+If \fIrepair\fP is used, the discrepancies will be corrected as they are
+encountered.  The 'lvs' command can be used to show the number of
+discrepancies found or repaired.
+.TP
 .B \-\-sysinit
 Indicates that \fBlvchange\fP(8) is being invoked from early system
 initialisation scripts (e.g. rc.sysinit or an initrd),
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -86,6 +86,7 @@ arg(ignoreadvanced_ARG, '\0', "ignoreadv
 arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
+arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
@@ -90,6 +90,7 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--syncaction {check|repair}\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -102,8 +103,8 @@ xx(lvchange,
    discards_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
-   refresh_ARG, addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG,
-   zero_ARG)
+   refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
+   yes_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -261,13 +261,6 @@ static int _lvchange_activate(struct cmd
 	return 1;
 }
 
-static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
-
-	return lv_refresh(cmd, lv);
-}
-
 static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
 	uint32_t s;
@@ -328,8 +321,28 @@ static int attach_metadata_devices(struc
 	return 1;
 }
 
-static int lvchange_resync(struct cmd_context *cmd,
-			      struct logical_volume *lv)
+/*
+ * lvchange_refresh
+ * @cmd
+ * @lv
+ *
+ * Suspend and resume a logical volume.
+ */
+static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
+
+	return lv_refresh(cmd, lv);
+}
+
+/*
+ * lvchange_resync
+ * @cmd
+ * @lv
+ *
+ * Force a mirror or RAID array to undergo a complete initializing resync.
+ */
+static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int active = 0;
 	int monitored;
@@ -898,6 +911,13 @@ static int lvchange_single(struct cmd_co
 			return ECMD_FAILED;
 		}
 
+	if (arg_count(cmd, syncaction_ARG)) {
+		if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL))) {
+			stack;
+			return ECMD_FAILED;
+		}
+	}
+
 	/* activation change */
 	if (arg_count(cmd, activate_ARG)) {
 		if (!_lvchange_activate(cmd, lv)) {
@@ -956,6 +976,7 @@ int lvchange(struct cmd_context *cmd, in
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, syncaction_ARG) ||
 		arg_count(cmd, zero_ARG);
 	int update = update_partial_safe || update_partial_unsafe;
 
Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -183,6 +183,10 @@ int lv_raid_dev_health(const struct logi
 {
 	return 0;
 }
+int lv_raid_message(const struct logical_volume *lv, const char *msg)
+{
+	return 0;
+}
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent)
 {
@@ -818,6 +822,61 @@ int lv_raid_dev_health(const struct logi
 	dev_manager_destroy(dm);
 
 	return r;
+}
+
+int lv_raid_message(const struct logical_volume *lv, const char *msg)
+{
+	int r = 0;
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+
+	if (!lv_is_active(lv)) {
+		log_error("Unable to send message to an inactive logical volume.");
+		return 0;
+	}
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
+		log_error("Failed to retrieve status of %s/%s",
+			  lv->vg->name, lv->name);
+		goto out;
+	}
+
+	if (!status->sync_action) {
+		log_error("Kernel driver does not support this action: %s", msg);
+		goto out;
+	}
+
+	/*
+	 * Note that 'dev_manager_raid_message' allows us to pass down any
+	 * currently valid message.  However, this function restricts the
+	 * number of user available combinations to a minimum.  Specifically,
+	 *     "idle" -> "check"
+	 *     "idle" -> "repair"
+	 * (The state automatically switches to "idle" when a sync process is
+	 * complete.)
+	 */
+	if (strcmp(msg, "check") && strcmp(msg, "repair")) {
+		/*
+		 * MD allows "frozen" to operate in a toggling fashion.
+		 * We could allow this if we like...
+		 */
+		log_error("\"%s\" is not a supported sync operation.", msg);
+		goto out;
+	}
+	if (strcmp(status->sync_action, "idle")) {
+		log_error("%s/%s state is currently \"%s\".  Unable to switch to \"%s\".",
+			  lv->vg->name, lv->name, status->sync_action, msg);
+		goto out;
+	}
+
+	r = dev_manager_raid_message(dm, lv, msg);
+out:
+	dev_manager_destroy(dm);
+
+	return r;
 }
 
 /*
Index: lvm2/lib/activate/activate.h
===================================================================
--- lvm2.orig/lib/activate/activate.h
+++ lvm2/lib/activate/activate.h
@@ -117,6 +117,7 @@ int lv_mirror_percent(struct cmd_context
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
+int lv_raid_message(const struct logical_volume *lv, const char *msg);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
Index: lvm2/lib/activate/dev_manager.h
===================================================================
--- lvm2.orig/lib/activate/dev_manager.h
+++ lvm2/lib/activate/dev_manager.h
@@ -57,6 +57,9 @@ int dev_manager_mirror_percent(struct de
 int dev_manager_raid_status(struct dev_manager *dm,
 			    const struct logical_volume *lv,
 			    struct dm_status_raid **status);
+int dev_manager_raid_message(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     const char *msg);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,



