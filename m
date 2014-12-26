From: David Taylor <davidt-lvm2@yadt.co.uk>
Date: Fri, 26 Dec 2014 20:06:33 +0100
Subject: [PATCH 1/2] Add readonly parameter to liblvm2app lvm_lv_snapshot()
In-Reply-To: <1419620794-29008-1-git-send-email-davidt-lvm2@yadt.co.uk>
References: <1419620794-29008-1-git-send-email-davidt-lvm2@yadt.co.uk>
Message-ID: <1419620794-29008-2-git-send-email-davidt-lvm2@yadt.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This adds a 'readonly' parameter to lvm_lv_snapshot() to allow
read-only snapshots to be created using liblvm2app.
---
 liblvm/lvm2app.h | 11 +++++++++--
 liblvm/lvm_lv.c  | 17 ++++++++++++-----
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 3692f9a..034e479 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1555,11 +1555,14 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
  * Max snapshot space to use. If you pass zero the same amount of space as
  * the origin will be used.
  *
+ * \param   readonly
+ * If non-zero a read-only snapshot will be created.
+ *
  * \return
  * Valid lv pointer on success, else NULL on error.
  *
  */
-lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
+lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size, int readonly);
 
 /**
  * Validate a name to be used for LV creation.
@@ -1638,6 +1641,9 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
  * \param	max_snap_size
  * Used for old snap shots max size, set to zero for thinp
  *
+ * \param	readonly
+ * Read-only snapshot.
+ *
  * \return
  * Valid lv_create_params pointer on success, else NULL on error.
  * Note: Memory is associated with the vg, it will get reclaimed when vg is
@@ -1645,7 +1651,8 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
  */
 lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
 													const char *snap_name,
-													uint64_t max_snap_size);
+													uint64_t max_snap_size,
+													int readonly);
 /**
  * Get the specific value of a lv create parameter by name
  *
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 33af348..e6b4664 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -479,13 +479,14 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
-						uint64_t max_snap_size)
+						uint64_t max_snap_size,
+						int readonly)
 {
 	lv_t rc = NULL;
 	struct lvm_lv_create_params *lvcp = NULL;
 	struct saved_env e = store_user_env(lv->vg->cmd);
 
-	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
+	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size, readonly);
 	if (lvcp) {
 		rc = lvm_lv_create(lvcp);
 	}
@@ -620,7 +621,8 @@ static int _lv_set_thin_params(struct lvcreate_params *lp,
 
 static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 							 const char *snap_name,
-							 uint64_t max_snap_size)
+							 uint64_t max_snap_size,
+							 int readonly)
 {
 	uint64_t size = 0;
 	uint64_t extents = 0;
@@ -654,6 +656,10 @@ static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 		lvcp->vg = lv->vg;
 		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
 
+		if (readonly) {
+			lvcp->lvp.permission = LVM_READ;
+		}
+
 		if (size) {
 			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "snapshot"))) {
 				log_error("Segtype snapshot not found.");
@@ -681,11 +687,12 @@ static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 
 lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
 						 const char *snap_name,
-						 uint64_t max_snap_size)
+						 uint64_t max_snap_size,
+						 int readonly)
 {
 	lv_create_params_t rc;
 	struct saved_env e = store_user_env(lv->vg->cmd);
-	rc = _lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
+	rc = _lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size, readonly);
 	restore_user_env(&e);
 	return rc;
 }
-- 
2.1.4


