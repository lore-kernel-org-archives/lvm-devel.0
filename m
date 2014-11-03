From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:44 +0000 (UTC)
Subject: master - cleanup: add arg to _setup_task
Message-ID: <20141103132344.C8C0C60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13e6369d7f3b44b50e583e48868fb075a9f31757
Commit:        13e6369d7f3b44b50e583e48868fb075a9f31757
Parent:        cb931eed72e8618cfeefacaa3be1a4a2d5679d99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 17:22:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cleanup: add arg to _setup_task

Add init of  no_open_count into _setup_task().
Report problem as warning (cannot happen anyway).

Also drop some duplicated debug messages - we have already
printed the info about operation so make log a bit shorter.
---
 lib/activate/dev_manager.c |   67 +++++++++++--------------------------------
 1 files changed, 17 insertions(+), 50 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9956fd4..b7e496e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -74,7 +74,8 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
  */
 static struct dm_task *_setup_task(const char *name, const char *uuid,
 				   uint32_t *event_nr, int task,
-				   uint32_t major, uint32_t minor)
+				   uint32_t major, uint32_t minor,
+				   int with_open_count)
 {
 	struct dm_task *dmt;
 
@@ -95,7 +96,10 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 
 	if (activation_checks() && !dm_task_enable_checks(dmt))
 		goto_out;
-		
+
+	if (!with_open_count && !dm_task_no_open_count(dmt))
+		log_warn("WARNING: Failed to disable open_count.");
+
 	return dmt;
       out:
 	dm_task_destroy(dmt);
@@ -112,13 +116,10 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
 
-	if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor)))
+	if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor,
+				with_open_count)))
 		return_0;
 
-	if (!with_open_count &&
-	    !dm_task_no_open_count(dmt))
-		log_warn("WARNING: Failed to disable open_count.");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -586,12 +587,9 @@ static int _status_run(const char *name, const char *uuid,
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -667,13 +665,9 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0,
-				DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
 		goto_bad;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -777,12 +771,9 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	*overall_percent = percent;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))
+				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -898,12 +889,9 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -1044,7 +1032,6 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	/*
 	 * Try and get some info on this device.
 	 */
-	log_debug_activation("Getting device status percentage for %s", name);
 	if (!_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
 		      NULL, fail_if_percent_unsupported))
 		return_0;
@@ -1100,14 +1087,9 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	log_debug_activation("Getting raid device status for %s.", lv->name);
-
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count.");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -1164,12 +1146,9 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count.");
-
 	if (!dm_task_set_message(dmt, msg))
 		goto_out;
 
@@ -1199,14 +1178,9 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	log_debug_activation("Getting cache device status for %s.", lv->name);
-
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count.");
-
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -1308,14 +1282,9 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	log_debug_activation("Getting thin pool device status for %s.", lv->name);
-
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
 		return_0;
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count.");
-
 	if (noflush && !dm_task_no_flush(dmt))
 		log_warn("Can't set no_flush.");
 
@@ -1400,9 +1369,7 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	log_debug_activation("Getting device id for %s.", dlid);
-
-	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0)))
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0, 0)))
 		return_0;
 
 	if (!dm_task_run(dmt))


