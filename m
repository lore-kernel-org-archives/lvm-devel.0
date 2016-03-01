From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  1 Mar 2016 17:13:27 +0000 (UTC)
Subject: master - pvs: replace 'unknown device' with [unknown]
Message-ID: <20160301171327.B7B86610F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57cd94b9e3b74c65f34eb2c40096cbbac024e986
Commit:        57cd94b9e3b74c65f34eb2c40096cbbac024e986
Parent:        afae3355f8e79b8fab8d5bc45f99caf0d8b2420c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 29 13:38:31 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 1 11:12:03 2016 -0600

pvs: replace 'unknown device' with [unknown]

A config setting can restore the old string.
---
 lib/commands/toolcontext.c   |    3 +++
 lib/config/config_settings.h |    4 ++++
 lib/config/defaults.h        |    1 +
 lib/device/dev-cache.c       |    2 +-
 lib/misc/lvm-globals.c       |   12 ++++++++++++
 lib/misc/lvm-globals.h       |    2 ++
 6 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1d7ca58..7f6eee4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -675,6 +675,9 @@ static int _process_config(struct cmd_context *cmd)
 	if (!process_profilable_config(cmd))
 		return_0;
 
+	if (find_config_tree_bool(cmd, report_two_word_unknown_device_CFG, NULL))
+		init_unknown_device_name("unknown device");
+
 	init_detect_internal_vg_cache_corruption
 		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1143c8b..95eb8ee 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1682,6 +1682,10 @@ cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, C
 cfg(report_mark_hidden_devices_CFG, "mark_hidden_devices", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 140), NULL, 0, NULL,
 	"Use brackets [] to mark hidden devices.\n")
 
+cfg(report_two_word_unknown_device_CFG, "two_word_unknown_device", report_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 146), NULL, 0, NULL,
+	"Use the two words 'unknown device' in place of '[unknown]'.\n"
+	"This is displayed when the device for a PV is not known.\n")
+
 cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
 	"libdevmapper-event-lvm2mirror.so attempts to recover from\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 080c3ff..648a168 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -56,6 +56,7 @@
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
+#define DEFAULT_UNKNOWN_DEVICE_NAME "[unknown]"
 
 #define DEFAULT_SANLOCK_LV_EXTEND_MB 256
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 6358109..47ae140 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1108,5 +1108,5 @@ int dev_fd(struct device *dev)
 const char *dev_name(const struct device *dev)
 {
 	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
-	    "unknown device";
+	    unknown_device_name();
 }
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 020640e..b7af353 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -55,6 +55,7 @@ static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 static int _detect_internal_vg_cache_corruption =
 	DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION;
+static const char *_unknown_device_name = DEFAULT_UNKNOWN_DEVICE_NAME;
 
 void init_verbose(int level)
 {
@@ -379,3 +380,14 @@ int detect_internal_vg_cache_corruption(void)
 {
 	return _detect_internal_vg_cache_corruption;
 }
+
+const char *unknown_device_name(void)
+{
+	return _unknown_device_name;
+}
+
+void init_unknown_device_name(const char *name)
+{
+	_unknown_device_name = name;
+}
+
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 387a4ae..77c01b4 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -52,6 +52,7 @@ void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_detect_internal_vg_cache_corruption(int detect);
 void init_retry_deactivation(int retry);
+void init_unknown_device_name(const char *name);
 
 void set_cmd_name(const char *cmd_name);
 const char *get_cmd_name(void);
@@ -84,6 +85,7 @@ uint64_t pv_min_size(void);
 int activation_checks(void);
 int detect_internal_vg_cache_corruption(void);
 int retry_deactivation(void);
+const char *unknown_device_name(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);


