From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:48:44 -0000
Subject: LVM2 configure configure.in
Message-ID: <20100511084844.9157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:48:43

Modified files:
	.              : configure configure.in 

Log message:
	Add UDEV_PC and SELINUX_PC substituted variables

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/configure	2010/04/30 14:49:43	1.126
+++ LVM2/configure	2010/05/11 08:48:43	1.127
@@ -649,10 +649,12 @@
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
@@ -12327,7 +12329,7 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_udev_udev_queue_get_udev_is_active" >&5
 $as_echo "$ac_cv_lib_udev_udev_queue_get_udev_is_active" >&6; }
 if test "x$ac_cv_lib_udev_udev_queue_get_udev_is_active" = x""yes; then
-  UDEV_LIBS="-ludev"
+  UDEV_PC="libudev"; UDEV_LIBS="-ludev"
 else
   { { $as_echo "$as_me:$LINENO: error: bailing out... libudev library is required" >&5
 $as_echo "$as_me: error: bailing out... libudev library is required" >&2;}
@@ -13141,12 +13143,14 @@
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
 
@@ -15610,6 +15614,8 @@
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/04/30 13:58:10	1.136
+++ LVM2/configure.in	2010/05/11 08:48:43	1.137
@@ -659,7 +659,9 @@
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active, UDEV_LIBS="-ludev", AC_MSG_ERROR(bailing out... libudev library is required))
+	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active,
+		     [UDEV_PC="libudev"; UDEV_LIBS="-ludev"],
+		     [AC_MSG_ERROR([bailing out... libudev library is required])])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
 
@@ -831,9 +833,11 @@
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
 
@@ -1117,10 +1121,12 @@
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


