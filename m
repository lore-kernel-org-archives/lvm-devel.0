From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 17 Dec 2013 17:01:55 -0600
Subject: [PATCH] liblvm: Save off and restore umask values
Message-ID: <1387321315-11680-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm has a default umask value in the config file that defaults
to 0077 which lvm changes to during normal operation.  This
causes a problem when the code is used as a library with
liblvm as it is changing the umask for the process.  This
patch saves off the current umask, sets to what is specified
in the config file and restores it what it was on library
function call exit.

The user is now free to change the umask in their application at
anytime including between library calls.

This fix address BZ:
https://bugzilla.redhat.com/show_bug.cgi?id=1012113

Tested by setting umask to 0777 and running the python unit
test and verifying that umask is still same value as expected
at the test completion and with a successful run.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_base.c |  68 +++++++++++--
 liblvm/lvm_lv.c   | 246 ++++++++++++++++++++++++++++++++++++++-------
 liblvm/lvm_misc.c |  25 +++++
 liblvm/lvm_misc.h |  12 +++
 liblvm/lvm_pv.c   | 150 +++++++++++++++++++++++-----
 liblvm/lvm_vg.c   | 292 ++++++++++++++++++++++++++++++++++++++++--------------
 6 files changed, 647 insertions(+), 146 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 80a4894..2a373ba 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -18,13 +18,14 @@
 #include "lvm-version.h"
 #include "metadata-exported.h"
 #include "lvm2app.h"
+#include "lvm_misc.h"
 
 const char *lvm_library_get_version(void)
 {
 	return LVM_VERSION;
 }
 
-lvm_t lvm_init(const char *system_dir)
+static lvm_t _lvm_init(const char *system_dir)
 {
 	struct cmd_context *cmd;
 
@@ -75,18 +76,34 @@ lvm_t lvm_init(const char *system_dir)
 	return (lvm_t) cmd;
 }
 
+
+lvm_t lvm_init(const char *system_dir)
+{
+	lvm_t h = NULL;
+	struct saved_env e = store_user_env(NULL);
+	h = _lvm_init(system_dir);
+	restore_user_env(&e);
+	return h;
+}
+
 void lvm_quit(lvm_t libh)
 {
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 	destroy_toolcontext((struct cmd_context *)libh);
 	udev_fin_library_context();
+	restore_user_env(&e);
 }
 
 int lvm_config_reload(lvm_t libh)
 {
+	int rc = 0;
+
 	/* FIXME: re-init locking needed here? */
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 	if (!refresh_toolcontext((struct cmd_context *)libh))
-		return -1;
-	return 0;
+		rc = -1;
+	restore_user_env(&e);
+	return rc;
 }
 
 /*
@@ -94,54 +111,83 @@ int lvm_config_reload(lvm_t libh)
  */
 int lvm_config_override(lvm_t libh, const char *config_settings)
 {
+	int rc = 0;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+
 	if (!override_config_tree_from_string(cmd, config_settings))
-		return -1;
-	return 0;
+		rc = -1;
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_config_find_bool(lvm_t libh, const char *config_path, int fail)
 {
+	int rc = 0;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	return dm_config_tree_find_bool(cmd->cft, config_path, fail);
+	rc = dm_config_tree_find_bool(cmd->cft, config_path, fail);
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_errno(lvm_t libh)
 {
-	return stored_errno();
+	int rc;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+	rc = stored_errno();
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_errmsg(lvm_t libh)
 {
 	const char *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+
 	const char *msg = stored_errmsg_with_clear();
 	if (msg) {
 		rc = dm_pool_strdup(cmd->mem, msg);
 		free((void *)msg);
 	}
+
+	restore_user_env(&e);
 	return rc;
 }
 
 const char *lvm_vgname_from_pvid(lvm_t libh, const char *pvid)
 {
+	const char *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 	struct id id;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	if (!id_read_format(&id, pvid)) {
+	if (id_read_format(&id, pvid)) {
+		rc = find_vgname_from_pvid(cmd, (char *)id.uuid);
+	} else {
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
-		return NULL;
 	}
-	return find_vgname_from_pvid(cmd, (char *)id.uuid);
+
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_vgname_from_device(lvm_t libh, const char *device)
 {
+	const char *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
-	return find_vgname_from_pvname(cmd, device);
+	struct saved_env e = store_user_env(cmd);
+	rc = find_vgname_from_pvname(cmd, device);
+	restore_user_env(&e);
+	return rc;
 }
 
+/*
+ * No context to work with, so no ability to save off and restore env is not
+ * available and is not needed.
+ */
 float lvm_percent_to_float(percent_t v)
 {
 	return percent_to_float(v);
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index b451c83..3b0e18d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -45,60 +45,99 @@ static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
 uint64_t lvm_lv_get_size(const lv_t lv)
 {
-	return SECTOR_SIZE * lv_size(lv);
+	uint64_t rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = SECTOR_SIZE * lv_size(lv);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_lv_get_uuid(const lv_t lv)
 {
-	return lv_uuid_dup(lv);
+	const char *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = lv_uuid_dup(lv);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_lv_get_name(const lv_t lv)
 {
-	return dm_pool_strndup(lv->vg->vgmem, (const char *)lv->name,
+	const char *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = dm_pool_strndup(lv->vg->vgmem, (const char *)lv->name,
 			       NAME_LEN+1);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_lv_get_attr(const lv_t lv)
 {
-	return lv_attr_dup(lv->vg->vgmem, lv);
+	const char *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = lv_attr_dup(lv->vg->vgmem, lv);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_lv_get_origin(const lv_t lv)
 {
-	return lv_origin_dup(lv->vg->vgmem, lv);
+	const char *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = lv_origin_dup(lv->vg->vgmem, lv);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, NULL, NULL, NULL, name);
+	struct lvm_property_value rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = get_property(NULL, NULL, lv, NULL, NULL, NULL, NULL, name);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, NULL, NULL, NULL, name);
+	struct lvm_property_value rc;
+	struct saved_env e = store_user_env(lvseg->lv->vg->cmd);
+	rc = get_property(NULL, NULL, NULL, lvseg, NULL, NULL, NULL, name);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
+	uint64_t rc = 0;
 	struct lvinfo info;
+
+	struct saved_env e = store_user_env(lv->vg->cmd);
+
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.live_table)
-		return 1;
-	return 0;
+		rc = 1;
+
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_lv_is_suspended(const lv_t lv)
 {
+	uint64_t rc = 0;
 	struct lvinfo info;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.suspended)
-		return 1;
-	return 0;
+		rc = 1;
+
+	restore_user_env(&e);
+	return rc;
 }
 
-int lvm_lv_add_tag(lv_t lv, const char *tag)
+static int _lvm_lv_add_tag(lv_t lv, const char *tag)
 {
 	if (_lv_check_handle(lv, 1))
 		return -1;
@@ -107,8 +146,17 @@ int lvm_lv_add_tag(lv_t lv, const char *tag)
 	return 0;
 }
 
+int lvm_lv_add_tag(lv_t lv, const char *tag)
+{
+	int rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_add_tag(lv, tag);
+	restore_user_env(&e);
+	return rc;
+}
+
 
-int lvm_lv_remove_tag(lv_t lv, const char *tag)
+static int _lvm_lv_remove_tag(lv_t lv, const char *tag)
 {
 	if (_lv_check_handle(lv, 1))
 		return -1;
@@ -117,10 +165,23 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag)
 	return 0;
 }
 
+int lvm_lv_remove_tag(lv_t lv, const char *tag)
+{
+	int rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_remove_tag(lv, tag);
+	restore_user_env(&e);
+	return rc;
+}
+
 
 struct dm_list *lvm_lv_get_tags(const lv_t lv)
 {
-	return tag_list_copy(lv->vg->vgmem, &lv->tags);
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = tag_list_copy(lv->vg->vgmem, &lv->tags);
+	restore_user_env(&e);
+	return rc;
 }
 
 /* Set defaults for non-segment specific LV parameters */
@@ -171,7 +232,7 @@ static int _lv_set_default_linear_params(struct cmd_context *cmd,
  * lvm_vg_write.  However, this appears to be non-trivial change until
  * lv_create_single is refactored by segtype.
  */
-lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
+static lv_t _lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp = { 0 };
 	uint64_t extents;
@@ -196,11 +257,20 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 	return (lv_t) lv;
 }
 
+lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
+{
+	lv_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_vg_create_lv_linear(vg, name, size);
+	restore_user_env(&e);
+	return rc;
+}
+
 /*
  * FIXME: This function should probably not commit to disk but require calling
  * lvm_vg_write.
  */
-int lvm_vg_remove_lv(lv_t lv)
+static int _lvm_vg_remove_lv(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
 		return -1;
@@ -211,7 +281,16 @@ int lvm_vg_remove_lv(lv_t lv)
 	return 0;
 }
 
-int lvm_lv_activate(lv_t lv)
+int lvm_vg_remove_lv(lv_t lv)
+{
+	int rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_vg_remove_lv(lv);
+	restore_user_env(&e);
+	return rc;
+}
+
+static int _lvm_lv_activate(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
 		return -1;
@@ -248,7 +327,16 @@ int lvm_lv_activate(lv_t lv)
 	return 0;
 }
 
-int lvm_lv_deactivate(lv_t lv)
+int lvm_lv_activate(lv_t lv)
+{
+	int rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_activate(lv);
+	restore_user_env(&e);
+	return rc;
+}
+
+static int _lvm_lv_deactivate(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
 		return -1;
@@ -261,7 +349,16 @@ int lvm_lv_deactivate(lv_t lv)
 	return 0;
 }
 
-struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
+int lvm_lv_deactivate(lv_t lv)
+{
+	int rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_deactivate(lv);
+	restore_user_env(&e);
+	return rc;
+}
+
+static struct dm_list *_lvm_lv_list_lvsegs(lv_t lv)
 {
 	struct dm_list *list;
 	lvseg_list_t *lvseg;
@@ -288,18 +385,32 @@ struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
 	return list;
 }
 
+struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
+{
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_list_lvsegs(lv);
+	restore_user_env(&e);
+	return rc;
+}
+
 lv_t lvm_lv_from_name(vg_t vg, const char *name)
 {
+	lv_t rc = NULL;
 	struct lv_list *lvl;
 
+	struct saved_env e = store_user_env(vg->cmd);
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!strcmp(name, lvl->lv->name))
-			return lvl->lv;
+		if (!strcmp(name, lvl->lv->name)) {
+			rc = lvl->lv;
+			break;
+		}
 	}
-	return NULL;
+	restore_user_env(&e);
+	return rc;
 }
 
-lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
+static lv_t _lvm_lv_from_uuid(vg_t vg, const char *uuid)
 {
 	struct lv_list *lvl;
 	struct id id;
@@ -322,19 +433,33 @@ lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
 	return NULL;
 }
 
+lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
+{
+	lv_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_lv_from_uuid(vg, uuid);
+	restore_user_env(&e);
+	return rc;
+}
+
 int lvm_lv_rename(lv_t lv, const char *new_name)
 {
+	int rc = 0;
+	struct saved_env e = store_user_env(lv->vg->cmd);
 	if (!lv_rename(lv->vg->cmd, lv, new_name)) {
 		/* FIXME Improve msg */
 		log_error("LV rename failed.");
-		return -1;
+		rc = -1;
 	}
-	return 0;
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
+	int rc = 0;
 	struct lvresize_params lp = { 0 };
+	struct saved_env e = { 0 };
 
 	lp.vg_name = lv->vg->name;
 	lp.lv_name = lv->name;
@@ -345,27 +470,32 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	lp.ac_force = 1;	/* Assume the user has a good backup? */
 	lp.sizeargs = 1;
 
+	e = store_user_env(lv->vg->cmd);
+
 	if (!lv_resize_prepare(lv->vg->cmd, lv, &lp, &lv->vg->pvs) ||
 	    !lv_resize(lv->vg->cmd, lv, &lp, &lv->vg->pvs)) {
 		/* FIXME Improve msg */
 		log_error("LV resize failed.");
 		/* FIXME Define consistent symbolic return codes */
-		return -1;
+		rc = -1;
 	}
-
-	return 0;
+	restore_user_env(&e);
+	return rc;
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
 						uint64_t max_snap_size)
 {
+	lv_t rc = NULL;
 	struct lvm_lv_create_params *lvcp = NULL;
+	struct saved_env e = store_user_env(lv->vg->cmd);
 
 	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
 	if (lvcp) {
-		return lvm_lv_create(lvcp);
+		rc = lvm_lv_create(lvcp);
 	}
-	return NULL;
+	restore_user_env(&e);
+	return rc;
 }
 
 /* Set defaults for thin pool specific LV parameters */
@@ -405,7 +535,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
+static lv_create_params_t _lvm_lv_params_create_thin_pool(vg_t vg,
 		const char *pool_name, uint64_t size, uint32_t chunk_size,
 		uint64_t meta_size, lvm_thin_discards_t discard)
 {
@@ -465,6 +595,18 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 	return lvcp;
 }
 
+lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
+		const char *pool_name, uint64_t size, uint32_t chunk_size,
+		uint64_t meta_size, lvm_thin_discards_t discard)
+{
+	lv_create_params_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_lv_params_create_thin_pool(vg, pool_name, size, chunk_size,
+										meta_size, discard);
+	restore_user_env(&e);
+	return rc;
+}
+
 /* Set defaults for thin LV specific parameters */
 static int _lv_set_thin_params(struct lvcreate_params *lp,
 				vg_t vg, const char *pool,
@@ -487,7 +629,7 @@ static int _lv_set_thin_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 						 const char *snap_name,
 						 uint64_t max_snap_size)
 {
@@ -548,8 +690,19 @@ lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
 	return lvcp;
 }
 
+lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+						 const char *snap_name,
+						 uint64_t max_snap_size)
+{
+	lv_create_params_t rc;
+	struct saved_env e = store_user_env(lv->vg->cmd);
+	rc = _lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
+	restore_user_env(&e);
+	return rc;
+}
 
-lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
+static lv_create_params_t _lvm_lv_params_create_thin(const vg_t vg,
+									const char *pool_name,
 									const char *lvname, uint64_t size)
 {
 	struct lvm_lv_create_params *lvcp = NULL;
@@ -590,6 +743,16 @@ lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_nam
 	return lvcp;
 }
 
+lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
+									const char *lvname, uint64_t size)
+{
+	lv_create_params_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_lv_params_create_thin(vg, pool_name, lvname, size);
+	restore_user_env(&e);
+	return rc;
+}
+
 struct lvm_property_value lvm_lv_params_get_property(
 						const lv_create_params_t params,
 						const char *name)
@@ -597,13 +760,14 @@ struct lvm_property_value lvm_lv_params_get_property(
 	struct lvm_property_value rc = {
 		.is_valid = 0
 	};
+	struct saved_env e = store_user_env(params->vg->cmd);
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
 		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, NULL, name);
 	} else {
 		log_error("Invalid lv_create_params parameter");
 	}
-
+	restore_user_env(&e);
 	return rc;
 }
 
@@ -611,16 +775,19 @@ int lvm_lv_params_set_property(lv_create_params_t params, const char *name,
 								struct lvm_property_value *prop)
 {
 	int rc = -1;
+	struct saved_env e = store_user_env(params->vg->cmd);
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
 		rc = set_property(NULL, NULL, NULL, &params->lvp, NULL, name, prop);
 	} else {
 		log_error("Invalid lv_create_params parameter");
 	}
+
+	restore_user_env(&e);
 	return rc;
 }
 
-lv_t lvm_lv_create(lv_create_params_t params)
+static lv_t _lvm_lv_create(lv_create_params_t params)
 {
 	struct lv_list *lvl = NULL;
 
@@ -644,3 +811,12 @@ lv_t lvm_lv_create(lv_create_params_t params)
 	log_error("Invalid lv_create_params parameter");
 	return NULL;
 }
+
+lv_t lvm_lv_create(lv_create_params_t params)
+{
+	lv_t rc;
+	struct saved_env e = store_user_env(params->vg->cmd);
+	rc = _lvm_lv_create(params);
+	restore_user_env(&e);
+	return rc;
+}
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index ba77010..d9b4323 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -140,3 +140,28 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 	}
 	return 0;
 }
+
+/*
+ * Store anything that may need to be restored back to the user on library
+ * call exit.  Currently the only thing we are preserving is the users umask.
+ */
+struct saved_env store_user_env(struct cmd_context *cmd)
+{
+	struct saved_env env = {0};
+
+	if (cmd) {
+		env.user_umask = umask(cmd->default_settings.umask);
+	} else {
+		env.user_umask = umask(0);
+		umask(env.user_umask);
+	}
+
+	return env;
+}
+
+void restore_user_env(const struct saved_env *env)
+{
+	if (env) {
+		umask(env->user_umask);
+	}
+}
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index b187021..4678338 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -17,6 +17,18 @@
 #include "libdevmapper.h"
 #include "lvm2app.h"
 #include "metadata-exported.h"
+#include "toolcontext.h"
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+struct saved_env
+{
+	mode_t user_umask;
+};
+
+struct saved_env store_user_env(struct cmd_context *cmd);
+void restore_user_env(const struct saved_env *env);
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index d540a6c..163ea4f 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -20,6 +20,7 @@
 #include "lvm2app.h"
 #include "locking.h"
 #include "toolcontext.h"
+#include "lvm_misc.h"
 
 struct lvm_pv_create_params
 {
@@ -33,43 +34,75 @@ struct lvm_pv_create_params
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
-	return pv_uuid_dup(pv);
+	const char *rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = pv_uuid_dup(pv);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_pv_get_name(const pv_t pv)
 {
-	return dm_pool_strndup(pv->vg->vgmem, pv_dev_name(pv), NAME_LEN);
+	const char *rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = dm_pool_strndup(pv->vg->vgmem, pv_dev_name(pv), NAME_LEN);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_pv_get_mda_count(const pv_t pv)
 {
-	return (uint64_t) pv_mda_count(pv);
+	uint64_t rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = (uint64_t) pv_mda_count(pv);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_pv_get_dev_size(const pv_t pv)
 {
-	return SECTOR_SIZE * pv_dev_size(pv);
+	uint64_t rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = SECTOR_SIZE * pv_dev_size(pv);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_pv_get_size(const pv_t pv)
 {
-	return SECTOR_SIZE * pv_size_field(pv);
+	uint64_t rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = SECTOR_SIZE * pv_size_field(pv);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_pv_get_free(const pv_t pv)
 {
-	return SECTOR_SIZE * pv_free(pv);
+	uint64_t rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = SECTOR_SIZE * pv_free(pv);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, NULL, NULL, NULL, name);
+	struct lvm_property_value rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = get_property(pv, NULL, NULL, NULL, NULL, NULL, NULL, name);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, NULL, name);
+	struct lvm_property_value rc;
+	struct saved_env e = store_user_env(pvseg->pv->vg->cmd);
+	rc = get_property(NULL, NULL, NULL, NULL, pvseg, NULL, NULL, name);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_list_wrapper
@@ -82,17 +115,20 @@ struct lvm_list_wrapper
 
 int lvm_pv_remove(lvm_t libh, const char *pv_name)
 {
+	int rc = 0;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
+	struct saved_env e = store_user_env(cmd);
 
 	if (!pvremove_single(cmd, pv_name, NULL, 0, 0))
-		return -1;
+		rc = -1;
 
-	return 0;
+	restore_user_env(&e);
+	return rc;
 }
 
-#define PV_LIST_MAGIC 0xF005BA11
+#define PV_LIST_MAGIC 4026907153
 
-struct dm_list *lvm_list_pvs(lvm_t libh)
+static struct dm_list *_lvm_list_pvs(lvm_t libh)
 {
 	struct lvm_list_wrapper *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
@@ -127,11 +163,21 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 	return &rc->pvslist;
 }
 
+struct dm_list *lvm_list_pvs(lvm_t libh)
+{
+	struct dm_list *rc;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+	rc = _lvm_list_pvs(libh);
+	restore_user_env(&e);
+	return rc;
+}
+
 int lvm_list_pvs_free(struct dm_list *pvlist)
 {
 	struct lvm_list_wrapper *to_delete;
 	struct vg_list *vgl;
 	struct pv_list *pvl;
+	struct saved_env e;
 
 	if (pvlist) {
 		to_delete = dm_list_struct_base(pvlist, struct lvm_list_wrapper, pvslist);
@@ -140,6 +186,12 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 			return -1;
 		}
 
+		/*
+		 * Need to ensure that pointer is valid before we can use reference to
+		 * cmd.
+		 */
+		e = store_user_env(to_delete->cmd);
+
 		dm_list_iterate_items(vgl, &to_delete->vgslist) {
 			release_vg(vgl->vg);
 		}
@@ -149,12 +201,14 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 
 		unlock_vg(to_delete->cmd, VG_GLOBAL);
 		to_delete->magic = 0xA5A5A5A5;
+
+		restore_user_env(&e);
 	}
 
 	return 0;
 }
 
-struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
+static struct dm_list *_lvm_pv_list_pvsegs(pv_t pv)
 {
 	struct dm_list *list;
 	pvseg_list_t *pvseg;
@@ -183,18 +237,32 @@ struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
 	return list;
 }
 
+struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
+{
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = _lvm_pv_list_pvsegs(pv);
+	restore_user_env(&e);
+	return rc;
+}
+
 pv_t lvm_pv_from_name(vg_t vg, const char *name)
 {
+	pv_t rc = NULL;
 	struct pv_list *pvl;
+	struct saved_env e = store_user_env(vg->cmd);
 
 	dm_list_iterate_items(pvl, &vg->pvs)
-		if (!strcmp(name, pv_dev_name(pvl->pv)))
-			return pvl->pv;
+		if (!strcmp(name, pv_dev_name(pvl->pv))) {
+			rc = pvl->pv;
+			break;
+		}
 
-	return NULL;
+	restore_user_env(&e);
+	return rc;
 }
 
-pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
+static pv_t _lvm_pv_from_uuid(vg_t vg, const char *uuid)
 {
 	struct pv_list *pvl;
 	struct id id;
@@ -216,7 +284,16 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
 	return NULL;
 }
 
-int lvm_pv_resize(const pv_t pv, uint64_t new_size)
+pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
+{
+	pv_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_pv_from_uuid(vg, uuid);
+	restore_user_env(&e);
+	return rc;
+}
+
+static int _lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	uint64_t size = new_size >> SECTOR_SHIFT;
 
@@ -236,6 +313,15 @@ int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 	return 0;
 }
 
+int lvm_pv_resize(const pv_t pv, uint64_t new_size)
+{
+	int rc;
+	struct saved_env e = store_user_env(pv->vg->cmd);
+	rc = _lvm_pv_resize(pv, new_size);
+	restore_user_env(&e);
+	return rc;
+}
+
 /*
  * Common internal code to create a parameter passing object
  */
@@ -280,7 +366,11 @@ static struct lvm_pv_create_params *_lvm_pv_params_create(
 
 pv_create_params_t lvm_pv_params_create(lvm_t libh, const char *pv_name)
 {
-	return _lvm_pv_params_create(libh, pv_name, NULL);
+	pv_create_params_t rc;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+	rc = _lvm_pv_params_create(libh, pv_name, NULL);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct lvm_property_value lvm_pv_params_get_property(
@@ -290,10 +380,13 @@ struct lvm_property_value lvm_pv_params_get_property(
 	struct lvm_property_value rc = {
 		.is_valid = 0
 	};
+	struct saved_env e;
 
 	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		e = store_user_env((struct cmd_context *)(params->libh));
 		rc = get_property(NULL, NULL, NULL, NULL, NULL, NULL, &params->pv_p,
 							name);
+		restore_user_env(&e);
 	} else {
 		log_error("Invalid pv_create_params parameter");
 	}
@@ -305,9 +398,12 @@ int lvm_pv_params_set_property(pv_create_params_t params, const char *name,
 								struct lvm_property_value *prop)
 {
 	int rc = -1;
+	struct saved_env e;
 
 	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		e = store_user_env((struct cmd_context *)(params->libh));
 		rc = set_property(NULL, NULL, NULL, NULL, &params->pv_p, name, prop);
+		restore_user_env(&e);
 	} else {
 		log_error("Invalid pv_create_params parameter");
 	}
@@ -334,21 +430,27 @@ static int _pv_create(pv_create_params_t params)
 int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
 {
 	struct lvm_pv_create_params pp;
+	int rc = -1;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	if (!_lvm_pv_params_create(libh, pv_name, &pp))
-		return -1;
-
-	pp.pv_p.size = size;
+	if (_lvm_pv_params_create(libh, pv_name, &pp)) {
+		pp.pv_p.size = size;
+		rc = _pv_create(&pp);
+	}
 
-	return _pv_create(&pp);
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_pv_create_adv(pv_create_params_t params)
 {
 	int rc = -1;
+	struct saved_env e;
 
 	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		e = store_user_env((struct cmd_context *)(params->libh));
 		rc = _pv_create(params);
+		restore_user_env(&e);
 	} else {
 		log_error("Invalid pv_create_params parameter");
 	}
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index d3c8ae2..76c5c63 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -25,47 +25,49 @@
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
-	if (vg_read_error(vg))
-		return -1;
-
-	if (!vg_check_write_mode(vg))
-		return -1;
+	int rc = -1;
+	struct saved_env e = store_user_env(vg->cmd);
 
-	if (!vg_change_tag(vg, tag, 1))
-		return -1;
-	return 0;
+	if (!vg_read_error(vg) && vg_check_write_mode(vg) &&
+		vg_change_tag(vg, tag, 1))
+		rc = 0;
+	restore_user_env(&e);
+	return rc;
 }
 
 
 int lvm_vg_remove_tag(vg_t vg, const char *tag)
 {
-	if (vg_read_error(vg))
-		return -1;
-
-	if (!vg_check_write_mode(vg))
-		return -1;
+	int rc = -1;
+	struct saved_env e = store_user_env(vg->cmd);
 
-	if (!vg_change_tag(vg, tag, 0))
-		return -1;
-	return 0;
+	if (!vg_read_error(vg) && vg_check_write_mode(vg) &&
+		vg_change_tag(vg, tag, 0))
+		rc = 0;
+	restore_user_env(&e);
+	return rc;
 }
 
 
 vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 {
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
 	vg = vg_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		return NULL;
+		vg = NULL;
+	} else {
+		vg->open_mode = 'w';
 	}
-	vg->open_mode = 'w';
+
+	restore_user_env(&e);
 	return (vg_t) vg;
 }
 
-int lvm_vg_extend(vg_t vg, const char *device)
+static int _lvm_vg_extend(vg_t vg, const char *device)
 {
 	struct pvcreate_params pp;
 
@@ -93,31 +95,41 @@ int lvm_vg_extend(vg_t vg, const char *device)
 	return 0;
 }
 
+int lvm_vg_extend(vg_t vg, const char *device)
+{
+	int rc = 0;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_vg_extend(vg, device);
+	restore_user_env(&e);
+	return rc;
+}
+
 int lvm_vg_reduce(vg_t vg, const char *device)
 {
-	if (vg_read_error(vg))
-		return -1;
-	if (!vg_check_write_mode(vg))
-		return -1;
+	int rc = -1;
+	struct saved_env e = store_user_env(vg->cmd);
 
-	if (!vg_reduce(vg, device))
-		return -1;
-	return 0;
+	if (!vg_read_error(vg) && vg_check_write_mode(vg) && vg_reduce(vg, device))
+		rc = 0;
+
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size)
 {
-	if (vg_read_error(vg))
-		return -1;
-	if (!vg_check_write_mode(vg))
-		return -1;
+	int rc = -1;
+	struct saved_env e = store_user_env(vg->cmd);
 
-	if (!vg_set_extent_size(vg, new_size / SECTOR_SIZE))
-		return -1;
-	return 0;
+	if (!vg_read_error(vg) && vg_check_write_mode(vg) &&
+		vg_set_extent_size(vg, new_size / SECTOR_SIZE))
+		rc = 0;
+
+	restore_user_env(&e);
+	return rc;
 }
 
-int lvm_vg_write(vg_t vg)
+static int _lvm_vg_write(vg_t vg)
 {
 	struct pv_list *pvl;
 
@@ -159,31 +171,41 @@ int lvm_vg_write(vg_t vg)
 	return 0;
 }
 
+int lvm_vg_write(vg_t vg)
+{
+	int rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_vg_write(vg);
+	restore_user_env(&e);
+	return rc;
+}
+
 int lvm_vg_close(vg_t vg)
 {
+	struct saved_env e = store_user_env(vg->cmd);
 	if (vg_read_error(vg) == FAILED_LOCKING)
 		release_vg(vg);
 	else
 		unlock_and_release_vg(vg->cmd, vg, vg->name);
+	restore_user_env(&e);
 	return 0;
 }
 
 int lvm_vg_remove(vg_t vg)
 {
-	if (vg_read_error(vg))
-		return -1;
-	if (!vg_check_write_mode(vg))
-		return -1;
+	int rc = -1;
+	struct saved_env e = store_user_env(vg->cmd);
 
-	if (!vg_remove_check(vg))
-		return -1;
-
-	vg_remove_pvs(vg);
+	if (!vg_read_error(vg) && vg_check_write_mode(vg) && vg_remove_check(vg)) {
+		vg_remove_pvs(vg);
+		rc = 0;
+	}
 
-	return 0;
+	restore_user_env(&e);
+	return rc;
 }
 
-vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+static vg_t _lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags)
 {
 	uint32_t internal_flags = 0;
@@ -208,7 +230,17 @@ vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 	return (vg_t) vg;
 }
 
-struct dm_list *lvm_vg_list_pvs(vg_t vg)
+vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags)
+{
+	vg_t rc;
+	struct saved_env e = store_user_env((struct cmd_context*)libh);
+	rc = _lvm_vg_open(libh, vgname, mode, flags);
+	restore_user_env(&e);
+	return rc;
+}
+
+static struct dm_list *_lvm_vg_list_pvs(vg_t vg)
 {
 	struct dm_list *list;
 	pv_list_t *pvs;
@@ -235,7 +267,16 @@ struct dm_list *lvm_vg_list_pvs(vg_t vg)
 	return list;
 }
 
-struct dm_list *lvm_vg_list_lvs(vg_t vg)
+struct dm_list *lvm_vg_list_pvs(vg_t vg)
+{
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_vg_list_pvs(vg);
+	restore_user_env(&e);
+	return rc;
+}
+
+static struct dm_list *_lvm_vg_list_lvs(vg_t vg)
 {
 	struct dm_list *list;
 	lv_list_t *lvs;
@@ -262,86 +303,159 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg)
 	return list;
 }
 
+struct dm_list *lvm_vg_list_lvs(vg_t vg)
+{
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = _lvm_vg_list_lvs(vg);
+	restore_user_env(&e);
+	return rc;
+}
+
 struct dm_list *lvm_vg_get_tags(const vg_t vg)
 {
-	return tag_list_copy(vg->vgmem, &vg->tags);
+	struct dm_list *rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = tag_list_copy(vg->vgmem, &vg->tags);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_seqno(const vg_t vg)
 {
-	return vg_seqno(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_seqno(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_is_clustered(const vg_t vg)
 {
-	return vg_is_clustered(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_is_clustered(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_is_exported(const vg_t vg)
 {
-	return vg_is_exported(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_is_exported(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_is_partial(const vg_t vg)
 {
-	return (vg_missing_pv_count(vg) != 0);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = (vg_missing_pv_count(vg) != 0);
+	restore_user_env(&e);
+	return rc;
 }
 
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {
-	return SECTOR_SIZE * vg_size(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = SECTOR_SIZE * vg_size(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_free_size(const vg_t vg)
 {
-	return SECTOR_SIZE * vg_free(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = SECTOR_SIZE * vg_free(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_extent_size(const vg_t vg)
 {
-	return SECTOR_SIZE * vg_extent_size(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = SECTOR_SIZE * vg_extent_size(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_extent_count(const vg_t vg)
 {
-	return vg_extent_count(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_extent_count(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_free_extent_count(const vg_t vg)
 {
-	return vg_free_count(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_free_count(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_pv_count(const vg_t vg)
 {
-	return vg_pv_count(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_pv_count(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_max_pv(const vg_t vg)
 {
-	return vg_max_pv(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_max_pv(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 uint64_t lvm_vg_get_max_lv(const vg_t vg)
 {
-	return vg_max_lv(vg);
+	uint64_t rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_max_lv(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_vg_get_uuid(const vg_t vg)
 {
-	return vg_uuid_dup(vg);
+	const char *rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = vg_uuid_dup(vg);
+	restore_user_env(&e);
+	return rc;
 }
 
 const char *lvm_vg_get_name(const vg_t vg)
 {
-	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
+	const char *rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
+	restore_user_env(&e);
+	return rc;
 }
 
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, NULL, NULL, NULL, name);
+	struct lvm_property_value rc;
+	struct saved_env e = store_user_env(vg->cmd);
+	rc = get_property(NULL, vg, NULL, NULL, NULL, NULL, NULL, name);
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,
@@ -352,29 +466,41 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 	 * that worst case we have two copies which will get freed when the vg gets
 	 * released.
 	 */
+	int rc;
+	struct saved_env e = store_user_env(vg->cmd);
 
 	if (value->is_valid && value->is_string && value->value.string) {
 		value->value.string = dm_pool_strndup(vg->vgmem, value->value.string,
 				strlen(value->value.string) + 1);
 	}
 
-	return set_property(NULL, vg, NULL, NULL, NULL, name, value);
+	rc = set_property(NULL, vg, NULL, NULL, NULL, name, value);
+	restore_user_env(&e);
+	return rc;
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
-	if (!lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh))
-		return NULL;
+	struct dm_list *rc = NULL;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	return get_vgnames((struct cmd_context *)libh, 0);
+	if (lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh)) {
+		rc = get_vgnames((struct cmd_context *)libh, 0);
+	}
+	restore_user_env(&e);
+	return rc;
 }
 
 struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
-	if (!lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh))
-		return NULL;
+	struct dm_list *rc = NULL;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	return get_vgids((struct cmd_context *)libh, 0);
+	if (lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh)) {
+		rc = get_vgids((struct cmd_context *)libh, 0);
+	}
+	restore_user_env(&e);
+	return rc;
 }
 
 /*
@@ -382,21 +508,29 @@ struct dm_list *lvm_list_vg_uuids(lvm_t libh)
  */
 int lvm_scan(lvm_t libh)
 {
+	int rc = 0;
+	struct saved_env e = store_user_env((struct cmd_context *)libh);
+
 	if (!lvmcache_label_scan((struct cmd_context *)libh, 2))
-		return -1;
-	return 0;
+		rc = -1;
+
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_lv_name_validate(const vg_t vg, const char *name)
 {
+	int rc = -1;
 	name_error_t name_error;
 
+	struct saved_env e = store_user_env(vg->cmd);
+
 	name_error = validate_name_detailed(name);
 
 	if (NAME_VALID == name_error) {
 		if (apply_lvname_restrictions(name)) {
 			if (!find_lv_in_vg(vg, name)) {
-				return 0;
+				rc = 0;
 			} else {
 				log_errno(EINVAL, "LV name exists in VG");
 			}
@@ -404,14 +538,20 @@ int lvm_lv_name_validate(const vg_t vg, const char *name)
 	} else {
 		display_name_error(name_error);
 	}
-	return -1;
+
+	restore_user_env(&e);
+	return rc;
 }
 
 int lvm_vg_name_validate(lvm_t libh, const char *name)
 {
+	int rc = -1;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
+	struct saved_env e = store_user_env(cmd);
 
 	if (validate_new_vg_name(cmd, name))
-		return 0;
-	return -1;
+		rc = 0;
+
+	restore_user_env(&e);
+	return rc;
 }
-- 
1.8.2.1


