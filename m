From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:15 +0000 (GMT)
Subject: main - activate: add get_device_list
Message-ID: <20211220151415.260353857C6D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d67bc96fd15b9f3110bdc824749805c8392b04a
Commit:        0d67bc96fd15b9f3110bdc824749805c8392b04a
Parent:        988ea0e94c79a496f2619eab878fd9db6168711d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 15 11:24:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

activate: add get_device_list

Add funtion get_device_list() to get list of active DM devices.
Handled through new dm_task_get_device_list().
---
 lib/activate/activate.c    |  9 +++++++++
 lib/activate/activate.h    |  4 ++++
 lib/activate/dev_manager.c | 29 ++++++++++++++++++++++++++++-
 lib/activate/dev_manager.h |  2 ++
 4 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9d1fe8ebe..ffb7f4b29 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -624,6 +624,15 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 				      &maj, &min, &patchlevel);
 }
 
+int get_device_list(const struct volume_group *vg, struct dm_list **devs,
+		    unsigned *devs_features)
+{
+	if (!activation())
+		return 0;
+
+	return dev_manager_get_device_list(NULL, devs, devs_features);
+}
+
 /*
  * When '*info' is NULL, returns 1 only when LV is active.
  * When '*info' != NULL, returns 1 when info structure is populated.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 6133e6d97..a276b48a7 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -106,6 +106,10 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
 		   uint32_t *min, uint32_t *patchlevel);
+
+int get_device_list(const struct volume_group *vg, struct dm_list **devs,
+		    unsigned *devs_features);
+
 int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segtype);
 int lvm_dm_prefix_check(int major, int minor, const char *prefix);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 56575fa85..16c66a341 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -138,8 +138,16 @@ static struct dm_task *_setup_task_run(int task, struct dm_info *info,
 	if (!with_flush && !dm_task_no_flush(dmt))
 		log_warn("WARNING: Failed to set no_flush.");
 
-	if (task == DM_DEVICE_TARGET_MSG)
+	switch (task) {
+	case DM_DEVICE_TARGET_MSG:
 		return dmt; /* TARGET_MSG needs more local tweaking before task_run() */
+	case DM_DEVICE_LIST:
+		if (!dm_task_set_newuuid(dmt, " ")) // new uuid has no meaning here
+			log_warn("WARNING: Failed to query uuid with LIST.");
+		break;
+	default:
+		break;
+	}
 
 	if (!dm_task_run(dmt))
 		goto_out;
@@ -922,6 +930,25 @@ int dev_manager_check_prefix_dm_major_minor(uint32_t major, uint32_t minor, cons
 	return r;
 }
 
+int dev_manager_get_device_list(const char *prefix, struct dm_list **devs, unsigned *devs_features)
+{
+	struct dm_task *dmt;
+	int r = 1;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_LIST, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0)))
+		return_0;
+
+	if (!dm_task_get_device_list(dmt, devs, devs_features)) {
+		r = 0;
+		goto_out;
+	}
+
+    out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 int dev_manager_info(struct cmd_context *cmd,
 		     const struct logical_volume *lv, const char *layer,
 		     int with_open_count, int with_read_ahead, int with_name_check,
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 27092f2b9..9980e1647 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -103,5 +103,7 @@ int dev_manager_device_uses_vg(struct device *dev,
 int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor);
 
 int dev_manager_check_prefix_dm_major_minor(uint32_t major, uint32_t minor, const char *prefix);
+int dev_manager_get_device_list(const char *prefix, struct dm_list **devs,
+				unsigned *devs_features);
 
 #endif


