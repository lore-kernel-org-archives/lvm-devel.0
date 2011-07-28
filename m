From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2011 12:58:53 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure.in ...
Message-ID: <20110728125853.13595.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-07-28 12:57:26

Modified files:
	.              : Makefile.in WHATS_NEW configure.in make.tmpl.in 
	scripts        : Makefile.in 

Log message:
	Configure and makefile changes for newly added systemd unit files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2043&r2=1.2044
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/Makefile.in	2010/11/22 21:39:47	1.63
+++ LVM2/Makefile.in	2011/07/28 12:57:26	1.64
@@ -92,6 +92,9 @@
 install_initscripts: 
 	$(MAKE) -C scripts install_initscripts
 
+install_systemd_units:
+	$(MAKE) -C scripts install_systemd_units
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)
--- LVM2/WHATS_NEW	2011/07/21 13:23:48	1.2043
+++ LVM2/WHATS_NEW	2011/07/28 12:57:26	1.2044
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add systemd unit file to provide lvm2 monitoring.
   Compare also file size to detect changed config file.
 
 Version 2.02.86 - 8th July 2011
--- LVM2/configure.in	2011/04/28 16:54:33	1.162
+++ LVM2/configure.in	2011/07/28 12:57:26	1.163
@@ -1371,6 +1371,7 @@
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(WRITE_INSTALL)
+AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
@@ -1417,6 +1418,8 @@
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
 scripts/lvm2_monitoring_init_red_hat
+scripts/dm_event_systemd_red_hat.service
+scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/Makefile
 test/Makefile
 test/api/Makefile
--- LVM2/make.tmpl.in	2011/04/22 11:59:59	1.117
+++ LVM2/make.tmpl.in	2011/07/28 12:57:26	1.118
@@ -65,6 +65,7 @@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
+systemd_dir = $(DESTDIR)/lib/systemd/system
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
--- LVM2/scripts/Makefile.in	2010/11/05 16:18:38	1.20
+++ LVM2/scripts/Makefile.in	2011/07/28 12:57:26	1.21
@@ -53,4 +53,11 @@
 	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
 
-DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat
+install_systemd_units:
+	$(INSTALL_DIR) $(systemd_dir)
+	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_dir)/dm-event.socket
+	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_dir)/dm-event.service
+	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_dir)/lvm2-monitor.service
+
+DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
+		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service


