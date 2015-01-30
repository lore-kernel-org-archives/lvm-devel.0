From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:31:57 +0000 (UTC)
Subject: master - conf: add devices/external_device_info_source to lvm.conf
Message-ID: <20150130123157.5DA8361152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf8943b0f63336272f3434455b906e0167e27b52
Commit:        bf8943b0f63336272f3434455b906e0167e27b52
Parent:        c50a90c9e6084350682a315ed1732c2a54a3a828
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 15 16:27:33 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

conf: add devices/external_device_info_source to lvm.conf

---
 conf/example.conf.in           |   16 ++++++++++++++++
 lib/commands/toolcontext.c     |   11 +++++++++++
 lib/config/config_settings.h   |    1 +
 lib/config/defaults.h          |    1 +
 lib/filters/filter-composite.c |    2 +-
 lib/misc/lvm-globals.c         |   11 +++++++++++
 lib/misc/lvm-globals.h         |    2 ++
 7 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0ba9ccb..df28a7b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -39,6 +39,22 @@ devices {
     # to use with LVM2.
     scan = [ "/dev" ]
 
+    # Select external device information source to use for further and more
+    # detailed device determination. Some information may already be available
+    # in the system and LVM2 can use this information to determine the exact
+    # type or use of the device it processes. Using existing external device
+    # information source can speed up device processing as LVM2 does not need
+    # to run its own native routines to acquire this information. For example,
+    # such information is used to drive LVM2 filtering like MD component
+    # detection, multipath component detection, partition detection and others.
+    # Possible options are:
+    # "none"        - No external device information source is used.
+    #
+    # "udev"        - Reuse existing udev database records. Applicable
+    #                 only if LVM is compiled with udev support.
+    #
+    external_device_info_source = "none"
+
     # If set, the cache of block device nodes with all associated symlinks
     # will be constructed out of the existing udev database content.
     # This avoids using and opening any inapplicable non-block devices or
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 83238fb..e914e93 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -307,6 +307,7 @@ int process_profilable_config(struct cmd_context *cmd) {
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
+	const char *dev_ext_info_src;
 	const char *read_ahead;
 	struct stat st;
 	const struct dm_config_node *cn;
@@ -340,6 +341,16 @@ static int _process_config(struct cmd_context *cmd)
 		return_0;
 #endif
 
+	dev_ext_info_src = find_config_tree_str(cmd, devices_external_device_info_source_CFG, NULL);
+	if (!strcmp(dev_ext_info_src, "none"))
+		init_external_device_info_source(DEV_EXT_NONE);
+	else if (!strcmp(dev_ext_info_src, "udev"))
+		init_external_device_info_source(DEV_EXT_UDEV);
+	else {
+		log_error("Invalid external device info source specification.");
+		return 0;
+	}
+
 	/* proc dir */
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
 			 find_config_tree_str(cmd, global_proc_CFG, NULL)) < 0) {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8978b5b..52d7f0f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -91,6 +91,7 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL)
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL)
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL)
+cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 115), NULL)
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 1431de2..dfbfea8 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -30,6 +30,7 @@
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
+#define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 950705b..1a2e172 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -31,7 +31,7 @@ static int _and_p_with_dev_ext_info(struct dev_filter *f, struct device *dev)
 {
 	int r;
 
-	dev_ext_enable(dev, DEV_EXT_NONE);
+	dev_ext_enable(dev, external_device_info_source());
 	r = _and_p(f, dev);
 	dev_ext_disable(dev);
 
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index ee192b0..f0dab88 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -29,6 +29,7 @@ static int _md_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
+static unsigned _external_device_info_source = DEV_EXT_NONE;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _debug_classes_logged = DEFAULT_LOGGED_DEBUG_CLASSES;
@@ -89,6 +90,11 @@ void init_obtain_device_list_from_udev(int device_list_from_udev)
 	_obtain_device_list_from_udev = device_list_from_udev;
 }
 
+void init_external_device_info_source(unsigned src)
+{
+	_external_device_info_source = src;
+}
+
 void init_trust_cache(int trustcache)
 {
 	_trust_cache = trustcache;
@@ -230,6 +236,11 @@ int obtain_device_list_from_udev(void)
 	return _obtain_device_list_from_udev;
 }
 
+unsigned external_device_info_source(void)
+{
+	return _external_device_info_source;
+}
+
 int trust_cache(void)
 {
 	return _trust_cache;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 4af713b..4c4cc1a 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -26,6 +26,7 @@ void init_test(int level);
 void init_md_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
+void init_external_device_info_source(unsigned src);
 void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
@@ -56,6 +57,7 @@ int md_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
 int obtain_device_list_from_udev(void);
+unsigned external_device_info_source(void);
 int trust_cache(void);
 int verbose_level(void);
 int silent_mode(void);


