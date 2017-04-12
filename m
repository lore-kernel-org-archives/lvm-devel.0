From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:39:01 -0400
Subject: master - fsadm: support configurable full path
Message-ID: <201704121939.v3CJd1L3012276@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3018cdcaa7aa258a432738b95077098985fb0c74
Commit:        3018cdcaa7aa258a432738b95077098985fb0c74
Parent:        109532290138d3b8b535457150052b6bda4f797c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 8 19:43:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:34:08 2017 +0200

fsadm: support configurable full path

Just like with other tools lvm2 is using allow to define
fully configurable path.

Default is selected by $PREFIX/sbin/fsadm
---
 WHATS_NEW                    |    1 +
 configure                    |    8 ++++++++
 configure.in                 |    4 ++++
 include/configure.h.in       |    3 +++
 lib/config/config_settings.h |    4 ++++
 lib/config/defaults.h        |    2 ++
 lib/metadata/lv_manip.c      |    8 ++++----
 7 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bc958e2..b0fc86f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.170 - 
 ==================================
+  Introduce global/fsadm_executable to make fsadm path configurable.
   Look for limited thin pool metadata size when using 16G metadata.
   Add lvconvert pool creation rule disallowing options with poolmetadata.
   Fix lvconvert when the same LV is incorrectly reused in options.
diff --git a/configure b/configure
index c3901d4..e691805 100755
--- a/configure
+++ b/configure
@@ -15319,6 +15319,14 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+
+FSADM_PATH="$lvm_exec_prefix/sbin/fsadm"
+
+cat >>confdefs.h <<_ACEOF
+#define FSADM_PATH "$FSADM_PATH"
+_ACEOF
+
+
 ################################################################################
 if test "$BUILD_DMEVENTD" = yes; then
 
diff --git a/configure.in b/configure.in
index 42ec52f..9c1dabe 100644
--- a/configure.in
+++ b/configure.in
@@ -1895,6 +1895,10 @@ test "$prefix" != NONE && clvmd_prefix=$prefix
 CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 
+
+FSADM_PATH="$lvm_exec_prefix/sbin/fsadm"
+AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
+
 ################################################################################
 dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
diff --git a/include/configure.h.in b/include/configure.h.in
index 04e7f4b..5172650 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -148,6 +148,9 @@
 /* Library version */
 #undef DM_LIB_VERSION
 
+/* Path to fsadm binary. */
+#undef FSADM_PATH
+
 /* Define to 1 if you have the `alarm' function. */
 #undef HAVE_ALARM
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b701722..3b0eebb 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1035,6 +1035,10 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
+cfg(global_fsadm_executable_CFG, "fsadm_executable", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FSADM_PATH, vsn(2, 2, 170), "@FSADM_PATH@", 0, NULL,
+	"The full path to the fsadm command.\n"
+	"LVM uses this command to help with lvresize -r operations.\n")
+
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
 	"The method LVM uses to set the local system ID.\n"
 	"Volume Groups can also be given a system ID (by vgcreate, vgchange,\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2340636..b5d9983 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -135,6 +135,8 @@
 #define DEFAULT_CACHE_METADATA_FORMAT CACHE_METADATA_FORMAT_UNSELECTED /* Autodetect */
 #define DEFAULT_CACHE_MODE "writethrough"
 
+#define DEFAULT_FSADM_PATH FSADM_PATH
+
 #define DEFAULT_UMASK 0077
 
 #define DEFAULT_FORMAT "lvm2"
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0dfbad4..50f5167 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4567,13 +4567,13 @@ static int _request_confirmation(const struct logical_volume *lv,
 }
 
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
-#define FSADM_CMD "fsadm"
+
 #define FSADM_CMD_MAX_ARGS 6
 #define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
 
 /*
- * FSADM_CMD --dry-run --verbose --force check lv_path
- * FSADM_CMD --dry-run --verbose --force resize lv_path size
+ * fsadm --dry-run --verbose --force check lv_path
+ * fsadm --dry-run --verbose --force resize lv_path size
  */
 static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 		      struct logical_volume *lv,
@@ -4588,7 +4588,7 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 	const char *argv[FSADM_CMD_MAX_ARGS + 2];
 	unsigned i = 0;
 
-	argv[i++] = FSADM_CMD;
+	argv[i++] = find_config_tree_str(cmd, global_fsadm_executable_CFG, NULL);
 
 	if (test_mode())
 		argv[i++] = "--dry-run";


