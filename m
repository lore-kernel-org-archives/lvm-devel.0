From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 12:12:35 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20100304121235.21084.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 12:12:34

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	libdm          : Makefile.in 
	tools          : Makefile.in 

Log message:
	Use UDEV_LIBS, and link -ludev only when needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1453&r2=1.1454
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/WHATS_NEW	2010/03/04 12:10:40	1.1453
+++ LVM2/WHATS_NEW	2010/03/04 12:12:34	1.1454
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Define and use internal makefile variable UDEV_LIBS.
   Define and use internal makefile variable DL_LIBS.
   Update check for selinux libraries and link them only when needed.
   Define and use internal makefile variable SELINUX_LIBS and STATIC_LIBS.
--- LVM2/configure	2010/03/04 12:10:40	1.120
+++ LVM2/configure	2010/03/04 12:12:34	1.121
@@ -648,6 +648,7 @@
 interface
 UDEV_SYNC
 UDEV_RULES
+UDEV_LIBS
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
@@ -12307,8 +12308,9 @@
 #define HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE 1
 _ACEOF
 
-			LIBS="-ludev $LIBS"
+			UDEV_LIBS="-ludev"
 		else
+			UDEV_LIBS=
 			{ $as_echo "$as_me:$LINENO: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&5
 $as_echo "$as_me: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&2;}
 		fi
@@ -15561,6 +15563,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/03/04 12:10:40	1.130
+++ LVM2/configure.in	2010/03/04 12:12:34	1.131
@@ -668,8 +668,9 @@
 		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
 			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
 			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
-			LIBS="-ludev $LIBS"
+			UDEV_LIBS="-ludev"
 		else
+			UDEV_LIBS=
 			AC_MSG_WARN(It won't be possible to get udev state. We will assume that udev is not running.)
 		fi
 fi
@@ -1120,6 +1121,7 @@
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
+AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(interface)
--- LVM2/make.tmpl.in	2010/03/04 12:10:40	1.82
+++ LVM2/make.tmpl.in	2010/03/04 12:12:34	1.83
@@ -31,7 +31,7 @@
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(SELINUX_LIBS)
+STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS)
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
@@ -43,6 +43,7 @@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+UDEV_LIBS = @UDEV_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
--- LVM2/libdm/Makefile.in	2010/03/04 12:08:27	1.49
+++ LVM2/libdm/Makefile.in	2010/03/04 12:12:34	1.50
@@ -52,7 +52,7 @@
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-LIBS += $(SELINUX_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS)
 
 device-mapper: all
 
--- LVM2/tools/Makefile.in	2010/03/04 12:08:27	1.110
+++ LVM2/tools/Makefile.in	2010/03/04 12:12:34	1.111
@@ -107,6 +107,8 @@
 
 include $(top_builddir)/make.tmpl
 
+LIBS += $(UDEV_LIBS)
+
 device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)


