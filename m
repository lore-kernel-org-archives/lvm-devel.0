From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:56:17 -0500
Subject: master - vdo: minor API cleanup
Message-ID: <201901211156.x0LBuH17024931@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e689bfb5d5a9983205efbccf1e554fde52a0376a
Commit:        e689bfb5d5a9983205efbccf1e554fde52a0376a
Parent:        fc02343eff39b80e3b41b74475d9f2d6797062ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 21 00:48:05 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: minor API cleanup

Since the parse_vdo_pool_status() become vdo_manip API part,
and there will be no 'dm' matching status parser,
the API can be simplified and closely match thin API here.
---
 lib/activate/activate.c    |   10 ++--------
 lib/activate/dev_manager.c |   14 +++++---------
 lib/activate/dev_manager.h |    5 ++---
 3 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 072e84e..ddc175c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1359,8 +1359,6 @@ int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 {
 	int r = 0;
 	struct dev_manager *dm;
-	struct lv_status_vdo *status;
-	char *params;
 
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
@@ -1371,14 +1369,10 @@ int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
 		return_0;
 
-	if (!dev_manager_vdo_pool_status(dm, lv, flush, &params, &status))
+	if (!dev_manager_vdo_pool_status(dm, lv, vdo_status, flush))
 		goto_out;
 
-	if (!parse_vdo_pool_status(status->mem, lv, params, status))
-		goto_out;
-
-	/* User is responsible to dm_pool_destroy memory pool! */
-	*vdo_status = status;
+	/* User has to call dm_pool_destroy(vdo_status->mem) */
 	r = 1;
 out:
 	if (!r)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f0c5254..dc570c7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1792,9 +1792,8 @@ out:
 
 int dev_manager_vdo_pool_status(struct dev_manager *dm,
 				const struct logical_volume *lv,
-				int flush,
-				char **vdo_params,
-				struct lv_status_vdo **vdo_status)
+				struct lv_status_vdo **vdo_status,
+				int flush)
 {
 	struct lv_status_vdo *status;
 	const char *dlid;
@@ -1805,7 +1804,6 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 	char *params = NULL;
 	int r = 0;
 
-	*vdo_params = NULL;
 	*vdo_status = NULL;
 
 	if (!(status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_vdo)))) {
@@ -1834,13 +1832,11 @@ int dev_manager_vdo_pool_status(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (!(*vdo_params = dm_pool_strdup(dm->mem, params))) {
-		log_error("Cannot duplicate VDO status params.");
-		goto out;
-	}
+	if (!parse_vdo_pool_status(dm->mem, lv, params, status))
+		goto_out;
 
 	status->mem = dm->mem;
-	*vdo_status =  status;
+	*vdo_status = status;
 
 	r = 1;
 out:
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index ca8c0d3..6456991 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -84,9 +84,8 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 			       uint32_t *device_id);
 int dev_manager_vdo_pool_status(struct dev_manager *dm,
 				const struct logical_volume *lv,
-				int flush,
-				char **vdo_params,
-				struct lv_status_vdo **vdo_status);
+				struct lv_status_vdo **vdo_status,
+				int flush);
 int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,


