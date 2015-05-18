From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:24 +0000 (UTC)
Subject: master - configure: move DEFS to configure.h
Message-ID: <20150518105224.E282B60EF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe00b163d67a6ec9c113fdc9c5ed06ad1d72c6d5
Commit:        fe00b163d67a6ec9c113fdc9c5ed06ad1d72c6d5
Parent:        76cc477fbabf2ee7ceea48950cd1db32eb2e5fca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:36:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:43:25 2015 +0200

configure: move DEFS to configure.h

---
 configure               |   58 +++++++++++++++++++++++++++++++---------------
 configure.in            |   27 ++++++++++-----------
 lib/misc/configure.h.in |   21 +++++++++++++++++
 libdm/Makefile.in       |    3 --
 make.tmpl.in            |   13 ----------
 5 files changed, 73 insertions(+), 49 deletions(-)

diff --git a/configure b/configure
index c4d714b..3b2b7ba 100755
--- a/configure
+++ b/configure
@@ -677,11 +677,9 @@ LVM_LIBAPI
 LVM_VERSION
 LVM1_FALLBACK
 LVM1
-LOCALEDIR
 LIB_SUFFIX
 LDDEPS
 JOBS
-INTL_PACKAGE
 INTL
 HAVE_VALGRIND
 HAVE_REALTIME
@@ -691,11 +689,6 @@ FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
 DM_LIB_VERSION
-DM_IOCTLS
-DM_DEVICE_UID
-DM_DEVICE_MODE
-DM_DEVICE_GID
-DM_COMPAT
 DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
@@ -7363,6 +7356,11 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_UID" >&5
 $as_echo "$DM_DEVICE_UID" >&6; }
 
+cat >>confdefs.h <<_ACEOF
+#define DM_DEVICE_UID $DM_DEVICE_UID
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking device node gid" >&5
 $as_echo_n "checking device node gid... " >&6; }
@@ -7378,6 +7376,11 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_GID" >&5
 $as_echo "$DM_DEVICE_GID" >&6; }
 
+cat >>confdefs.h <<_ACEOF
+#define DM_DEVICE_GID $DM_DEVICE_GID
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking device node mode" >&5
 $as_echo_n "checking device node mode... " >&6; }
@@ -7393,6 +7396,11 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_MODE" >&5
 $as_echo "$DM_DEVICE_MODE" >&6; }
 
+cat >>confdefs.h <<_ACEOF
+#define DM_DEVICE_MODE $DM_DEVICE_MODE
+_ACEOF
+
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking when to create device nodes" >&5
 $as_echo_n "checking when to create device nodes... " >&6; }
 
@@ -11303,8 +11311,11 @@ else
 fi
 
 
-if test "$DM_COMPAT" = yes; then
-	as_fn_error $? "--enable-compat is not currently supported.
+if test "$DM_COMPAT" = yes; then :
+
+$as_echo "#define DM_COMPAT 1" >>confdefs.h
+
+      as_fn_error $? "--enable-compat is not currently supported.
 Since device-mapper version 1.02.66, only one version (4) of the device-mapper
 ioctl protocol is supported." "$LINENO" 5
 fi
@@ -11330,6 +11341,11 @@ if test "${enable_ioctl+set}" = set; then :
   enableval=$enable_ioctl; DM_IOCTLS=$enableval
 fi
 
+if test "$DM_IOCTLS" = yes; then :
+
+$as_echo "#define DM_IOCTLS 1" >>confdefs.h
+
+fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable O_DIRECT" >&5
@@ -12408,9 +12424,10 @@ else
   MSGFMT="$ac_cv_path_MSGFMT"
 fi
 
-	if [ -z "$MSGFMT" ]; then
-		as_fn_error $? "msgfmt not found in path $PATH" "$LINENO" 5
-	fi
+
+	if test -z "$MSGFMT"]; then :
+  as_fn_error $? "msgfmt not found in path $PATH" "$LINENO" 5
+fi
 
 
 # Check whether --with-localedir was given.
@@ -12420,6 +12437,16 @@ else
   LOCALEDIR='${prefix}/share/locale'
 fi
 
+
+cat >>confdefs.h <<_ACEOF
+#define INTL_PACKAGE "$INTL_PACKAGE"
+_ACEOF
+
+
+cat >>confdefs.h <<_ACEOF
+#define LOCALEDIR "$LOCALEDIR"
+_ACEOF
+
 fi
 
 ################################################################################
@@ -13237,13 +13264,6 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
-
-
-
-
-
-
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat@.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 161f832..ba0b236 100644
--- a/configure.in
+++ b/configure.in
@@ -201,6 +201,7 @@ AC_ARG_WITH(device-uid,
 			   [set the owner used for new device nodes [UID=0]]),
 	    DM_DEVICE_UID=$withval, DM_DEVICE_UID=0)
 AC_MSG_RESULT($DM_DEVICE_UID)
+AC_DEFINE_UNQUOTED([DM_DEVICE_UID], [$DM_DEVICE_UID], [Define default owner for device node])
 
 ################################################################################
 dnl -- Setup device group ownership
@@ -211,6 +212,7 @@ AC_ARG_WITH(device-gid,
 			   [set the group used for new device nodes [GID=0]]),
 	    DM_DEVICE_GID=$withval, DM_DEVICE_GID=0)
 AC_MSG_RESULT($DM_DEVICE_GID)
+AC_DEFINE_UNQUOTED([DM_DEVICE_GID], [$DM_DEVICE_GID], [Define default group for device node])
 
 ################################################################################
 dnl -- Setup device mode
@@ -221,6 +223,7 @@ AC_ARG_WITH(device-mode,
 			   [set the mode used for new device nodes [MODE=0600]]),
 	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
 AC_MSG_RESULT($DM_DEVICE_MODE)
+AC_DEFINE_UNQUOTED([DM_DEVICE_MODE], [$DM_DEVICE_MODE], [Define default mode for device node])
 
 AC_MSG_CHECKING(when to create device nodes)
 AC_ARG_WITH(device-nodes-on,
@@ -1224,11 +1227,11 @@ AC_ARG_ENABLE(compat,
 			     [enable support for old device-mapper versions]),
 	      DM_COMPAT=$enableval, DM_COMPAT=no)
 
-if test "$DM_COMPAT" = yes; then
-	AC_MSG_ERROR([--enable-compat is not currently supported.
+AS_IF([test "$DM_COMPAT" = yes],
+      [AC_DEFINE([DM_COMPAT], 1, [Define to enable compat protocol])
+      AC_MSG_ERROR([--enable-compat is not currently supported.
 Since device-mapper version 1.02.66, only one version (4) of the device-mapper
-ioctl protocol is supported.])
-fi
+ioctl protocol is supported.])])
 
 ################################################################################
 dnl -- Compatible units suffix mode
@@ -1248,6 +1251,8 @@ AC_ARG_ENABLE(ioctl,
 	      AC_HELP_STRING([--disable-ioctl],
 			     [disable ioctl calls to device-mapper in the kernel]),
 	      DM_IOCTLS=$enableval)
+AS_IF([test "$DM_IOCTLS" = yes],
+      [AC_DEFINE([DM_IOCTLS], 1, [Define to enable ioctls calls to kernel])])
 
 ################################################################################
 dnl -- Disable O_DIRECT
@@ -1506,14 +1511,15 @@ if test "$INTL" = yes; then
 # FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
 	AC_PATH_TOOL(MSGFMT, msgfmt)
-	if [[ -z "$MSGFMT" ]]; then
-		AC_MSG_ERROR([msgfmt not found in path $PATH])
-	fi
+
+	AS_IF(test -z "$MSGFMT"], [AC_MSG_ERROR([msgfmt not found in path $PATH])])
 
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
 				   [translation files in DIR [PREFIX/share/locale]]),
 		    LOCALEDIR=$withval, LOCALEDIR='${prefix}/share/locale')
+	AC_DEFINE_UNQUOTED([INTL_PACKAGE], ["$INTL_PACKAGE"], [Internalization package])
+	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$LOCALEDIR"], [Location of transaltion files])
 fi
 
 ################################################################################
@@ -1784,11 +1790,6 @@ AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DMEVENTD_PATH)
-AC_SUBST(DM_COMPAT)
-AC_SUBST(DM_DEVICE_GID)
-AC_SUBST(DM_DEVICE_MODE)
-AC_SUBST(DM_DEVICE_UID)
-AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
@@ -1798,12 +1799,10 @@ AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_VALGRIND)
 AC_SUBST(INTL)
-AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
 AC_SUBST(LIB_SUFFIX)
-AC_SUBST(LOCALEDIR)
 AC_SUBST(LVM1)
 AC_SUBST(LVM1_FALLBACK)
 AC_SUBST(LVM_VERSION)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index f28cc79..2f17190 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -113,6 +113,21 @@
 /* Path to dmeventd pidfile. */
 #undef DMEVENTD_PIDFILE
 
+/* Define to enable compat protocol */
+#undef DM_COMPAT
+
+/* Define default group for device node */
+#undef DM_DEVICE_GID
+
+/* Define default mode for device node */
+#undef DM_DEVICE_MODE
+
+/* Define default owner for device node */
+#undef DM_DEVICE_UID
+
+/* Define to enable ioctls calls to kernel */
+#undef DM_IOCTLS
+
 /* Library version */
 #undef DM_LIB_VERSION
 
@@ -489,6 +504,12 @@
 /* Define to 1 if `vfork' works. */
 #undef HAVE_WORKING_VFORK
 
+/* Internalization package */
+#undef INTL_PACKAGE
+
+/* Location of transaltion files */
+#undef LOCALEDIR
+
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing
    slash. */
 #undef LSTAT_FOLLOWS_SLASHED_SYMLINK
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 852cab0..c1d7871 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -53,9 +53,6 @@ include $(top_builddir)/make.tmpl
 
 CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
-DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
-	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
-
 LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS)
 
 device-mapper: all
diff --git a/make.tmpl.in b/make.tmpl.in
index 33d79c2..2206cc2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -224,11 +224,6 @@ endif
 # end of fPIC protection
 endif
 
-
-ifeq ("@INTL@", "yes")
-  DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
-endif
-
 LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 
@@ -241,14 +236,6 @@ ifeq ("@DMEVENTD@", "yes")
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
 
-ifeq ("@DM_COMPAT@", "yes")
-  DEFS += -DDM_COMPAT
-endif
-
-ifeq ("@DM_IOCTLS@", "yes")
-  DEFS += -DDM_IOCTLS
-endif
-
 # Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
 #DEFS += -DDEBUG_POOL
 # Default pool locking is using the crc checksum. With mprotect memory


