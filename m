From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jan 2007 20:31:09 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20070109203109.7120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-09 20:31:08

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	lib/activate   : dev_manager.c 

Log message:
	Add configure --with-dmdir to compile against a device-mapper source tree.
	Use no flush suspending for mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.527&r2=1.528
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/WHATS_NEW	2007/01/08 14:24:20	1.527
+++ LVM2/WHATS_NEW	2007/01/09 20:31:08	1.528
@@ -1,5 +1,7 @@
 Version 2.02.18 -
 ====================================
+  Add configure --with-dmdir to compile against a device-mapper source tree.
+  Use no flush suspending for mirrors.
   Add dmeventd_mirror register_mutex, tidy initialisation & add memlock.
   Fix create mirror with name longer than 22 chars.
   Fix some activate.c prototypes when compiled without devmapper.
--- LVM2/configure	2006/11/20 20:03:26	1.55
+++ LVM2/configure	2007/01/09 20:31:08	1.56
@@ -310,7 +310,7 @@
 #endif"
 
 ac_default_prefix=/usr
-ac_subst_vars='SHELL PATH_SEPARATOR PACKAGE_NAME PACKAGE_TARNAME PACKAGE_VERSION PACKAGE_STRING PACKAGE_BUGREPORT exec_prefix prefix program_transform_name bindir sbindir libexecdir datadir sysconfdir sharedstatedir localstatedir libdir includedir oldincludedir infodir mandir build_alias host_alias target_alias DEFS ECHO_C ECHO_N ECHO_T LIBS build build_cpu build_vendor build_os host host_cpu host_vendor host_os target target_cpu target_vendor target_os AWK CC CFLAGS LDFLAGS CPPFLAGS ac_ct_CC EXEEXT OBJEXT INSTALL_PROGRAM INSTALL_SCRIPT INSTALL_DATA LN_S SET_MAKE RANLIB ac_ct_RANLIB CFLOW_CMD CSCOPE_CMD CPP EGREP ALLOCA LIBOBJS POW_LIB MSGFMT MODPROBE_CMD JOBS STATIC_LINK LVM1 POOL SNAPSHOTS MIRRORS OWNER GROUP COPTIMISE_FLAG CLDFLAGS CLDWHOLEARCHIVE CLDNOWHOLEARCHIVE LDDEPS LIB_SUFFIX LVM_VERSION LVM1_FALLBACK DEBUG DEVMAPPER HAVE_LIBDL HAVE_SELINUX HAVE_REALTIME CMDLIB LOCALEDIR CONFDIR STATICDIR INTL_PACKAGE INTL CLVMD CLUSTER FSADM DMEVENTD LTLIBOBJS'
+ac_subst_vars='SHELL PATH_SEPARATOR PACKAGE_NAME PACKAGE_TARNAME PACKAGE_VERSION PACKAGE_STRING PACKAGE_BUGREPORT exec_prefix prefix program_transform_name bindir sbindir libexecdir datadir sysconfdir sharedstatedir localstatedir libdir includedir oldincludedir infodir mandir build_alias host_alias target_alias DEFS ECHO_C ECHO_N ECHO_T LIBS build build_cpu build_vendor build_os host host_cpu host_vendor host_os target target_cpu target_vendor target_os AWK CC CFLAGS LDFLAGS CPPFLAGS ac_ct_CC EXEEXT OBJEXT INSTALL_PROGRAM INSTALL_SCRIPT INSTALL_DATA LN_S SET_MAKE RANLIB ac_ct_RANLIB CFLOW_CMD CSCOPE_CMD CPP EGREP ALLOCA LIBOBJS POW_LIB MSGFMT MODPROBE_CMD JOBS STATIC_LINK LVM1 POOL SNAPSHOTS MIRRORS OWNER GROUP COPTIMISE_FLAG CLDFLAGS CLDWHOLEARCHIVE CLDNOWHOLEARCHIVE LDDEPS LIB_SUFFIX LVM_VERSION LVM1_FALLBACK DEBUG DEVMAPPER HAVE_LIBDL HAVE_SELINUX HAVE_REALTIME CMDLIB LOCALEDIR CONFDIR STATICDIR DMDIR INTL_PACKAGE INTL CLVMD CLUSTER FSADM DMEVENTD LTLIBOBJS'
 ac_subst_files=''
 
 # Initialize some variables set by options.
@@ -883,6 +883,7 @@
   --with-localedir=DIR    Translation files in DIR PREFIX/share/locale
   --with-confdir=DIR      Configuration files in DIR /etc
   --with-staticdir=DIR    Static binary in DIR EXEC_PREFIX/sbin
+  --with-dmdir=DIR        Build against device-mapper source tree in DIR
 
 Some influential environment variables:
   CC          C compiler command
@@ -8964,6 +8965,15 @@
    STATICDIR='${exec_prefix}/sbin'
 fi;
 
+
+# Check whether --with-dmdir or --without-dmdir was given.
+if test "${with_dmdir+set}" = set; then
+  withval="$with_dmdir"
+   DMDIR="$withval"
+else
+   DMDIR=
+fi;
+
 ################################################################################
 if test x$READLINE = xyes; then
 
@@ -11202,6 +11212,7 @@
 
 
 
+
 ################################################################################
                                                                                                                                                                                                                                                           ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
 cat >confcache <<\_ACEOF
@@ -11900,6 +11911,7 @@
 s, at LOCALEDIR@,$LOCALEDIR,;t t
 s, at CONFDIR@,$CONFDIR,;t t
 s, at STATICDIR@,$STATICDIR,;t t
+s, at DMDIR@,$DMDIR,;t t
 s, at INTL_PACKAGE@,$INTL_PACKAGE,;t t
 s, at INTL@,$INTL,;t t
 s, at CLVMD@,$CLVMD,;t t
--- LVM2/configure.in	2006/11/20 20:03:26	1.54
+++ LVM2/configure.in	2007/01/09 20:31:08	1.55
@@ -526,6 +526,11 @@
   	    [ STATICDIR="$withval" ],
  	    [ STATICDIR='${exec_prefix}/sbin' ])
 
+AC_ARG_WITH(dmdir,
+	    [  --with-dmdir=DIR        Build against device-mapper source tree in DIR],
+  	    [ DMDIR="$withval" ],
+	    [ DMDIR= ])
+
 ################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
@@ -608,6 +613,7 @@
 AC_SUBST(LOCALEDIR)
 AC_SUBST(CONFDIR)
 AC_SUBST(STATICDIR)
+AC_SUBST(DMDIR)
 AC_SUBST(INTL_PACKAGE)
 AC_SUBST(INTL)
 AC_SUBST(CLVMD)
--- LVM2/make.tmpl.in	2006/05/16 20:53:13	1.45
+++ LVM2/make.tmpl.in	2007/01/09 20:31:08	1.46
@@ -73,6 +73,10 @@
   DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
 endif
 
+ifneq ("@DMDIR@", "")
+  LDFLAGS += -L at DMDIR@/lib/ioctl
+endif
+
 LDFLAGS += -L$(top_srcdir)/lib -L$(libdir)
 
 #DEFS += -DDEBUG_POOL
@@ -89,6 +93,10 @@
 
 INCLUDES += -I. -I$(top_srcdir)/include
 
+ifneq ("@DMDIR@", "")
+  INCLUDES += -I@DMDIR@/include
+endif
+
 ifdef DESTDIR
   INCLUDES += -I$(DESTDIR)/usr/include
 endif
--- LVM2/lib/activate/dev_manager.c	2006/11/30 23:11:39	1.117
+++ LVM2/lib/activate/dev_manager.c	2007/01/09 20:31:08	1.118
@@ -993,6 +993,8 @@
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
+		if ((lv->status & MIRRORED) && !(lv->status & PVMOVE))
+			dm_tree_use_no_flush_suspend(root);
 	case SUSPEND_WITH_LOCKFS:
 		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;


