From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 14:45:20 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./make.tmpl.in ...
Message-ID: <20100520144520.5880.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 14:45:17

Modified files:
	.              : Makefile.in WHATS_NEW make.tmpl.in 
	scripts        : Makefile.in 

Log message:
	Add make install_initscripts

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1570&r2=1.1571
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/Makefile.in	2010/05/20 13:47:21	1.53
+++ LVM2/Makefile.in	2010/05/20 14:45:14	1.54
@@ -86,6 +86,9 @@
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_LOCK_DIR)
 	$(INSTALL_ROOT_DATA) /dev/null $(DESTDIR)$(DEFAULT_CACHE_DIR)/.cache
 
+install_initscripts: 
+	$(MAKE) -C scripts install_initscripts
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)
--- LVM2/WHATS_NEW	2010/05/20 13:47:21	1.1570
+++ LVM2/WHATS_NEW	2010/05/20 14:45:14	1.1571
@@ -1,6 +1,6 @@
 Version 2.02.66 - 
 ===============================
-  Add install_system_dirs makefile target.
+  Add install_system_dirs and install_initscripts makefile targets.
   Add configure options for system and locking directories.
   Generate example.conf so default lvm.conf contents can be configured.
   Install lvmconf script by default.
--- LVM2/make.tmpl.in	2010/05/20 13:47:21	1.100
+++ LVM2/make.tmpl.in	2010/05/20 14:45:14	1.101
@@ -90,7 +90,7 @@
 # Handle installation of files
 ifeq ("@WRITE_INSTALL@", "yes")
 # leaving defaults
-M_INSTALL_PROGRAM =
+M_INSTALL_SCRIPT =
 M_INSTALL_DATA = -m 644
 else
 M_INSTALL_PROGRAM = -m 555
@@ -100,8 +100,10 @@
 INSTALL_DATA = $(INSTALL) -p $(M_INSTALL_DATA)
 INSTALL_WDATA = $(INSTALL) -p -m 644
 
+INSTALL_DIR = $(INSTALL) -m 0755 -d
 INSTALL_ROOT_DIR = $(INSTALL) -m 0700 -d
 INSTALL_ROOT_DATA = $(INSTALL) -m 0600
+INSTALL_SCRIPT = $(INSTALL) -p -m $(M_INSTALL_PROGRAM)
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
--- LVM2/scripts/Makefile.in	2010/05/20 11:20:38	1.17
+++ LVM2/scripts/Makefile.in	2010/05/20 14:45:17	1.18
@@ -31,4 +31,15 @@
 
 install: install_lvm2
 
+# FIXME Customise for other distributions
+install_initscripts:
+	$(INSTALL_DIR) $(DESTDIR)/etc/rc.d/init.d
+	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(DESTDIR)/etc/rc.d/init.d/lvm2-monitor
+ifneq ("@CLVMD@", "none")
+	$(INSTALL_SCRIPT) clvmd_init_red_hat $(DESTDIR)/etc/rc.d/init.d/clvmd
+endif
+ifeq ("@BUILD_CMIRRORD@", "yes")
+	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(DESTDIR)/etc/rc.d/init.d/cmirrord
+endif
+
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat


