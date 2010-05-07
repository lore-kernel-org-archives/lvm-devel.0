From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:54 +0200
Subject: [PATCH 7/9] Add UDEV_PC and SELINUX_PC subst variables
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <28c6c495cc0eb1c4bba127150976c2005cf46df3.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use UDEV_PC and SELINUX_PC later in Requires.private: .pc files.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure    |    8 +++++++-
 configure.in |    8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index f0ce691..2f8781c 100755
--- a/configure
+++ b/configure
@@ -649,10 +649,12 @@ interface
 WRITE_INSTALL
 UDEV_SYNC
 UDEV_RULES
+UDEV_PC
 UDEV_LIBS
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
+SELINUX_PC
 SELINUX_LIBS
 READLINE_LIBS
 PTHREAD_LIBS
@@ -12327,7 +12329,7 @@ fi
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_udev_udev_queue_get_udev_is_active" >&5
 $as_echo "$ac_cv_lib_udev_udev_queue_get_udev_is_active" >&6; }
 if test "x$ac_cv_lib_udev_udev_queue_get_udev_is_active" = x""yes; then
-  UDEV_LIBS="-ludev"
+  UDEV_PC="libudev"; UDEV_LIBS="-ludev"
 else
   { { $as_echo "$as_me:$LINENO: error: bailing out... libudev library is required" >&5
 $as_echo "$as_me: error: bailing out... libudev library is required" >&2;}
@@ -13141,12 +13143,14 @@ cat >>confdefs.h <<\_ACEOF
 _ACEOF
 
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
+		SELINUX_PC="libselinux"
 		HAVE_SELINUX=yes
 else
 
 		{ $as_echo "$as_me:$LINENO: WARNING: Disabling selinux" >&5
 $as_echo "$as_me: WARNING: Disabling selinux" >&2;}
 		SELINUX_LIBS=
+		SELINUX_PC=
 		HAVE_SELINUX=no
 fi
 
@@ -15610,6 +15614,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
diff --git a/configure.in b/configure.in
index 4594559..b2a6e0c 100644
--- a/configure.in
+++ b/configure.in
@@ -659,7 +659,9 @@ UDEV_SYNC=$enableval, UDEV_SYNC=no)
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active, UDEV_LIBS="-ludev", AC_MSG_ERROR(bailing out... libudev library is required))
+	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active,
+		     [UDEV_PC="libudev"; UDEV_LIBS="-ludev"],
+		     [AC_MSG_ERROR([bailing out... libudev library is required])])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
 
@@ -831,9 +833,11 @@ if test x$SELINUX = xyes; then
 		AC_CHECK_HEADERS([selinux/selinux.h],, hard_bailout)
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
+		SELINUX_PC="libselinux"
 		HAVE_SELINUX=yes ], [
 		AC_MSG_WARN(Disabling selinux)
 		SELINUX_LIBS=
+		SELINUX_PC=
 		HAVE_SELINUX=no ])
 fi
 
@@ -1117,10 +1121,12 @@ AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
 AC_SUBST(SELINUX_LIBS)
+AC_SUBST(SELINUX_PC)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_LIBS)
+AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(WRITE_INSTALL)
-- 
1.7.0.1


