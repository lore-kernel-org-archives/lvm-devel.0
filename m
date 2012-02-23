From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Feb 2012 11:24:10 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in sc ...
Message-ID: <20120223112410.29684.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-23 11:24:08

Modified files:
	.              : WHATS_NEW configure configure.in 
	scripts        : Makefile.in 
Added files:
	scripts        : lvm2_lvmetad_systemd_red_hat.service.in 
	                 lvm2_lvmetad_systemd_red_hat.socket 

Log message:
	Add LVMetaD systemd units.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2302&r2=1.2303
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2012/02/23 03:57:23	1.2302
+++ LVM2/WHATS_NEW	2012/02/23 11:24:07	1.2303
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Add LVMetaD systemd units.
   Fix allocation code to allow replacement of single RAID 4/5/6 device.
   Check all tags and LV names are in a valid form in vg_validate.
   Add tmpfiles.d style configuration for lvm2 lock and run directory.
--- LVM2/configure	2012/02/22 17:55:10	1.170
+++ LVM2/configure	2012/02/23 11:24:08	1.171
@@ -10426,7 +10426,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_e!
 vent_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11152,6 +11152,7 @@
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
--- LVM2/configure.in	2012/02/22 17:55:10	1.185
+++ LVM2/configure.in	2012/02/23 11:24:08	1.186
@@ -1528,6 +1528,7 @@
 po/Makefile
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
+scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
 scripts/dm_event_systemd_red_hat.service
 scripts/lvm2_monitoring_systemd_red_hat.service
/cvs/lvm2/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ -	2012-02-23 11:24:09.598813000 +0000
@@ -0,0 +1,15 @@
+[Unit]
+Description=LVM2 metadata daemon
+Requires=lvm2-lvmetad.socket
+After=lvm2-lvmetad.socket
+DefaultDependencies=no
+Conflicts=shutdown.target
+
+[Service]
+Type=forking
+ExecStart=@sbindir@/lvmetad
+ExecReload=@sbindir@/lvmetad -R
+PIDFile=/var/run/lvm/lvmetad.pid
+
+[Install]
+WantedBy=sysinit.target
/cvs/lvm2/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket
+++ -	2012-02-23 11:24:09.762805000 +0000
@@ -0,0 +1,10 @@
+[Unit]
+Description=LVM2 metadata daemon socket
+DefaultDependencies=no
+
+[Socket]
+ListenStream=/var/run/lvm/lvmetad.socket
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target
--- LVM2/scripts/Makefile.in	2012/02/23 11:13:18	1.25
+++ LVM2/scripts/Makefile.in	2012/02/23 11:24:08	1.26
@@ -63,6 +63,10 @@
 	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_dir)/dm-event.service
 	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_dir)/lvm2-monitor.service
 endif
+ifeq ("@BUILD_LVMETAD@", "yes")
+	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_dir)/lvm2-lvmetad.socket
+	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service.in $(systemd_dir)/lvm2-lvmetad.service
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)


