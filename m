From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:03 -0400
Subject: master - dev_manager: add dev_manager_vdo_pool_status
Message-ID: <201807091335.w69DZ3bZ030738@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f708e870974fb9414ce7f1b7d277f14af6c2d38
Commit:        4f708e870974fb9414ce7f1b7d277f14af6c2d38
Parent:        493ffe7a0f4646d151bd4a48e2ec9756892c4944
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:15:54 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

dev_manager: add dev_manager_vdo_pool_status

---
 lib/activate/activate.c    |   40 +++++++++++++++++++++++++++++
 lib/activate/activate.h    |    2 +
 lib/activate/dev_manager.c |   59 ++++++++++++++++++++++++++++++++++++++++++++
 lib/activate/dev_manager.h |    5 +++
 4 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4facb7c..0435139 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1313,6 +1313,46 @@ int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
 	return r;
 }
 
+/*
+ * lv_vdo_pool_status  obtains  status information about VDO pool
+ *
+ * If the 'params' string has been already retrieved, use it.
+ * If the mempool already exists, use it.
+ *
+ */
+int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
+		       struct lv_status_vdo **vdo_status)
+{
+	int r = 0;
+	struct dev_manager *dm;
+	struct lv_status_vdo *status;
+	char *params;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+		return 0;
+
+	log_debug_activation("Checking VDO pool status for LV %s.",
+			     display_lvname(lv));
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
+		return_0;
+
+	if (!dev_manager_vdo_pool_status(dm, lv, flush, &params, &status))
+		goto_out;
+
+	if (!parse_vdo_pool_status(status->mem, lv, params, status))
+		goto_out;
+
+	/* User is responsible to dm_pool_destroy memory pool! */
+	*vdo_status = status;
+	r = 1;
+out:
+	if (!r)
+		dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 6d70f64..cca2504 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -193,6 +193,8 @@ int lv_thin_percent(const struct logical_volume *lv, int mapped,
 int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 				uint64_t *transaction_id);
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id);
+int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
+		       struct lv_status_vdo **status);
 
 /*
  * Return number of LVs in the VG that are active.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 25d5e69..43dba8c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1640,6 +1640,65 @@ out:
 	return r;
 }
 
+int dev_manager_vdo_pool_status(struct dev_manager *dm,
+				const struct logical_volume *lv,
+				int flush,
+				char **vdo_params,
+				struct lv_status_vdo **vdo_status)
+{
+	struct lv_status_vdo *status;
+	const char *dlid;
+	struct dm_info info;
+	uint64_t start, length;
+	struct dm_task *dmt = NULL;
+	char *type = NULL;
+	char *params = NULL;
+	int r = 0;
+
+	*vdo_params = NULL;
+	*vdo_status = NULL;
+
+	if (!(status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_vdo)))) {
+		log_error("Cannot allocate VDO status structure.");
+		return 0;
+	}
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+		return_0;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
+		return_0;
+
+	if (!info.exists)
+		goto_out;
+
+	if (dm_get_next_target(dmt, NULL, &start, &length, &type, &params)) {
+		log_error("More then one table line found for %s.",
+			  display_lvname(lv));
+		goto out;
+	}
+
+	if (!type || strcmp(type, TARGET_NAME_VDO)) {
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_VDO, type ? type : "NULL");
+		goto out;
+	}
+
+	if (!(*vdo_params = dm_pool_strdup(dm->mem, params))) {
+		log_error("Cannot duplicate VDO status params.");
+		goto out;
+	}
+
+	status->mem = dm->mem;
+	*vdo_status =  status;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 
 /*************************/
 /*  NEW CODE STARTS HERE */
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 809fd04..bd96832 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -79,6 +79,11 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
 			       uint32_t *device_id);
+int dev_manager_vdo_pool_status(struct dev_manager *dm,
+				const struct logical_volume *lv,
+				int flush,
+				char **vdo_params,
+				struct lv_status_vdo **vdo_status);
 int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,


