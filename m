From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Feb 2012 13:02:49 -0000
Subject: LVM2 WHATS_NEW configure configure.in make.tmpl.in
Message-ID: <20120213130249.14008.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-13 13:02:48

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 

Log message:
	Add configure --with-systemdsystemunitdir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2290&r2=1.2291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW	2012/02/13 11:16:42	1.2290
+++ LVM2/WHATS_NEW	2012/02/13 13:02:47	1.2291
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add configure --with-systemdsystemunitdir.
   Add check for allocation failure in _build_matcher().
   Add check for rimage name allocation failure in _raid_add_images().
   Add check for mda_copy failure in _text_pv_setup().
--- LVM2/configure	2012/02/13 07:30:24	1.166
+++ LVM2/configure	2012/02/13 13:02:47	1.167
@@ -596,6 +596,7 @@
 ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
+systemdsystemunitdir
 udevdir
 udev_prefix
 tmpdir
@@ -840,6 +841,7 @@
 with_usrsbindir
 with_udev_prefix
 with_udevdir
+with_systemdsystemunitdir
 with_dmeventd_pidfile
 with_dmeventd_path
 with_default_run_dir
@@ -1580,6 +1582,8 @@
   --with-udev-prefix=UPREFIX
                           install udev rule files in UPREFIX [[EPREFIX]]
   --with-udevdir=DIR      udev rules in DIR [[UPREFIX/lib/udev/rules.d]]
+  --with-systemdsystemunitdir=DIR
+                          systemd service files in DIR
   --with-dmeventd-pidfile=PATH
                           dmeventd pidfile [[/var/run/dmeventd.pid]]
   --with-dmeventd-path=PATH
@@ -9701,6 +9705,23 @@
 
 
 ################################################################################
+
+# Check whether --with-systemdsystemunitdir was given.
+if test "${with_systemdsystemunitdir+set}" = set; then :
+  withval=$with_systemdsystemunitdir; systemdsystemunitdir=$withval
+else
+  pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
+fi
+
+
+if test -n "$pkg_systemdsystemunitdir"; then
+	    systemdsystemunitdir=$pkg_systemdsystemunitdir;
+fi
+
+if test -z "$systemdsystemunitdir"; then
+	    systemdsystemunitdir='/lib/systemd/system';
+fi
+################################################################################
 if test x$READLINE = xyes; then
 	for ac_header in readline/readline.h readline/history.h
 do :
@@ -10345,6 +10366,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2012/02/13 05:24:57	1.181
+++ LVM2/configure.in	2012/02/13 13:02:48	1.182
@@ -1168,6 +1168,22 @@
 	    udevdir=$withval, udevdir='${udev_prefix}/lib/udev/rules.d')
 
 ################################################################################
+dnl -- Get the systemd system unit dir value from pkg_config automatically if value not given explicitly.
+dnl -- This follows the recommendation for systemd integration best practices mentioned in daemon(7) manpage.
+AC_ARG_WITH(systemdsystemunitdir,
+	    AC_HELP_STRING([--with-systemdsystemunitdir=DIR],
+			   [systemd service files in DIR]),
+	    systemdsystemunitdir=$withval,
+	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd))
+
+if test -n "$pkg_systemdsystemunitdir"; then
+	    systemdsystemunitdir=$pkg_systemdsystemunitdir;
+fi
+
+if test -z "$systemdsystemunitdir"; then
+	    systemdsystemunitdir='/lib/systemd/system';
+fi
+################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,AC_MSG_ERROR(bailing out))
@@ -1435,6 +1451,7 @@
 AC_SUBST(tmpdir)
 AC_SUBST(udev_prefix)
 AC_SUBST(udevdir)
+AC_SUBST(systemdsystemunitdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
--- LVM2/make.tmpl.in	2011/11/23 12:19:23	1.127
+++ LVM2/make.tmpl.in	2012/02/13 13:02:48	1.128
@@ -66,7 +66,7 @@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
-systemd_dir = $(DESTDIR)/lib/systemd/system
+systemd_dir = $(DESTDIR)/@systemdsystemunitdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \


