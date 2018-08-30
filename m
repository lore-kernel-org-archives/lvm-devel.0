From: David Teigland <teigland@sourceware.org>
Date: Thu, 30 Aug 2018 11:01:16 -0400
Subject: master - filter: add config setting to skip scanning LVs
Message-ID: <201808301501.w7UF1Gpj011142@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfcecbbce182570d040f3ec446dccb84ca07efcd
Commit:        bfcecbbce182570d040f3ec446dccb84ca07efcd
Parent:        a0f6f188416823c2d32bb54bddff00e09f4426e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 29 13:14:18 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 30 09:59:50 2018 -0500

filter: add config setting to skip scanning LVs

devices/scan_lvs (default 1) determines whether lvm
will scan LVs for layered PVs.  The lvm behavior has
always been to scan LVs, but it's rare for LVs to have
layered PVs, and much more common for there to be many
LVs that substantially slow down scanning with no benefit.

This is implemented in the usable filter, and has the
same effect as listing all LVs in the global_filter.
---
 lib/activate/activate.h      |    1 +
 lib/activate/dev_manager.c   |    5 +++++
 lib/commands/toolcontext.c   |    2 +-
 lib/config/config_settings.h |    3 +++
 lib/config/defaults.h        |    2 ++
 lib/filters/filter-usable.c  |   27 ++++++++++++++++++++++-----
 lib/filters/filter.h         |    2 +-
 7 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index cca2504..9530c36 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -240,6 +240,7 @@ struct dev_usable_check_params {
 	unsigned int check_suspended:1;
 	unsigned int check_error_target:1;
 	unsigned int check_reserved:1;
+	unsigned int check_lv:1;
 };
 
 /*
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 43dba8c..67a49be 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -648,6 +648,11 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		}
 	}
 
+	if (check.check_lv && uuid && !strncmp(uuid, "LVM-", 4)) {
+		/* Skip LVs */
+		goto out;
+	}
+
 	if (check.check_reserved && uuid &&
 	    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
 	     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 961962c..fa87bcc 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1088,7 +1088,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	nr_filt++;
 
 	/* usable device filter. Required. */
-	if (!(filters[nr_filt] = usable_filter_create(cmd->dev_types, FILTER_MODE_NO_LVMETAD))) {
+	if (!(filters[nr_filt] = usable_filter_create(cmd, cmd->dev_types, FILTER_MODE_NO_LVMETAD))) {
 		log_error("Failed to create usabled device filter");
 		goto bad;
 	}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1d0cc79..b47b225 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -337,6 +337,9 @@ cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"This is a quick way of filtering out block devices that are not\n"
 	"present on the system. sysfs must be part of the kernel and mounted.)\n")
 
+cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SCAN_LVS, vsn(2, 2, 182), NULL, 0, NULL,
+	"Scan LVM LVs for layered PVs.\n")
+
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9928fb1..9fbe8c2 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -300,4 +300,6 @@
 #define DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_VDO_POOL_AUTOEXTEND_PERCENT 20
 
+#define DEFAULT_SCAN_LVS 1
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index ab5c02f..6997368 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -21,6 +21,11 @@
 #include "lib/device/dev-ext-udev-constants.h"
 #endif
 
+struct filter_data {
+	filter_mode_t mode;
+	int skip_lvs;
+};
+
 static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
 
 static int _native_check_pv_min_size(struct device *dev)
@@ -102,7 +107,9 @@ static int _check_pv_min_size(struct device *dev)
 
 static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev)
 {
-	filter_mode_t mode = *((filter_mode_t *) f->private);
+	struct filter_data *data = f->private;
+	filter_mode_t mode = data->mode;
+	int skip_lvs = data->skip_lvs;
 	struct dev_usable_check_params ucp = {0};
 	int r = 1;
 
@@ -115,6 +122,7 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			ucp.check_suspended = ignore_suspended_devices();
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
+			ucp.check_lv = skip_lvs;
 			break;
 		case FILTER_MODE_PRE_LVMETAD:
 			ucp.check_empty = 1;
@@ -122,6 +130,7 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			ucp.check_suspended = 0;
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
+			ucp.check_lv = skip_lvs;
 			break;
 		case FILTER_MODE_POST_LVMETAD:
 			ucp.check_empty = 0;
@@ -129,6 +138,7 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			ucp.check_suspended = ignore_suspended_devices();
 			ucp.check_error_target = 0;
 			ucp.check_reserved = 0;
+			ucp.check_lv = skip_lvs;
 			break;
 		}
 
@@ -162,8 +172,9 @@ static void _usable_filter_destroy(struct dev_filter *f)
 	free(f);
 }
 
-struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
+struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
 {
+	struct filter_data *data;
 	struct dev_filter *f;
 
 	if (!(f = zalloc(sizeof(struct dev_filter)))) {
@@ -174,14 +185,20 @@ struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unus
 	f->passes_filter = _passes_usable_filter;
 	f->destroy = _usable_filter_destroy;
 	f->use_count = 0;
-	if (!(f->private = zalloc(sizeof(filter_mode_t)))) {
+
+	if (!(data = zalloc(sizeof(struct filter_data)))) {
 		log_error("Usable device filter mode allocation failed");
 		free(f);
 		return NULL;
 	}
-	*((filter_mode_t *) f->private) = mode;
 
-	log_debug_devs("Usable device filter initialised.");
+	data->mode = mode;
+
+	data->skip_lvs = !find_config_tree_bool(cmd, devices_scan_lvs_CFG, NULL);
+
+	f->private = data;
+
+	log_debug_devs("Usable device filter initialised (scan_lvs %d).", !data->skip_lvs);
 
 	return f;
 }
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index cdd5a14..7333cfe 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -50,6 +50,6 @@ typedef enum {
 	FILTER_MODE_PRE_LVMETAD,
 	FILTER_MODE_POST_LVMETAD
 } filter_mode_t;
-struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
+struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_types *dt, filter_mode_t mode);
 
 #endif 	/* _LVM_FILTER_H */


