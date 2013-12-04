From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:37 +0000 (UTC)
Subject: master - thin: read table line with thin device id
Message-ID: <20131204133137.936A260EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=572983d7931eac9347dad79b7d9b13f640bfaeaf
Commit:        572983d7931eac9347dad79b7d9b13f640bfaeaf
Parent:        cf7f4512384bac494fd352762f685377e2f10034
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 13:57:27 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

thin: read table line with thin device id

Add functions to parse thin table line to
obtain thin device id.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   22 +++++++++++++++++++
 lib/activate/activate.h    |    1 +
 lib/activate/dev_manager.c |   50 ++++++++++++++++++++++++++++++++++++++++++++
 lib/activate/dev_manager.h |    3 ++
 5 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cba7c8f..c81cb7a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add support to read thin device id from table line entry.
   Drop extra test for origin when testing merging origin in lv_refresh().
   Extend lv_remove_single() to not print info about removed LV.
   Replace open_count check with lv_check_not_in_use() for snapshot open test.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f75f1cf..80eef32 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1051,6 +1051,28 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	return r;
 }
 
+int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!activation())
+		return 0;
+
+	log_debug_activation("Checking device id for LV %s/%s",
+			     lv->vg->name, lv->name);
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_thin_device_id(dm, lv, device_id)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index df888cd..1881f75 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -140,6 +140,7 @@ int lv_thin_percent(const struct logical_volume *lv, int mapped,
 		    percent_t *percent);
 int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 				uint64_t *transaction_id);
+int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id);
 
 /*
  * Return number of LVs in the VG that are active.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index bed4d60..24574ec 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1313,6 +1313,56 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 	return 1;
 }
 
+int dev_manager_thin_device_id(struct dev_manager *dm,
+			       const struct logical_volume *lv,
+			       uint32_t *device_id)
+{
+	const char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	uint64_t start, length;
+	char *params, *target_type = NULL;
+	int r = 0;
+
+	/* Build dlid for the thin layer */
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+		return_0;
+
+	log_debug_activation("Getting device id for %s.", dlid);
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0)))
+		return_0;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	if (dm_get_next_target(dmt, NULL, &start, &length,
+			       &target_type, &params)) {
+		log_error("More then one table line found for %s.", lv->name);
+		goto out;
+	}
+
+	if (strcmp(target_type, "thin")) {
+		log_error("Unexpected target type %s found for thin %s.", target_type, lv->name);
+		goto out;
+	}
+
+	if (sscanf(params, "%*u:%*u %u", device_id) != 1) {
+		log_error("Cannot parse table like parameters %s for %s.", params, lv->name);
+		goto out;
+	}
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+
 /*************************/
 /*  NEW CODE STARTS HERE */
 /*************************/
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index ecf3c5f..032766e 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -70,6 +70,9 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 int dev_manager_thin_percent(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     int mapped, percent_t *percent);
+int dev_manager_thin_device_id(struct dev_manager *dm,
+			       const struct logical_volume *lv,
+			       uint32_t *device_id);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,


