From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Feb 2012 17:55:12 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20120222175512.30277.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-22 17:55:11

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	                 make.tmpl.in 
	scripts        : Makefile.in 

Log message:
	Add configure --with-tmpfilesdir and lvm2 tmpfiles.d configuration file itself.
	
	/etc/tmpfiles.d directory holds configuration files for temporary/volatile
	files and directories that should be automatically managed. For example,
	if we have some parts of the fs hierarchy on tmpfs, we'd like to recreate
	some files or directories on every boot so they're always prepared for use.
	
	Systemd can read such configuration files. For now, the lock and run directory
	are the ones that are most probably placed on tmpfs. If this is the case, we
	can install the configuration by 'make install_tmpfiles_configuration'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2299&r2=1.2300
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/Makefile.in	2012/02/01 10:46:45	1.68
+++ LVM2/Makefile.in	2012/02/22 17:55:10	1.69
@@ -97,6 +97,9 @@
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
+install_tmpfiles_configuration:
+	$(MAKE) -C scripts install_tmpfiles_configuration
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)
--- LVM2/WHATS_NEW	2012/02/22 17:18:49	1.2299
+++ LVM2/WHATS_NEW	2012/02/22 17:55:10	1.2300
@@ -1,5 +1,7 @@
 Version 2.02.93 - 
 ====================================
+  Add tmpfiles.d style configuration for lvm2 lock and run directory.
+  Add configure --with-tmpfilesdir for dir holding volatile-file configuration.
   Allow 'lvconvert --repair' to operate on RAID 4/5/6
   Fix 'build_parallel_areas_from_lv' to work properly with RAID 4/5/6
 
--- LVM2/configure	2012/02/20 19:36:27	1.169
+++ LVM2/configure	2012/02/22 17:55:10	1.170
@@ -596,6 +596,7 @@
 ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
+tmpfilesdir
 systemdsystemunitdir
 udevdir
 udev_prefix
@@ -844,6 +845,7 @@
 with_udev_prefix
 with_udevdir
 with_systemdsystemunitdir
+with_tmpfilesdir
 with_dmeventd_pidfile
 with_dmeventd_path
 with_default_run_dir
@@ -1589,6 +1591,9 @@
   --with-udevdir=DIR      udev rules in DIR [[UPREFIX/lib/udev/rules.d]]
   --with-systemdsystemunitdir=DIR
                           systemd service files in DIR
+  --with-tmpfilesdir=DIR  install configuration files for management of
+                          volatile files and directories in DIR
+                          [[SYSCONFDIR/tmpfiles.d]]
   --with-dmeventd-pidfile=PATH
                           dmeventd pidfile [[/var/run/dmeventd.pid]]
   --with-dmeventd-path=PATH
@@ -9764,6 +9769,15 @@
 	    systemdsystemunitdir='/lib/systemd/system';
 fi
 ################################################################################
+
+# Check whether --with-tmpfilesdir was given.
+if test "${with_tmpfilesdir+set}" = set; then :
+  withval=$with_tmpfilesdir; tmpfilesdir=$withval
+else
+  tmpfilesdir='${sysconfdir}/tmpfiles.d'
+fi
+
+################################################################################
 if test x$READLINE = xyes; then
 	for ac_header in readline/readline.h readline/history.h
 do :
@@ -10410,8 +10424,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11140,6 +11155,7 @@
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
+    "scripts/lvm2_tmpfiles_red_hat.conf") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_tmpfiles_red_hat.conf" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
--- LVM2/configure.in	2012/02/20 19:36:27	1.184
+++ LVM2/configure.in	2012/02/22 17:55:10	1.185
@@ -1209,6 +1209,11 @@
 	    systemdsystemunitdir='/lib/systemd/system';
 fi
 ################################################################################
+AC_ARG_WITH(tmpfilesdir,
+	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
+			   [install configuration files for management of volatile files and directories in DIR [[SYSCONFDIR/tmpfiles.d]]]),
+			   tmpfilesdir=$withval, tmpfilesdir='${sysconfdir}/tmpfiles.d')
+################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,AC_MSG_ERROR(bailing out))
@@ -1478,6 +1483,7 @@
 AC_SUBST(udev_prefix)
 AC_SUBST(udevdir)
 AC_SUBST(systemdsystemunitdir)
+AC_SUBST(tmpfilesdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
 
@@ -1525,6 +1531,7 @@
 scripts/lvm2_monitoring_init_red_hat
 scripts/dm_event_systemd_red_hat.service
 scripts/lvm2_monitoring_systemd_red_hat.service
+scripts/lvm2_tmpfiles_red_hat.conf
 scripts/Makefile
 test/Makefile
 test/api/Makefile
--- LVM2/make.tmpl.in	2012/02/13 17:31:14	1.129
+++ LVM2/make.tmpl.in	2012/02/22 17:55:10	1.130
@@ -51,6 +51,7 @@
 prefix = @prefix@
 exec_prefix = @exec_prefix@
 udev_prefix = @udev_prefix@
+sysconfdir = @sysconfdir@
 bindir = $(DESTDIR)@bindir@
 confdir = $(DESTDIR)@CONFDIR@/lvm
 includedir = $(DESTDIR)@includedir@
@@ -65,8 +66,9 @@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
-initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
+initdir = $(DESTDIR)$(sysconfdir)/rc.d/init.d
 systemd_dir = $(DESTDIR)@systemdsystemunitdir@
+tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
--- LVM2/scripts/Makefile.in	2011/09/24 21:05:03	1.22
+++ LVM2/scripts/Makefile.in	2012/02/22 17:55:11	1.23
@@ -60,5 +60,9 @@
 	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_dir)/dm-event.service
 	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_dir)/lvm2-monitor.service
 
+install_tmpfiles_configuration:
+	$(INSTALL_DIR) $(tmpfiles_dir)
+	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
+
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
 		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service


