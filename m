From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:17:53 -0400
Subject: stable-2.02 - mirror: fix leg splitting
Message-ID: <201910311217.x9VCHrGU010811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1be01c7ef21e80d3543b7c54a15ec2b49776c4c
Commit:        f1be01c7ef21e80d3543b7c54a15ec2b49776c4c
Parent:        8b741b3bbac6121f05caa455b31fed0983a30b64
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 11:45:28 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 12:56:24 2019 +0100

mirror: fix leg splitting

Enhance lv_info with lv_info_with_name_check.
This 'variant' not only check existance if UUID in DM table
but also compares its  DM name  whether it's matching expected LV name.
Otherwise activation may 'skip' activation with rename in case the
DM UUID already exists, just device is different name.

This change make fairly easier manipulation with i.e. detached mirror
leg which ATM is using same UUID - just the LV name have been changed.

Used code was not able to run 'activation' (and do a rename) and just
skipped the call. So the code used to do a workaround and 'tried'
to deactivate such LV firts - this however work only in non-clvmd case,
as cluster was not having the lock for deactivated LV.

With this extended lv_info code will run 'activation' and will
synchronize the name to match expected LV name.

Patch extends _lv_info() with new paramter 'with_name_check',
which is later translated into 'name_check' argument for
_info_run() which in case of name mismatch evaluates the
check as if device does not exists.

Such call is only used in one place _lv_activate() which then
let activation run.  All other invocation of _info() calls
are left intact.

TODO: fix mirror table manipulation (and raid)....
---
 lib/activate/activate.c    |   40 +++++++++++++++++++++++++---------------
 lib/activate/activate.h    |    2 ++
 lib/activate/dev_manager.c |   28 +++++++++++++++++++---------
 lib/activate/dev_manager.h |    2 +-
 4 files changed, 47 insertions(+), 25 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f17be61..fb6f545 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -658,7 +658,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		    int use_layer, struct lvinfo *info,
 		    const struct lv_segment *seg,
 		    struct lv_seg_status *seg_status,
-		    int with_open_count, int with_read_ahead)
+		    int with_open_count, int with_read_ahead, int with_name_check)
 {
 	struct dm_info dminfo;
 
@@ -678,7 +678,7 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	/* New thin-pool has no layer, but -tpool suffix needs to be queried */
 	if (!use_layer && lv_is_new_thin_pool(lv)) {
 		/* Check if there isn't existing old thin pool mapping in the table */
-		if (!dev_manager_info(cmd, lv, NULL, 0, 0, &dminfo, NULL, NULL))
+		if (!dev_manager_info(cmd, lv, NULL, 0, 0, 0, &dminfo, NULL, NULL))
 			return_0;
 		if (!dminfo.exists)
 			use_layer = 1;
@@ -691,8 +691,9 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 
 	if (!dev_manager_info(cmd, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
-			      with_open_count, with_read_ahead,
-			      &dminfo, (info) ? &info->read_ahead : NULL,
+			      with_open_count, with_read_ahead, with_name_check,
+			      &dminfo,
+			      (info) ? &info->read_ahead : NULL,
 			      seg_status))
 		return_0;
 
@@ -721,7 +722,7 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	if (!activation())
 		return 0;
 
-	return _lv_info(cmd, lv, use_layer, info, NULL, NULL, with_open_count, with_read_ahead);
+	return _lv_info(cmd, lv, use_layer, info, NULL, NULL, with_open_count, with_read_ahead, 0);
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
@@ -739,6 +740,15 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 	return r;
 }
 
+int lv_info_with_name_check(struct cmd_context *cmd, const struct logical_volume *lv,
+			    int use_layer, struct lvinfo *info)
+{
+	if (!activation())
+		return 0;
+
+	return _lv_info(cmd, lv, use_layer, info, NULL, NULL, 0, 0, 1);
+}
+
 /*
  * Returns 1 if lv_with_info_and_seg_status info structure populated,
  * else 0 on failure or if device not active locally.
@@ -766,16 +776,16 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 		 * STATUS is collected from cache LV */
 		if (!(lv_seg = get_only_segment_using_this_lv(lv)))
 			return_0;
-		(void) _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
+		(void) _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, &status->seg_status, 0, 0, 0);
 		return 1;
 	}
 
 	if (lv_is_thin_pool(lv)) {
 		/* Always collect status for '-tpool' */
-		if (_lv_info(cmd, lv, 1, &status->info, lv_seg, &status->seg_status, 0, 0) &&
+		if (_lv_info(cmd, lv, 1, &status->info, lv_seg, &status->seg_status, 0, 0, 0) &&
 		    (status->seg_status.type == SEG_STATUS_THIN_POOL)) {
 			/* There is -tpool device, but query 'active' state of 'fake' thin-pool */
-			if (!_lv_info(cmd, lv, 0, NULL, NULL, NULL, 0, 0) &&
+			if (!_lv_info(cmd, lv, 0, NULL, NULL, NULL, 0, 0, 0) &&
 			    !status->seg_status.thin_pool->needs_check)
 				status->info.exists = 0; /* So pool LV is not active */
 		}
@@ -784,10 +794,10 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 
 	if (lv_is_external_origin(lv)) {
 		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL,
-			      with_open_count, with_read_ahead))
+			      with_open_count, with_read_ahead, 0))
 			return_0;
 
-		(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
+		(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0, 0);
 		return 1;
 	}
 
@@ -800,13 +810,13 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 		/* Show INFO for actual origin and grab status for merging origin */
 		if (!_lv_info(cmd, lv, 0, &status->info, lv_seg,
 			      lv_is_merging_origin(lv) ? &status->seg_status : NULL,
-			      with_open_count, with_read_ahead))
+			      with_open_count, with_read_ahead, 0))
 			return_0;
 
 		if (status->info.exists &&
 		    (status->seg_status.type != SEG_STATUS_SNAPSHOT)) /* Not merging */
 			/* Grab STATUS from layered -real */
-			(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
+			(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0, 0);
 		return 1;
 	}
 
@@ -815,7 +825,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 			olv = origin_from_cow(lv);
 
 			if (!_lv_info(cmd, olv, 0, &status->info, first_seg(olv), &status->seg_status,
-				      with_open_count, with_read_ahead))
+				      with_open_count, with_read_ahead, 0))
 				return_0;
 
 			if (status->seg_status.type == SEG_STATUS_SNAPSHOT ||
@@ -836,7 +846,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 	}
 
 	return _lv_info(cmd, lv, 0, &status->info, lv_seg, &status->seg_status,
-			with_open_count, with_read_ahead);
+			with_open_count, with_read_ahead, 0);
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25
@@ -2821,7 +2831,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 			     laopts->noscan ? " noscan" : "",
 			     laopts->temporary ? " temporary" : "");
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0))
+	if (!lv_info_with_name_check(cmd, lv, 0, &info))
 		goto_out;
 
 	/*
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 524d2bf..7139276 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -134,6 +134,8 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	    struct lvinfo *info, int with_open_count, int with_read_ahead);
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
+int lv_info_with_name_check(struct cmd_context *cmd, const struct logical_volume *lv,
+			    int use_layer, struct lvinfo *info);
 
 /*
  * Returns 1 if lv_info_and_seg_status structure has been populated,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index becbf6d..317a2a7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -240,6 +240,7 @@ static uint32_t _seg_len(const struct lv_segment *seg)
 static int _info_run(const char *dlid, struct dm_info *dminfo,
 		     uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status,
+		     const char *name_check,
 		     int with_open_count, int with_read_ahead,
 		     uint32_t major, uint32_t minor)
 {
@@ -250,6 +251,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	void *target = NULL;
 	uint64_t target_start, target_length, start, length;
 	char *target_name, *target_params;
+	const char *dev_name;
 
 	if (seg_status) {
 		dmtask = DM_DEVICE_STATUS;
@@ -263,6 +265,11 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 				    with_open_count, with_flush, 0)))
 		return_0;
 
+	if (name_check && dminfo->exists &&
+	    (dev_name = dm_task_get_name(dmt)) &&
+	    (strcmp(name_check, dev_name) != 0))
+		dminfo->exists = 0;	/* mismatching name -> device does not exist */
+
 	if (with_read_ahead && dminfo->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
@@ -779,18 +786,19 @@ static int _original_uuid_format_check_required(struct cmd_context *cmd)
 
 static int _info(struct cmd_context *cmd,
 		 const char *name, const char *dlid,
-		 int with_open_count, int with_read_ahead,
+		 int with_open_count, int with_read_ahead, int with_name_check,
 		 struct dm_info *dminfo, uint32_t *read_ahead,
 		 struct lv_seg_status *seg_status)
 {
 	char old_style_dlid[sizeof(UUID_PREFIX) + 2 * ID_LEN];
 	const char *suffix, *suffix_position;
+	const char *name_check = (with_name_check) ? name : NULL;
 	unsigned i = 0;
 
 	log_debug_activation("Getting device info for %s [%s].", name, dlid);
 
 	/* Check for dlid */
-	if (!_info_run(dlid, dminfo, read_ahead, seg_status,
+	if (!_info_run(dlid, dminfo, read_ahead, seg_status, name_check,
 		       with_open_count, with_read_ahead, 0, 0))
 		return_0;
 
@@ -806,7 +814,8 @@ static int _info(struct cmd_context *cmd,
 			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
 			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
 			if (!_info_run(old_style_dlid, dminfo, read_ahead, seg_status,
-				       with_open_count, with_read_ahead, 0, 0))
+				       name_check, with_open_count, with_read_ahead,
+				       0, 0))
 				return_0;
 			if (dminfo->exists)
 				return 1;
@@ -819,7 +828,7 @@ static int _info(struct cmd_context *cmd,
 
 	/* Check for dlid before UUID_PREFIX was added */
 	if (!_info_run(dlid + sizeof(UUID_PREFIX) - 1, dminfo, read_ahead, seg_status,
-		       with_open_count, with_read_ahead, 0, 0))
+		       name_check, with_open_count, with_read_ahead, 0, 0))
 		return_0;
 
 	return 1;
@@ -827,12 +836,12 @@ static int _info(struct cmd_context *cmd,
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 {
-	return _info_run(NULL, info, NULL, 0, 0, 0, major, minor);
+	return _info_run(NULL, info, NULL, NULL, NULL, 0, 0, major, minor);
 }
 
 int dev_manager_info(struct cmd_context *cmd,
 		     const struct logical_volume *lv, const char *layer,
-		     int with_open_count, int with_read_ahead,
+		     int with_open_count, int with_read_ahead, int with_name_check,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status)
 {
@@ -845,7 +854,8 @@ int dev_manager_info(struct cmd_context *cmd,
 	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer)))
 		goto_out;
 
-	if (!(r = _info(cmd, name, dlid, with_open_count, with_read_ahead,
+	if (!(r = _info(cmd, name, dlid,
+			with_open_count, with_read_ahead, with_name_check,
 			dminfo, read_ahead, seg_status)))
 		stack;
 out:
@@ -1955,7 +1965,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dlid = build_dm_uuid(dm->track_pending_delete ? dm->cmd->pending_delete_mem : dm->mem, lv, layer)))
 		return_0;
 
-	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
+	if (!_info(dm->cmd, name, dlid, 1, 0, 0, &info, NULL, NULL))
 		return_0;
 
 	/*
@@ -2481,7 +2491,7 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 				      seg->lv->name, errid)))
 		return_NULL;
 
-	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
+	if (!_info(dm->cmd, name, dlid, 1, 0, 0, &info, NULL, NULL))
 		return_NULL;
 
 	if (!info.exists) {
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 5be417b..20b6a26 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -47,7 +47,7 @@ void dev_manager_exit(void);
  */
 int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		     const char *layer,
-		     int with_open_count, int with_read_ahead,
+		     int with_open_count, int with_read_ahead, int with_name_check,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status);
 


