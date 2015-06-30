From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Jun 2015 12:11:14 +0000 (UTC)
Subject: master - configure: set DEFAULT_FALLBACK_TO_LVM1 in configure and use it in config_settings.h
Message-ID: <20150630121114.D5BAF60EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89d355ea04560dba54aa8b7b5a20950b9eb3f653
Commit:        89d355ea04560dba54aa8b7b5a20950b9eb3f653
Parent:        d7b9349ce71f2747eb7d0a8992244bc3d34719be
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 30 14:09:00 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 30 14:09:05 2015 +0200

configure: set DEFAULT_FALLBACK_TO_LVM1 in configure and use it in config_settings.h

Just like we have DEFAULT_USE_LVMETAD (or DEFUALT_USE_LVMPOLLD), use
fallback_to_lvm1=1 lvm.conf setting if we configured lvm2 with
--enable-lvm1-fallback and use fallback_to_lvm1=0 otherwise.

Also, generate proper lvm.conf.in with unconfigured value.
---
 conf/example.conf.in         |    2 +-
 configure                    |   10 ++++++++++
 configure.in                 |    6 ++++++
 lib/config/config_settings.h |    2 +-
 lib/config/defaults.h        |    6 ------
 lib/misc/configure.h.in      |    4 ++++
 6 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4520162..9af58db 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -602,7 +602,7 @@ global {
 	# The LVM1 tools need to be installed with .lvm1 suffices,
 	# e.g. vgscan.lvm1. They will stop working once the lvm2
 	# on-disk metadata format is used.
-	# fallback_to_lvm1 = 1
+	# fallback_to_lvm1 = @DEFAULT_FALLBACK_TO_LVM1@
 
 	# Configuration option global/format.
 	# The default metadata format that commands should use.
diff --git a/configure b/configure
index 13d10c4..13e40f8 100755
--- a/configure
+++ b/configure
@@ -703,6 +703,7 @@ DEFAULT_RAID10_SEGTYPE
 DEFAULT_PROFILE_SUBDIR
 DEFAULT_PID_DIR
 DEFAULT_MIRROR_SEGTYPE
+DEFAULT_FALLBACK_TO_LVM1
 DEFAULT_LOCK_DIR
 DEFAULT_DM_RUN_DIR
 DEFAULT_DATA_ALIGNMENT
@@ -7462,11 +7463,19 @@ fi
 $as_echo "$LVM1_FALLBACK" >&6; }
 
 if test "$LVM1_FALLBACK" = yes; then
+	DEFAULT_FALLBACK_TO_LVM1=1
 
 $as_echo "#define LVM1_FALLBACK 1" >>confdefs.h
 
+else
+	DEFAULT_FALLBACK_TO_LVM1=0
 fi
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_FALLBACK_TO_LVM1 $DEFAULT_FALLBACK_TO_LVM1
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include support for lvm1 metadata" >&5
 $as_echo_n "checking whether to include support for lvm1 metadata... " >&6; }
@@ -13276,6 +13285,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index d330bd2..0c310ca 100644
--- a/configure.in
+++ b/configure.in
@@ -263,8 +263,13 @@ AC_ARG_ENABLE(lvm1_fallback,
 AC_MSG_RESULT($LVM1_FALLBACK)
 
 if test "$LVM1_FALLBACK" = yes; then
+	DEFAULT_FALLBACK_TO_LVM1=1
 	AC_DEFINE([LVM1_FALLBACK], 1, [Define to 1 if 'lvm' should fall back to using LVM1 binaries if device-mapper is missing from the kernel])
+else
+	DEFAULT_FALLBACK_TO_LVM1=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_FALLBACK_TO_LVM1, [$DEFAULT_FALLBACK_TO_LVM1],
+		   [Fall back to LVM1 by default if device-mapper is missing from the kernel.])
 
 ################################################################################
 dnl -- format1 inclusion type
@@ -1782,6 +1787,7 @@ AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
 AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_FALLBACK_TO_LVM1)
 AC_SUBST(DEFAULT_MIRROR_SEGTYPE)
 AC_SUBST(DEFAULT_PID_DIR)
 AC_SUBST(DEFAULT_PROFILE_SUBDIR)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fb05b85..cac1978 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -628,7 +628,7 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"is not present in the kernel, disabling this should suppress\n"
 	"the error messages.\n")
 
-cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL, 0, NULL,
+cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), "@DEFAULT_FALLBACK_TO_LVM1@", 0, NULL,
 	"Try running LVM1 tools if LVM cannot communicate with DM.\n"
 	"This option only applies to 2.4 kernels and is provided to\n"
 	"help switch between device-mapper kernels and LVM1 kernels.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3745639..2d74c17 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -111,12 +111,6 @@
 
 #define DEFAULT_UMASK 0077
 
-#ifdef LVM1_FALLBACK
-#  define DEFAULT_FALLBACK_TO_LVM1 1
-#else
-#  define DEFAULT_FALLBACK_TO_LVM1 0
-#endif
-
 #define DEFAULT_FORMAT "lvm2"
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 9ec997f..6daf105 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -68,6 +68,10 @@
 /* Default system configuration directory. */
 #undef DEFAULT_ETC_DIR
 
+/* Fall back to LVM1 by default if device-mapper is missing from the kernel.
+   */
+#undef DEFAULT_FALLBACK_TO_LVM1
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 


