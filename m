From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:22 +0000 (UTC)
Subject: master - dev_manager: use setup_task_run for mknod
Message-ID: <20161205161522.62F92602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=114f7e62854e7b62f613925881ad321c3d5f6ff3
Commit:        114f7e62854e7b62f613925881ad321c3d5f6ff3
Parent:        5163b8f697191caf13ae8192781f65b3f6335e74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 2 13:46:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:39 2016 +0100

dev_manager: use setup_task_run for mknod

Simplify info run for use only for INFO & STATUS.
Drop handling MKNODES within _info_run() call
and use more advanced _setup_task_run() directly.

This allows to further simplify _info_run().
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   36 +++++++++++++++++-------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eb64542..595b667 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Simplify internal _info_run() and use _setup_task_run() for mknod.
   Better API for internal function _setup_task_run.
   Avoid using lv_has_target_type() call within lv_info_with_seg_status.
   Simplify internal lv_info_with_seg_status API.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a90b6c0..af7f5d8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -211,10 +211,9 @@ static int _get_segment_status_from_target_params(const char *target_name,
 typedef enum {
 	INFO,	/* DM_DEVICE_INFO ioctl */
 	STATUS, /* DM_DEVICE_STATUS ioctl */
-	MKNODES
 } info_type_t;
 
-static int _info_run(info_type_t type, const char *name, const char *dlid,
+static int _info_run(info_type_t type, const char *dlid,
 		     struct dm_info *dminfo, uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status,
 		     int with_open_count, int with_read_ahead,
@@ -236,17 +235,13 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 			dmtask = DM_DEVICE_STATUS;
 			with_flush = 0;
 			break;
-		case MKNODES:
-			dmtask = DM_DEVICE_MKNODES;
-			break;
 		default:
 			log_error(INTERNAL_ERROR "_info_run: unhandled info type");
 			return 0;
 	}
 
 	if (!(dmt = _setup_task_run(dmtask, dminfo,
-				    (type == MKNODES) ? name : NULL, dlid, 0,
-				    major, minor, with_open_count, with_flush, 0)))
+				    NULL, dlid, 0, major, minor, with_open_count, with_flush, 0)))
 		return_0;
 
 	if (with_read_ahead && dminfo->exists) {
@@ -686,7 +681,7 @@ static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count,
 	unsigned i = 0;
 
 	/* Check for dlid */
-	if ((r = _info_run(seg_status ? STATUS : INFO, NULL, dlid, dminfo, read_ahead,
+	if ((r = _info_run(seg_status ? STATUS : INFO, dlid, dminfo, read_ahead,
 			   seg_status, with_open_count, with_read_ahead, 0, 0)) && dminfo->exists)
 		return 1;
 
@@ -698,7 +693,7 @@ static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count,
 
 			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
 			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
-			if ((r = _info_run(seg_status ? STATUS : INFO, NULL, old_style_dlid, dminfo,
+			if ((r = _info_run(seg_status ? STATUS : INFO, old_style_dlid, dminfo,
 					   read_ahead, seg_status, with_open_count,
 					   with_read_ahead, 0, 0)) && dminfo->exists)
 				return 1;
@@ -710,7 +705,7 @@ static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count,
 		return r;
 
 	/* Check for dlid before UUID_PREFIX was added */
-	if ((r = _info_run(seg_status ? STATUS : INFO, NULL, dlid + sizeof(UUID_PREFIX) - 1,
+	if ((r = _info_run(seg_status ? STATUS : INFO, dlid + sizeof(UUID_PREFIX) - 1,
 				dminfo, read_ahead, seg_status, with_open_count,
 				with_read_ahead, 0, 0)) && dminfo->exists)
 		return 1;
@@ -720,7 +715,7 @@ static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count,
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 {
-	return _info_run(INFO, NULL, NULL, info, NULL, 0, 0, 0, major, minor);
+	return _info_run(INFO, NULL, info, NULL, 0, 0, 0, major, minor);
 }
 
 int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
@@ -1561,21 +1556,24 @@ static int _lv_has_mknode(const struct logical_volume *lv)
 int dev_manager_mknodes(const struct logical_volume *lv)
 {
 	struct dm_info dminfo;
+	struct dm_task *dmt;
 	char *name;
 	int r = 0;
 
 	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if ((r = _info_run(MKNODES, name, NULL, &dminfo, NULL, NULL, 0, 0, 0, 0))) {
-		if (dminfo.exists) {
-			if (_lv_has_mknode(lv))
-				r = _dev_manager_lv_mknodes(lv);
-		} else
-			r = _dev_manager_lv_rmnodes(lv);
-	}
+	if (!(dmt = _setup_task_run(DM_DEVICE_MKNODES, &dminfo, name, NULL, 0, 0, 0, 0, 0, 0)))
+		return_0;
+
+	if (dminfo.exists) {
+		if (_lv_has_mknode(lv))
+			r = _dev_manager_lv_mknodes(lv);
+	} else
+		r = _dev_manager_lv_rmnodes(lv);
+
+	dm_task_destroy(dmt);
 
-	dm_pool_free(lv->vg->cmd->mem, name);
 	return r;
 }
 


