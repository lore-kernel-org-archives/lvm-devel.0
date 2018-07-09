From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:43 -0400
Subject: master - dmeventd: lvm vdo support
Message-ID: <201807091335.w69DZhp0030864@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=faa126882a9cf2fb64dd143bb96414399e30edf2
Commit:        faa126882a9cf2fb64dd143bb96414399e30edf2
Parent:        12213445b5f86155665ed6f027082e93c4f6cf85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 11:43:12 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:16 2018 +0200

dmeventd: lvm vdo support

---
 conf/example.conf.in         |   44 +++++++++++++++++++++++++++++++++++++++++
 lib/config/config_settings.h |   38 +++++++++++++++++++++++++++++++++++
 lib/config/defaults.h        |    4 +++
 lib/vdo/vdo.c                |   45 ++++++++++++++++++++++++++++++++++++++++++
 tools/lvmcmdlib.c            |    3 ++
 5 files changed, 134 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index f2bb77b..36204d3 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1533,6 +1533,33 @@ activation {
 	# 
 	thin_pool_autoextend_percent = 20
 
+	# Configuration option activation/vdo_pool_autoextend_threshold.
+	# Auto-extend a VDO pool when its usage exceeds this percent.
+	# Setting this to 100 disables automatic extension.
+	# The minimum value is 50 (a smaller value is treated as 50.)
+	# Also see vdo_pool_autoextend_percent.
+	# Automatic extension requires dmeventd to be monitoring the LV.
+	# 
+	# Example
+	# Using 70% autoextend threshold and 20% autoextend size, when a 10G
+	# VDO pool exceeds 7G, it is extended to 12G, and when it exceeds
+	# 8.4G, it is extended to 14.4G:
+	# vdo_pool_autoextend_threshold = 70
+	# 
+	vdo_pool_autoextend_threshold = 100
+
+	# Configuration option activation/vdo_pool_autoextend_percent.
+	# Auto-extending a VDO pool adds this percent extra space.
+	# The amount of additional space added to a VDO pool is this
+	# percent of its current size.
+	# 
+	# Example
+	# Using 70% autoextend threshold and 20% autoextend size, when a 10G
+	# VDO pool exceeds 7G, it is extended to 12G, and when it exceeds
+	# 8.4G, it is extended to 14.4G:
+	# This configuration option has an automatic default value.
+	# vdo_pool_autoextend_percent = 20
+
 	# Configuration option activation/mlock_filter.
 	# Do not mlock these memory areas.
 	# While activating devices, I/O to devices being (re)configured is
@@ -2154,6 +2181,23 @@ dmeventd {
 	# This configuration option has an automatic default value.
 	# thin_command = "lvm lvextend --use-policies"
 
+	# Configuration option dmeventd/vdo_library.
+	# The library dmeventd uses when monitoring a VDO pool device.
+	# libdevmapper-event-lvm2vdo.so monitors the filling of a pool
+	# and emits a warning through syslog when the usage exceeds 80%. The
+	# warning is repeated when 85%, 90% and 95% of the pool is filled.
+	# This configuration option has an automatic default value.
+	# vdo_library = "libdevmapper-event-lvm2vdo.so"
+
+	# Configuration option dmeventd/vdo_command.
+	# The plugin runs command with each 5% increment when VDO pool volume
+	# gets above 50%.
+	# Command which starts with 'lvm ' prefix is internal lvm command.
+	# You can write your own handler to customise behaviour in more details.
+	# User handler is specified with the full path starting with '/'.
+	# This configuration option has an automatic default value.
+	# vdo_command = "lvm lvextend --use-policies"
+
 	# Configuration option dmeventd/executable.
 	# The full path to the dmeventd binary.
 	# This configuration option has an automatic default value.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9026c2d..3417127 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1478,6 +1478,30 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 	"thin_pool_autoextend_percent = 20\n"
 	"#\n")
 
+cfg(activation_vdo_pool_autoextend_threshold_CFG, "vdo_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD, VDO_1ST_VSN, NULL, 0, NULL,
+	"Auto-extend a VDO pool when its usage exceeds this percent.\n"
+	"Setting this to 100 disables automatic extension.\n"
+	"The minimum value is 50 (a smaller value is treated as 50.)\n"
+	"Also see vdo_pool_autoextend_percent.\n"
+	"Automatic extension requires dmeventd to be monitoring the LV.\n"
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 10G\n"
+	"VDO pool exceeds 7G, it is extended to 12G, and when it exceeds\n"
+	"8.4G, it is extended to 14.4G:\n"
+	"vdo_pool_autoextend_threshold = 70\n"
+	"#\n")
+
+cfg(activation_vdo_pool_autoextend_percent_CFG, "vdo_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_POOL_AUTOEXTEND_PERCENT, VDO_1ST_VSN, NULL, 0, NULL,
+	"Auto-extending a VDO pool adds this percent extra space.\n"
+	"The amount of additional space added to a VDO pool is this\n"
+	"percent of its current size.\n"
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 10G\n"
+	"VDO pool exceeds 7G, it is extended to 12G, and when it exceeds\n"
+	"8.4G, it is extended to 14.4G:\n")
+
 cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
 	"While activating devices, I/O to devices being (re)configured is\n"
@@ -1965,6 +1989,20 @@ cfg(dmeventd_thin_command_CFG, "thin_command", dmeventd_CFG_SECTION, CFG_DEFAULT
 	"User handler is specified with the full path starting with '/'.\n")
 	/* TODO: systemd service handler */
 
+cfg(dmeventd_vdo_library_CFG, "vdo_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_VDO_LIB, VDO_1ST_VSN, NULL, 0, NULL,
+	"The library dmeventd uses when monitoring a VDO pool device.\n"
+	"libdevmapper-event-lvm2vdo.so monitors the filling of a pool\n"
+	"and emits a warning through syslog when the usage exceeds 80%. The\n"
+	"warning is repeated when 85%, 90% and 95% of the pool is filled.\n")
+
+cfg(dmeventd_vdo_command_CFG, "vdo_command", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_VDO_COMMAND, VDO_1ST_VSN, NULL, 0, NULL,
+	"The plugin runs command with each 5% increment when VDO pool volume\n"
+	"gets above 50%.\n"
+	"Command which starts with 'lvm ' prefix is internal lvm command.\n"
+	"You can write your own handler to customise behaviour in more details.\n"
+	"User handler is specified with the full path starting with '/'.\n")
+	/* TODO: systemd service handler */
+
 cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2d70f53..9928fb1 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -83,6 +83,8 @@
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
 #define DEFAULT_DMEVENTD_THIN_LIB "libdevmapper-event-lvm2thin.so"
 #define DEFAULT_DMEVENTD_THIN_COMMAND "lvm lvextend --use-policies"
+#define DEFAULT_DMEVENTD_VDO_LIB "libdevmapper-event-lvm2vdo.so"
+#define DEFAULT_DMEVENTD_VDO_COMMAND "lvm lvextend --use-policies"
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
@@ -295,5 +297,7 @@
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT 20
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
+#define DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD 100
+#define DEFAULT_VDO_POOL_AUTOEXTEND_PERCENT 20
 
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 80ddcfd..455ce5b 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -450,6 +450,38 @@ static int _vdo_modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+
+#  ifdef DMEVENTD
+/* FIXME Cache this */
+static int _vdo_pool_target_registered(struct lv_segment *seg, int *pending, int *monitored)
+{
+	return target_registered_with_dmeventd(seg->lv->vg->cmd,
+					       seg->segtype->dso,
+					       seg->lv, pending, monitored);
+}
+
+/* FIXME This gets run while suspended and performs banned operations. */
+static int _vdo_pool_target_set_events(struct lv_segment *seg, int evmask, int set)
+{
+	/* FIXME Make timeout (10) configurable */
+	return target_register_events(seg->lv->vg->cmd,
+				      seg->segtype->dso,
+				      seg->lv, evmask, set, 10);
+}
+
+static int _vdo_pool_target_register_events(struct lv_segment *seg,
+					    int events)
+{
+	return _vdo_pool_target_set_events(seg, events, 1);
+}
+
+static int _vdo_pool_target_unregister_events(struct lv_segment *seg,
+					      int events)
+{
+	return _vdo_pool_target_set_events(seg, events, 0);
+}
+
+#  endif /* DMEVENTD */
 #endif
 
 /* reused as _vdo_destroy */
@@ -487,6 +519,12 @@ static struct segtype_handler _vdo_pool_ops = {
 	.add_target_line = _vdo_pool_add_target_line,
 	.target_present = _vdo_target_present,
 	.modules_needed = _vdo_modules_needed,
+
+#  ifdef DMEVENTD
+	.target_monitored = _vdo_pool_target_registered,
+	.target_monitor_events = _vdo_pool_target_register_events,
+	.target_unmonitor_events = _vdo_pool_target_unregister_events,
+#  endif /* DMEVENTD */
 #endif
 	.destroy = _vdo_pool_destroy,
 };
@@ -515,6 +553,13 @@ int init_vdo_segtypes(struct cmd_context *cmd,
 	pool_segtype->name = SEG_TYPE_NAME_VDO_POOL;
 	pool_segtype->flags = SEG_VDO_POOL | SEG_ONLY_EXCLUSIVE;
 	pool_segtype->ops = &_vdo_pool_ops;
+#ifdef DEVMAPPER_SUPPORT
+#  ifdef DMEVENTD
+	pool_segtype->dso = get_monitor_dso_path(cmd, dmeventd_vdo_library_CFG);
+	if (pool_segtype->dso)
+		pool_segtype->flags |= SEG_MONITORED;
+#  endif /* DMEVENTD */
+#endif
 
 	if (!lvm_register_segtype(seglib, pool_segtype))
 		return_0;
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index b787d09..695d4dd 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -87,6 +87,9 @@ int lvm2_run(void *handle, const char *cmdline)
 	else if (!strcmp(cmdline, "_dmeventd_thin_command")) {
 		if (setenv(cmdline, find_config_tree_str(cmd, dmeventd_thin_command_CFG, NULL), 1))
 			ret = ECMD_FAILED;
+	} else if (!strcmp(cmdline, "_dmeventd_vdo_command")) {
+		if (setenv(cmdline, find_config_tree_str(cmd, dmeventd_vdo_command_CFG, NULL), 1))
+			ret = ECMD_FAILED;
 	} else
 		ret = lvm_run_command(cmd, argc, argv);
 


