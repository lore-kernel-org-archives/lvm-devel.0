From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 17:46:51 -0500
Subject: stable-2.02 - filter: add config setting to skip scanning LVs
Message-ID: <201902202246.x1KMkpm6005033@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a5575e9597c50a7ebc89895de154db3fa13d753
Commit:        6a5575e9597c50a7ebc89895de154db3fa13d753
Parent:        57cde6063f3073e73542c5f7f59d0269ad9b703b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 29 13:14:18 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:30:24 2019 -0600

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
 lib/commands/toolcontext.c   |    4 ++--
 lib/config/config_settings.h |    3 +++
 lib/config/defaults.h        |    2 ++
 lib/filters/filter-usable.c  |   27 ++++++++++++++++++++++-----
 lib/filters/filter.h         |    2 +-
 7 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index d2c6db7..524d2bf 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -234,6 +234,7 @@ struct dev_usable_check_params {
 	unsigned int check_suspended:1;
 	unsigned int check_error_target:1;
 	unsigned int check_reserved:1;
+	unsigned int check_lv:1;
 };
 
 /*
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d281b60..1f4ec65 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -640,6 +640,11 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
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
index ecd8fd7..3289b38 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1115,7 +1115,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	nr_filt++;
 
 	/* usable device filter. Required. */
-	if (!(filters[nr_filt] = usable_filter_create(cmd->dev_types,
+	if (!(filters[nr_filt] = usable_filter_create(cmd, cmd->dev_types,
 						      lvmetad_used() ? FILTER_MODE_PRE_LVMETAD
 								     : FILTER_MODE_NO_LVMETAD))) {
 		log_error("Failed to create usabled device filter");
@@ -1235,7 +1235,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 			}
 			nr_filt++;
 		}
-		if (!(filter_components[nr_filt] = usable_filter_create(cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
+		if (!(filter_components[nr_filt] = usable_filter_create(cmd, cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
 			log_verbose("Failed to create usable device filter.");
 			goto bad;
 		}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3433d0c..8fe7ec9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -345,6 +345,9 @@ cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"This is a quick way of filtering out block devices that are not\n"
 	"present on the system. sysfs must be part of the kernel and mounted.)\n")
 
+cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SCAN_LVS, vsn(2, 2, 182), NULL, 0, NULL,
+	"Scan LVM LVs for layered PVs.\n")
+
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index fc2f603..12d8e1d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -267,4 +267,6 @@
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
 
+#define DEFAULT_SCAN_LVS 1
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 2de2a0f..bb392a9 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -20,6 +20,11 @@
 #include "dev-ext-udev-constants.h"
 #endif
 
+struct filter_data {
+	filter_mode_t mode;
+	int skip_lvs;
+};
+
 static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
 
 static int _native_check_pv_min_size(struct device *dev)
@@ -101,7 +106,9 @@ static int _check_pv_min_size(struct device *dev)
 
 static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 {
-	filter_mode_t mode = *((filter_mode_t *) f->private);
+	struct filter_data *data = f->private;
+	filter_mode_t mode = data->mode;
+	int skip_lvs = data->skip_lvs;
 	struct dev_usable_check_params ucp = {0};
 	int r = 1;
 
@@ -114,6 +121,7 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			ucp.check_suspended = ignore_suspended_devices();
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
+			ucp.check_lv = skip_lvs;
 			break;
 		case FILTER_MODE_PRE_LVMETAD:
 			ucp.check_empty = 1;
@@ -121,6 +129,7 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			ucp.check_suspended = 0;
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
+			ucp.check_lv = skip_lvs;
 			break;
 		case FILTER_MODE_POST_LVMETAD:
 			ucp.check_empty = 0;
@@ -128,6 +137,7 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			ucp.check_suspended = ignore_suspended_devices();
 			ucp.check_error_target = 0;
 			ucp.check_reserved = 0;
+			ucp.check_lv = skip_lvs;
 			break;
 		}
 
@@ -161,8 +171,9 @@ static void _usable_filter_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
+struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
 {
+	struct filter_data *data;
 	struct dev_filter *f;
 
 	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
@@ -173,14 +184,20 @@ struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unus
 	f->passes_filter = _passes_usable_filter;
 	f->destroy = _usable_filter_destroy;
 	f->use_count = 0;
-	if (!(f->private = dm_zalloc(sizeof(filter_mode_t)))) {
+
+	if (!(data = dm_zalloc(sizeof(struct filter_data)))) {
 		log_error("Usable device filter mode allocation failed");
 		dm_free(f);
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
index 6245827..45572eb 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -52,7 +52,7 @@ typedef enum {
 	FILTER_MODE_PRE_LVMETAD,
 	FILTER_MODE_POST_LVMETAD
 } filter_mode_t;
-struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
+struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_types *dt, filter_mode_t mode);
 
 int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
 


