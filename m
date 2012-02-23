From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Feb 2012 11:13:19 -0000
Subject: LVM2/scripts Makefile.in
Message-ID: <20120223111319.25627.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-23 11:13:19

Modified files:
	scripts        : Makefile.in 

Log message:
	Install lvm2 monitoring init script and systemd units only if dmeventd is built.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/scripts/Makefile.in	2012/02/23 10:01:12	1.24
+++ LVM2/scripts/Makefile.in	2012/02/23 11:13:18	1.25
@@ -46,7 +46,9 @@
 # FIXME Customise for other distributions
 install_initscripts:
 	$(INSTALL_DIR) $(initdir)
+ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
+endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initdir)/clvmd
 endif
@@ -56,9 +58,11 @@
 
 install_systemd_units:
 	$(INSTALL_DIR) $(systemd_dir)
+ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_dir)/dm-event.socket
 	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_dir)/dm-event.service
 	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_dir)/lvm2-monitor.service
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)


