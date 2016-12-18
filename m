From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:25 +0000 (UTC)
Subject: master - activate: further _info API refinement
Message-ID: <20161218185225.7C23B60E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=034931f68dec96265519af6f35ea3726ba7eec82
Commit:        034931f68dec96265519af6f35ea3726ba7eec82
Parent:        79121416dfd695900a02711e6f63146e532b825b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 14:57:16 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:38:51 2016 +0100

activate: further _info API refinement

Another cleanup of internal _info() API simplifying code.
Also make sure 'error' on _info() call is properly passed upward
(return 0 is error path).
---
 lib/activate/dev_manager.c |   88 ++++++++++++++++++++-----------------------
 1 files changed, 41 insertions(+), 47 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 520a0a1..73229b3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -214,8 +214,8 @@ typedef enum {
 	STATUS, /* DM_DEVICE_STATUS ioctl */
 } info_type_t;
 
-static int _info_run(info_type_t type, const char *dlid,
-		     struct dm_info *dminfo, uint32_t *read_ahead,
+static int _info_run(const char *dlid, struct dm_info *dminfo,
+		     uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status,
 		     int with_open_count, int with_read_ahead,
 		     uint32_t major, uint32_t minor)
@@ -223,26 +223,21 @@ static int _info_run(info_type_t type, const char *dlid,
 	int r = 0;
 	struct dm_task *dmt;
 	int dmtask;
+	int with_flush; /* TODO: arg for _info_run */
 	void *target = NULL;
 	uint64_t target_start, target_length, start, length;
 	char *target_name, *target_params;
-	int with_flush = 1; /* TODO: arg for _info_run */
 
-	switch (type) {
-		case INFO:
-			dmtask = DM_DEVICE_INFO;
-			break;
-		case STATUS:
-			dmtask = DM_DEVICE_STATUS;
-			with_flush = 0;
-			break;
-		default:
-			log_error(INTERNAL_ERROR "_info_run: unhandled info type.");
-			return 0;
+	if (seg_status) {
+		dmtask = DM_DEVICE_STATUS;
+		with_flush = 0;
+	} else {
+		dmtask = DM_DEVICE_INFO;
+		with_flush = 1; /* doesn't really matter */
 	}
 
-	if (!(dmt = _setup_task_run(dmtask, dminfo,
-				    NULL, dlid, 0, major, minor, with_open_count, with_flush, 0)))
+	if (!(dmt = _setup_task_run(dmtask, dminfo, NULL, dlid, 0, major, minor,
+				    with_open_count, with_flush, 0)))
 		return_0;
 
 	if (with_read_ahead && dminfo->exists) {
@@ -252,7 +247,7 @@ static int _info_run(info_type_t type, const char *dlid,
 		*read_ahead = DM_READ_AHEAD_NONE;
 
 	/* Query status only for active device */
-	if ((type == STATUS) && dminfo->exists) {
+	if (seg_status && dminfo->exists) {
 		start = length = seg_status->seg->lv->vg->extent_size;
 		start *= seg_status->seg->le;
 		length *= seg_status->seg->len;
@@ -674,18 +669,24 @@ static int _original_uuid_format_check_required(struct cmd_context *cmd)
 	return (_kernel_major == -1);
 }
 
-static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count, int with_read_ahead,
+static int _info(struct cmd_context *cmd,
+		 const char *name, const char *dlid,
+		 int with_open_count, int with_read_ahead,
 		 struct dm_info *dminfo, uint32_t *read_ahead,
 		 struct lv_seg_status *seg_status)
 {
-	int r = 0;
 	char old_style_dlid[sizeof(UUID_PREFIX) + 2 * ID_LEN];
 	const char *suffix, *suffix_position;
 	unsigned i = 0;
 
+	log_debug_activation("Getting device info for %s [%s].", name, dlid);
+
 	/* Check for dlid */
-	if ((r = _info_run(seg_status ? STATUS : INFO, dlid, dminfo, read_ahead,
-			   seg_status, with_open_count, with_read_ahead, 0, 0)) && dminfo->exists)
+	if (!_info_run(dlid, dminfo, read_ahead, seg_status,
+		       with_open_count, with_read_ahead, 0, 0))
+		return_0;
+
+	if (dminfo->exists)
 		return 1;
 
 	/* Check for original version of dlid before the suffixes got added in 2.02.106 */
@@ -696,33 +697,33 @@ static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count,
 
 			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
 			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
-			if ((r = _info_run(seg_status ? STATUS : INFO, old_style_dlid, dminfo,
-					   read_ahead, seg_status, with_open_count,
-					   with_read_ahead, 0, 0)) && dminfo->exists)
+			if (!_info_run(old_style_dlid, dminfo, read_ahead, seg_status,
+				       with_open_count, with_read_ahead, 0, 0))
+				return_0;
+			if (dminfo->exists)
 				return 1;
 		}
 	}
 
 	/* Must we still check for the pre-2.02.00 dm uuid format? */
 	if (!_original_uuid_format_check_required(cmd))
-		return r;
+		return 1;
 
 	/* Check for dlid before UUID_PREFIX was added */
-	if ((r = _info_run(seg_status ? STATUS : INFO, dlid + sizeof(UUID_PREFIX) - 1,
-				dminfo, read_ahead, seg_status, with_open_count,
-				with_read_ahead, 0, 0)) && dminfo->exists)
-		return 1;
+	if (!_info_run(dlid + sizeof(UUID_PREFIX) - 1, dminfo, read_ahead, seg_status,
+		       with_open_count, with_read_ahead, 0, 0))
+		return_0;
 
-	return r;
+	return 1;
 }
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 {
-	return _info_run(INFO, NULL, info, NULL, 0, 0, 0, major, minor);
+	return _info_run(NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
-int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
-		     const char *layer,
+int dev_manager_info(struct cmd_context *cmd,
+		     const struct logical_volume *lv, const char *layer,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status)
@@ -736,9 +737,9 @@ int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer)))
 		goto_out;
 
-	log_debug_activation("Getting device info for %s [%s].", name, dlid);
-	r = _info(cmd, dlid, with_open_count, with_read_ahead,
-		  dminfo, read_ahead, seg_status);
+	if (!(r = _info(cmd, name, dlid, with_open_count, with_read_ahead,
+			dminfo, read_ahead, seg_status)))
+		stack;
 out:
 	dm_pool_free(cmd->mem, name);
 
@@ -1713,12 +1714,8 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
-	log_debug_activation("Getting device info for %s [%s].", name, dlid);
-
-	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
-		log_error("Failed to get info for %s [%s].", name, dlid);
-		return 0;
-	}
+	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
+		return_0;
 
 	/*
 	 * For top level volumes verify that existing device match
@@ -2241,11 +2238,8 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 				      seg->lv->name, errid)))
 		return_NULL;
 
-	log_debug_activation("Getting device info for %s [%s].", name, dlid);
-	if (!_info(dm->cmd, dlid, 1, 0, &info, NULL, NULL)) {
-		log_error("Failed to get info for %s [%s].", name, dlid);
-		return 0;
-	}
+	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
+		return_NULL;
 
 	if (!info.exists) {
 		/* Create new node */


