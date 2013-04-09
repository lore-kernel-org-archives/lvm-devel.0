From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 08 Apr 2013 20:47:10 -0500
Subject: [PATCH 4 of 4] LVM RAID: Add ability to report 'SyncAction' for RAID LVs
Message-ID: <1365472030.13988.7.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'lvs':  Add the ability to report the current sync action of a RAID volume

RAID arrays undergo various synchronization operations:
	- idle:   All sync operations complete (doing nothing)
	- resync: Initializing an array or recovering after a machine failure
	- recover: Replacing a device in the array
	- check: Looking for array inconsistencies
	- repair: Looking for and repairing inconsistencies
This new option to 'lvs' ('lvs -o syncaction') will display the current
sync action.

Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -187,6 +187,10 @@ int lv_raid_mismatch_count(const struct
 {
 	return 0;
 }
+int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
+{
+	return 0;
+}
 int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
@@ -855,6 +859,40 @@ int lv_raid_mismatch_count(const struct
 
 	dev_manager_destroy(dm);
 
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
 	return 1;
 }
 
Index: lvm2/lib/activate/activate.h
===================================================================
--- lvm2.orig/lib/activate/activate.h
+++ lvm2/lib/activate/activate.h
@@ -118,6 +118,7 @@ int lv_mirror_percent(struct cmd_context
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
+int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
Index: lvm2/lib/report/columns.h
===================================================================
--- lvm2.orig/lib/report/columns.h
+++ lvm2/lib/report/columns.h
@@ -81,6 +81,7 @@ FIELD(LVS, lv, NUM, "Meta%", lvid, 6, me
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
+FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -936,6 +936,24 @@ no_copypercent:
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
 static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
 				struct dm_pool *mem,
 				struct dm_report_field *field,
Index: lvm2/man/lvs.8.in
===================================================================
--- lvm2.orig/man/lvs.8.in
+++ lvm2/man/lvs.8.in
@@ -114,6 +114,7 @@ seg_tags,
 snap_percent,
 stripes,
 stripe_size,
+sync_action,
 sync_percent,
 thin_count,
 transaction_id,
Index: lvm2/lib/report/properties.c
===================================================================
--- lvm2.orig/lib/report/properties.c
+++ lvm2/lib/report/properties.c
@@ -101,6 +101,14 @@ static uint64_t _mismatches(const struct
 	return cnt;
 }
 
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
 
@@ -205,6 +213,8 @@ GET_LV_NUM_PROPERTY_FN(sync_percent, _co
 #define _sync_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
 #define _mismatches_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
+#define _syncaction_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))



