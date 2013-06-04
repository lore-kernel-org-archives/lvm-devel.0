From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:37 +0000 (UTC)
Subject: dev-mornfall-activate - RAID: Add scrubbing support for RAID LVs
Message-ID: <20130604192337.D25C861188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff64e3500f6acf93dce017388445c4828111d06f
Commit:        ff64e3500f6acf93dce017388445c4828111d06f
Parent:        e7ccad2ef0e813f6ca42ab5090e76aa5bee05912
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Apr 11 15:33:59 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Apr 11 15:33:59 2013 -0500

RAID:  Add scrubbing support for RAID LVs

New options to 'lvchange' allow users to scrub their RAID LVs.
Synopsis:
	lvchange --syncaction {check|repair} vg/raid_lv

RAID scrubbing is the process of reading all the data and parity blocks in
an array and checking to see whether they are coherent.  'lvchange' can
now initaite the two scrubbing operations: "check" and "repair".  "check"
will go over the array and recored the number of discrepancies but not
repair them.  "repair" will correct the discrepancies as it finds them.

'lvchange --syncaction repair vg/raid_lv' is not to be confused with
'lvconvert --repair vg/raid_lv'.  The former initiates a background
synchronization operation on the array, while the latter is designed to
repair/replace failed devices in a mirror or RAID logical volume.

Additional reporting has been added for 'lvs' to support the new
operations.  Two new printable fields (which are not printed by
default) have been added: "syncaction" and "mismatches".  These
can be accessed using the '-o' option to 'lvs', like:
	lvs -o +syncaction,mismatches vg/lv
"syncaction" will print the current synchronization operation that the
RAID volume is performing.  It can be one of the following:
        - idle:   All sync operations complete (doing nothing)
        - resync: Initializing an array or recovering after a machine failure
        - recover: Replacing a device in the array
        - check: Looking for array inconsistencies
        - repair: Looking for and repairing inconsistencies
The "mismatches" field with print the number of descrepancies found during
a check or repair operation.

The 'Cpy%Sync' field already available to 'lvs' will print the progress
of any of the above syncactions, including check and repair.

Finally, the lv_attr field has changed to accomadate the scrubbing operations
as well.  The role of the 'p'artial character in the lv_attr report field
as expanded.  "Partial" is really an indicator for the health of a
logical volume and it makes sense to extend this include other health
indicators as well, specifically:
        'm'ismatches:  Indicates that there are discrepancies in a RAID
                       LV.  This character is shown after a scrubbing
                       operation has detected that portions of the RAID
                       are not coherent.
        'r'efresh   :  Indicates that a device in a RAID array has suffered
                       a failure and the kernel regards it as failed -
                       even though LVM can read the device label and
                       considers the device to be ok.  The LV should be
                       'r'efreshed to notify the kernel that the device is
                       now available, or the device should be 'r'eplaced
                       if it is suspected of failing.
---
 WHATS_NEW                   |    1 +
 lib/activate/activate.c     |  133 +++++++++++++++++++++++++++++++++++++++-
 lib/activate/activate.h     |    3 +
 lib/activate/dev_manager.c  |   49 +++++++++++++++
 lib/activate/dev_manager.h  |    3 +
 lib/metadata/lv.c           |   14 +++-
 lib/report/columns.h        |    2 +
 lib/report/properties.c     |   20 ++++++
 lib/report/report.c         |   36 +++++++++++
 man/lvchange.8.in           |   14 ++++
 man/lvs.8.in                |   16 ++++-
 test/shell/lvchange-raid.sh |  145 +++++++++++++++++++++++++++++++++++++++++++
 tools/args.h                |    1 +
 tools/commands.h            |    5 +-
 tools/lvchange.c            |   39 +++++++++---
 15 files changed, 463 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c41dd04..43c39d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  New lvchange arg, '--syncaction' allows scrubbing of RAID LVs.
   Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
   Add external origin support for lvcreate.
   Improve lvcreate, lvconvert and lvm man pages.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 572383f..b3439ad 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -183,6 +183,18 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 {
 	return 0;
 }
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
+{
+	return 0;
+}
+int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
+{
+	return 0;
+}
+int lv_raid_message(const struct logical_volume *lv, const char *msg)
+{
+	return 0;
+}
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent)
 {
@@ -796,7 +808,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	*dev_health = NULL;
 
 	if (!activation())
-		return 0;
+		return_0;
 
 	log_debug_activation("Checking raid device health for LV %s/%s",
 			     lv->vg->name, lv->name);
@@ -820,6 +832,125 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	return r;
 }
 
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
+{
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+
+	*cnt = 0;
+
+	if (!activation())
+		return 0;
+
+	log_debug_activation("Checking raid mismatch count for LV %s/%s",
+			     lv->vg->name, lv->name);
+
+	if (!lv_is_active(lv))
+		return_0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_raid_status(dm, lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+	*cnt = status->mismatch_count;
+
+	dev_manager_destroy(dm);
+
+	return 1;
+}
+
+int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
+{
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+	char *action;
+
+	*sync_action = NULL;
+
+	if (!activation())
+		return 0;
+
+	log_debug_activation("Checking raid sync_action for LV %s/%s",
+			     lv->vg->name, lv->name);
+
+	if (!lv_is_active(lv))
+		return_0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_raid_status(dm, lv, &status) ||
+	    !(action = dm_pool_strdup(lv->vg->cmd->mem,
+				      status->sync_action))) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+
+	*sync_action = action;
+
+	dev_manager_destroy(dm);
+
+	return 1;
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
+}
+
 /*
  * Returns data or metadata percent usage, depends on metadata 0/1.
  * Returns 1 if percent set, else 0 on failure.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index bf1f7a0..f7c312f 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -117,6 +117,9 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
+int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
+int lv_raid_message(const struct logical_volume *lv, const char *msg);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4a77320..8c06476 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
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
 
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index a4556e7..ecf3c5f 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -57,6 +57,9 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 int dev_manager_raid_status(struct dev_manager *dm,
 			    const struct logical_volume *lv,
 			    struct dm_status_raid **status);
+int dev_manager_raid_message(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     const char *msg);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f1c79be..5cb87c3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -597,11 +597,17 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else
 		repstr[7] = '-';
 
-	if (lv->status & PARTIAL_LV ||
-	    (lv_is_raid_type(lv) && !_lv_raid_healthy(lv)))
+	repstr[8] = '-';
+	if (lv->status & PARTIAL_LV)
 		repstr[8] = 'p';
-	else
-		repstr[8] = '-';
+	else if (lv_is_raid_type(lv)) {
+		uint64_t n;
+		if (!_lv_raid_healthy(lv))
+			repstr[8] = 'r';  /* RAID needs 'r'efresh */
+		else if ((lv->status & RAID) &&
+			 lv_raid_mismatch_count(lv, &n) && n)
+			repstr[8] = 'm';  /* RAID contains 'm'ismatches */
+	}
 
 out:
 	return repstr;
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 23d3e11..b6dc483 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -80,6 +80,8 @@ FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, t
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
+FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 08443d4..c04a6a1 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -93,6 +93,22 @@ static percent_t _copy_percent(const struct logical_volume *lv) {
 	return perc;
 }
 
+static uint64_t _mismatches(const struct logical_volume *lv) {
+	uint64_t cnt;
+
+	if (!lv_raid_mismatch_count(lv, &cnt))
+		return 0;
+	return cnt;
+}
+
+static char *_sync_action(const struct logical_volume *lv) {
+	char *action;
+
+	if (!lv_raid_sync_action(lv, &action))
+		return 0;
+	return action;
+}
+
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
 
@@ -195,6 +211,10 @@ GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
 #define _copy_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
 #define _sync_percent_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
+#define _mismatches_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
+#define _syncaction_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 633dfe4..4b0ebef 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -936,6 +936,42 @@ no_copypercent:
 	return 1;
 }
 
+static int _sync_action_disp(struct dm_report *rh __attribute__((unused)),
+			     struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data,
+			     void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *sync_action;
+
+	if (!(lv->status & RAID) ||
+	    !lv_raid_sync_action(lv, &sync_action)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return _string_disp(rh, mem, field, &sync_action, private);
+}
+
+static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
+				struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data,
+				void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t mismatch_count;
+
+	if (!(lv->status & RAID) ||
+	    !lv_raid_mismatch_count(lv, &mismatch_count)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return  dm_report_field_uint64(rh, field, &mismatch_count);
+}
+
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
 			   struct dm_pool *mem,
 			   struct dm_report_field *field,
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 32a0580..295eea2 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -26,6 +26,8 @@ lvchange \- change attributes of a logical volume
 .RI { y | n }]
 .RB [ \-\-poll
 .RI { y | n }]
+.RB [ \-\-syncaction
+.RI { check | repair }]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-M | \-\-persistent
@@ -107,6 +109,18 @@ process from its last checkpoint.  However, it may not be appropriate to
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
diff --git a/man/lvs.8.in b/man/lvs.8.in
index d4d77b0..727353b 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -97,6 +97,7 @@ lv_time,
 lv_uuid,
 metadata_lv,
 mirror_log,
+mismatches,
 modules,
 move_pv,
 origin,
@@ -113,6 +114,7 @@ seg_tags,
 snap_percent,
 stripes,
 stripe_size,
+sync_action,
 sync_percent,
 thin_count,
 transaction_id,
@@ -159,8 +161,18 @@ snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-(p)artial: One or more of the Physical Volumes this Logical Volume uses is
-missing from the system.
+Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist.
+(p)artial signifies that one or more of the Physical Volumes this Logical
+Volume uses is missing from the system.  (r)efresh signifies that one or
+more of the Physical Volumes this RAID Logical Volume uses had suffered a
+write error.  The write error could be due to a temporary failure of that
+Physical Volume or an indication that it is failing.  The device should be
+refreshed or replaced.  (m)ismatches signifies that the RAID logical volume
+has portions of the array that are not coherent or that the array has
+recently repaired inconsistencies.  An additional "check" after a "repair"
+of a RAID logical volume will clear this flag if no additional discrepancies
+are found.  ("check" and "repair" of a RAID Logical Volume can be done via
+the 'lvchange' command.)
 .RE
 .TP
 .BR \-O ", " \-\-sort
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
new file mode 100644
index 0000000..a1c9540
--- /dev/null
+++ b/test/shell/lvchange-raid.sh
@@ -0,0 +1,145 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# This test ensures that 'lvchange --refresh vg/raid_lv' properly restores
+# a transiently failed device in RAID LVs.
+
+. lib/test
+
+# dm-raid v1.5.0+ contains RAID scrubbing support
+aux target_at_least dm-raid 1 5 0 || skip
+
+aux prepare_vg 5
+
+# run_syncaction_check <VG> <LV>
+run_syncaction_check() {
+	local device
+	local seek
+	local size
+
+	aux wait_for_sync $1 $2
+
+	device=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
+	device=$(sed s/^[[:space:]]*// <<< "$device")
+	size=`lvs -a --noheadings -o size --units 1k $1/$2 | sed s/\.00k//`
+	size=$(sed s/^[[:space:]]*// <<< "$size")
+	size=$(($size / 2))
+	seek=`pvs --noheadings -o mda_size --units 1k $device | sed s/\.00k//`
+	seek=$(sed s/^[[:space:]]*// <<< "$seek")
+	seek=$(($size + $seek))
+
+	# Check all is normal
+	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-$' ||
+		[ `lvs --noheadings -o mismatches $1/$2` != 0 ]; then
+		#
+		# I think this is a kernel bug.  It happens randomly after
+		# a RAID device creation.  I think the mismatch count
+		# should not be set unless a check or repair is run.
+		#
+		echo "Strange... RAID has mismatch count after creation."
+
+		# Run "check" should turn up clean
+		lvchange --syncaction check $1/$2
+	fi
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
+
+	# Overwrite the last half of one of the PVs with crap
+	dd if=/dev/urandom of=$device bs=1k count=$size seek=$seek
+
+	# FIXME: Why is this necessary?  caching effects?
+	# I don't need to do this when testing "real" devices...
+	lvchange -an $1/$2; lvchange -ay $1/$2
+
+	# "check" should find discrepancies but not change them
+	# 'lvs' should show results
+	lvchange --syncaction check $1/$2
+	aux wait_for_sync $1 $2
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*m$'
+	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
+
+	# "repair" will fix discrepancies and record number fixed
+	lvchange --syncaction repair $1/$2
+	aux wait_for_sync $1 $2
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*m$'
+	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
+
+	# Final "check" should show no mismatches
+	# 'lvs' should show results
+	lvchange --syncaction check $1/$2
+	aux wait_for_sync $1 $2
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
+}
+
+# run_refresh_check <VG> <LV>
+#   Assumes "$dev2" is in the array
+run_refresh_check() {
+	aux wait_for_sync $1 $2
+
+	# Disable dev2 and do some I/O to make the kernel notice
+	aux disable_dev "$dev2"
+	dd if=/dev/urandom of=/dev/$1/$2 bs=4M count=1
+
+	# Check for 'p'artial flag
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*p$'
+
+	aux enable_dev "$dev2"
+
+	# Check for 'r'efresh flag
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*r$'
+
+	lvchange --refresh $1/$2
+
+	# Writing random data above should mean that the devices
+	# were out-of-sync.  The refresh should have taken care
+	# of properly reintegrating the device.  If any mismatches
+	# are repaired, it will show up in the 'lvs' output.
+	lvchange --syncaction repair $1/$2
+	aux wait_for_sync $1 $2
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
+}
+
+run_checks() {
+	if aux target_at_least dm-raid 1 5 0; then
+		run_syncaction_check $1 $2
+	fi
+
+	if aux target_at_least dm-raid 1 5 1; then
+		run_refresh_check $1 $2
+	fi
+}
+
+########################################################
+# MAIN
+########################################################
+
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg "$dev1" "$dev2"
+run_checks $vg $lv1
+lvremove -ff $vg
+
+lvcreate --type raid4 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+run_checks $vg $lv1
+lvremove -ff $vg
+
+lvcreate --type raid5 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+run_checks $vg $lv1
+lvremove -ff $vg
+
+lvcreate --type raid6 -i 3 -l 6 -n $lv1 $vg \
+		"$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+run_checks $vg $lv1
+lvremove -ff $vg
+
+lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg \
+		"$dev1" "$dev2" "$dev3" "$dev4"
+run_checks $vg $lv1
+lvremove -ff $vg
diff --git a/tools/args.h b/tools/args.h
index 49ddcd2..81793a5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -86,6 +86,7 @@ arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
 arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
+arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 9aed9e7..3124a13 100644
--- a/tools/commands.h
+++ b/tools/commands.h
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
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 67db083..e19e2e7 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -261,13 +261,6 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
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
@@ -328,8 +321,28 @@ static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
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
@@ -898,6 +911,13 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
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
@@ -956,6 +976,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, syncaction_ARG) ||
 		arg_count(cmd, zero_ARG);
 	int update = update_partial_safe || update_partial_unsafe;
 


