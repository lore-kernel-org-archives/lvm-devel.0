From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:30 +0000 (UTC)
Subject: master - sparse: configurable type for sparse volumes
Message-ID: <20141030230030.A11D360654@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0164f21886a5b4964110bcac65535a670fdf6f3
Commit:        e0164f21886a5b4964110bcac65535a670fdf6f3
Parent:        87f59af15ce315bb76ebaa176dd458295f607816
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 23:38:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:48 2014 +0100

sparse: configurable type for sparse volumes

Support compile type configurable defaults for creation
of sparse volumes.

By default now create 'thin-pools' for sparse volumes.
Use the global/sparse_segtype_default to switch back to old
snapshots if needed.

Apply the same compile logic for newly introduces mirror/raid1 options.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   22 ++++++++++++++++-
 configure.in                 |   52 +++++++++++++++++++++++++++++++++---------
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    5 +--
 lib/misc/configure.h.in      |    9 +++++++
 tools/lvcreate.c             |   16 +++++++++----
 7 files changed, 85 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5ad246c..e59e0f4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Configurable support for creation of sparse volumes with thin-pools.
   Update and correct lvcreate and lvcovert man pages.
   Mark pools and snapshots as unzeroable volumes.
   Check for zeroing of volume after segment type is fully detected.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index d1da23f..d1a1397 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -646,7 +646,7 @@ global {
     #
     # Specify the '--type <mirror|raid1>' option to override this default
     # setting.
-    mirror_segtype_default = "raid1"
+    mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
 
     # 'raid10_segtype_default' determines the segment types used by default
     # when the '--stripes/-i' and '--mirrors/-m' arguments are both specified
@@ -663,7 +663,25 @@ global {
     #            this setting is not advised.
     # Specify the '--type <raid10|mirror>' option to override this default
     # setting.
-    raid10_segtype_default = "raid10"
+    raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
+
+    # 'sparse_segtype_default' defines which segtype will be used when the
+    # shorthand '-V and -L' option is used for sparse volume creation.
+    #
+    # "snapshot" - The original snapshot implementation provided by LVM2/DM.
+    #		   It is using old snashot that mixes data and metadata within
+    #		   a single COW storage volume and has poor performs when
+    #		   the size of stored data passes hundereds of MB.
+    #
+    # "thin"     - Newer implementation leverages thin provisioning target.
+    #		   It has bigger minimal chunk size (64KiB) and uses separate volume
+    #		   for metadata. It has better performance especially in case of
+    #		   bigger data uses. This device type has also full snapshot support.
+    #
+    # Specify the '--type <snapshot|thin>' option to override this default
+    # setting.
+    sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
+
 
     # The default format for displaying LV names in lvdisplay was changed 
     # in version 2.02.89 to show the LV name and path separately.
diff --git a/configure.in b/configure.in
index 8d47bc7..9e10dc3 100644
--- a/configure.in
+++ b/configure.in
@@ -349,13 +349,29 @@ AC_ARG_WITH(raid,
 	    RAID=$withval, RAID=internal)
 AC_MSG_RESULT($RAID)
 
+AC_ARG_WITH(default-mirror-segtype,
+	    AC_HELP_STRING([--with-default-mirror-segtype=TYPE],
+			   [default mirror segtype: raid1/mirror [raid1]]),
+			   DEFAULT_MIRROR_SEGTYPE=$withval, DEFAULT_MIRROR_SEGTYPE="raid1")
+AC_ARG_WITH(default-raid10r-segtype,
+	    AC_HELP_STRING([--with-default-raid10-segtype=TYPE],
+			   [default mirror segtype: raid10/mirror [raid10]]),
+			   DEFAULT_RAID10_SEGTYPE=$withval, DEFAULT_RAID10_SEGTYPE="raid10")
 case "$RAID" in
-  none|shared) ;;
+  none)  test "$DEFAULT_MIRROR_SEGTYPE" = "raid1" && DEFAULT_MIRROR_SEGTYPE="mirror"
+	test "$DEFAULT_RAID10_SEGTYPE" = "raid10" && DEFAULT_RAID10_SEGTYPE="mirror" ;;
+  shared) ;;
   internal) AC_DEFINE([RAID_INTERNAL], 1,
 		      [Define to 1 to include built-in support for raid.]) ;;
   *) AC_MSG_ERROR([--with-raid parameter invalid]) ;;
 esac
 
+AC_DEFINE_UNQUOTED([DEFAULT_MIRROR_SEGTYPE], ["$DEFAULT_MIRROR_SEGTYPE"],
+		   [Default segtype used for mirror volumes.])
+
+AC_DEFINE_UNQUOTED([DEFAULT_RAID10_SEGTYPE], ["$DEFAULT_RAID10_SEGTYPE"],
+		   [Default segtype used for raid10 volumes.])
+
 ################################################################################
 dnl -- asynchronous volume replicator inclusion type
 AC_MSG_CHECKING(whether to include replicators)
@@ -372,6 +388,12 @@ case "$REPLICATORS" in
   *) AC_MSG_ERROR([--with-replicators parameter invalid ($REPLICATORS)]) ;;
 esac
 
+
+AC_ARG_WITH(default-sparse-segtype,
+	    AC_HELP_STRING([--with-default-sparse-segtype=TYPE],
+			   [default sparse segtype: thin/snapshot [thin]]),
+			   DEFAULT_SPARSE_SEGTYPE=$withval, DEFAULT_SPARSE_SEGTYPE="thin")
+
 ################################################################################
 dnl -- thin provisioning
 AC_MSG_CHECKING(whether to include thin provisioning)
@@ -399,12 +421,16 @@ AC_ARG_WITH(thin-restore,
 AC_MSG_RESULT($THIN)
 
 case "$THIN" in
-  none|shared) ;;
+  none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
+  shared) ;;
   internal) AC_DEFINE([THIN_INTERNAL], 1,
 		      [Define to 1 to include built-in support for thin provisioning.]) ;;
   *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
 esac
 
+AC_DEFINE_UNQUOTED([DEFAULT_SPARSE_SEGTYPE], ["$DEFAULT_SPARSE_SEGTYPE"],
+		   [Default segtype used for sparse volumes.])
+
 dnl -- thin_check needs-check flag
 AC_ARG_ENABLE(thin_check_needs_check,
 	      AC_HELP_STRING([--disable-thin_check_needs_check],
@@ -466,15 +492,16 @@ case "$THIN" in
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
+
+	AC_MSG_CHECKING([whether thin_check supports the needs-check flag])
+	AC_MSG_RESULT([$THIN_CHECK_NEEDS_CHECK])
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+		AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
+	fi
+
 	;;
 esac
 
-AC_MSG_CHECKING([whether thin_check supports the needs-check flag])
-AC_MSG_RESULT([$THIN_CHECK_NEEDS_CHECK])
-if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
-	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
-fi
-
 AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
 		   [The path to 'thin_check', if available.])
 
@@ -1645,16 +1672,19 @@ AC_SUBST(CPG_CFLAGS)
 AC_SUBST(CPG_LIBS)
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
-AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
-AC_SUBST(DEFAULT_PROFILE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
-AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
+AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_MIRROR_SEGTYPE)
 AC_SUBST(DEFAULT_PID_DIR)
+AC_SUBST(DEFAULT_PROFILE_SUBDIR)
+AC_SUBST(DEFAULT_RAID10_SEGTYPE)
 AC_SUBST(DEFAULT_RUN_DIR)
+AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
+AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a6c1d1b..e944b81 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -175,6 +175,7 @@ cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_co
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL)
 cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), NULL)
 cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), NULL)
+cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), NULL)
 cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL)
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL)
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2724cd1..acf768b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -52,13 +52,12 @@
 #define DEFAULT_METADATA_READ_ONLY 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
-#define DEFAULT_MIRROR_SEGTYPE "raid1"
 #define DEFAULT_MIRRORLOG MIRROR_LOG_DISK
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
-#define DEFAULT_RAID10_SEGTYPE "raid10"
 #define DEFAULT_RAID_FAULT_POLICY "warn"
+
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index f137f14..7c0d64c 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -68,18 +68,27 @@
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
+/* Default segtype used for mirror volumes. */
+#undef DEFAULT_MIRROR_SEGTYPE
+
 /* Default directory to keep PID files in. */
 #undef DEFAULT_PID_DIR
 
 /* Name of default configuration profile subdirectory. */
 #undef DEFAULT_PROFILE_SUBDIR
 
+/* Default segtype used for raid10 volumes. */
+#undef DEFAULT_RAID10_SEGTYPE
+
 /* Default LVM run directory. */
 #undef DEFAULT_RUN_DIR
 
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
 #undef DEFAULT_SI_UNIT_CONSISTENCY
 
+/* Default segtype used for sparse volumes. */
+#undef DEFAULT_SPARSE_SEGTYPE
+
 /* Path to LVM system directory. */
 #undef DEFAULT_SYS_DIR
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 78b6898..e507858 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -644,15 +644,21 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					 -1))
 			return_0;
 	/* More estimations from options after shortcuts */
-	} else if (arg_is_set(cmd, snapshot_ARG))
+	} else if (arg_is_set(cmd, snapshot_ARG) &&
+		   (arg_is_set(cmd, virtualoriginsize_ARG) ||
+		   !arg_is_set(cmd, virtualsize_ARG)))
 		/* Snapshot has higher priority then thin */
 		segtype_str = "snapshot"; /* --thinpool makes thin volume */
-	else if (arg_is_set(cmd, cache_ARG) || arg_count(cmd, cachepool_ARG))
+	else if (arg_is_set(cmd, cache_ARG) || arg_is_set(cmd, cachepool_ARG))
 		segtype_str = "cache";
-	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG) ||
-		 arg_is_set(cmd, virtualsize_ARG))
+	else if (arg_is_set(cmd, thin_ARG) || arg_is_set(cmd, thinpool_ARG))
 		segtype_str = "thin";
-	else if (arg_uint_value(cmd, mirrors_ARG, 0)) {
+	else if (arg_is_set(cmd, virtualsize_ARG)) {
+		if (arg_is_set(cmd, virtualoriginsize_ARG))
+			segtype_str = "snapshot";
+		else
+			segtype_str = find_config_tree_str(cmd, global_sparse_segtype_default_CFG, NULL);
+	} else if (arg_uint_value(cmd, mirrors_ARG, 0)) {
 		/* Remember, '-m 0' implies stripe */
 		mirror_default_cfg = (arg_uint_value(cmd, stripes_ARG, 1) > 1)
 			? global_raid10_segtype_default_CFG : global_mirror_segtype_default_CFG;


