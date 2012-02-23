From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Feb 2012 13:31:50 -0000
Subject: LVM2 ./configure ./configure.in scripts/Makefi ...
Message-ID: <20120223133150.32639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-23 13:31:50

Modified files:
	.              : configure configure.in 
	scripts        : Makefile.in 
	                 lvm2_lvmetad_systemd_red_hat.service.in 
Added files:
	scripts        : lvm2_lvmetad_systemd_red_hat.socket.in 

Log message:
	Use DEFAULT_RUN_DIR instead of hardcoded value in lvmetad systemd units
	and add ExecStartPost=vgscan to actually run the first scan that will
	fill the metadata daemon with metadata information.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/configure	2012/02/23 11:24:08	1.171
+++ LVM2/configure	2012/02/23 13:31:49	1.172
@@ -10426,7 +10426,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_e!
 vent_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scrip!
 ts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11152,6 +11152,7 @@
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
--- LVM2/configure.in	2012/02/23 11:24:08	1.186
+++ LVM2/configure.in	2012/02/23 13:31:49	1.187
@@ -1528,6 +1528,7 @@
 po/Makefile
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
+scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
 scripts/dm_event_systemd_red_hat.service
/cvs/lvm2/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ -	2012-02-23 13:31:50.509731000 +0000
@@ -0,0 +1,10 @@
+[Unit]
+Description=LVM2 metadata daemon socket
+DefaultDependencies=no
+
+[Socket]
+ListenStream=@DEFAULT_RUN_DIR@/lvmetad.sock
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target
--- LVM2/scripts/Makefile.in	2012/02/23 11:24:08	1.26
+++ LVM2/scripts/Makefile.in	2012/02/23 13:31:49	1.27
@@ -65,7 +65,7 @@
 endif
 ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_dir)/lvm2-lvmetad.socket
-	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service.in $(systemd_dir)/lvm2-lvmetad.service
+	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_dir)/lvm2-lvmetad.service
 endif
 
 install_tmpfiles_configuration:
@@ -74,4 +74,5 @@
 
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
 		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service \
+		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
 		     lvm2_tmpfiles_red_hat.conf
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/02/23 11:24:08	1.1
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/02/23 13:31:49	1.2
@@ -8,8 +8,9 @@
 [Service]
 Type=forking
 ExecStart=@sbindir@/lvmetad
+ExecStartPost=@sbindir@/vgscan
 ExecReload=@sbindir@/lvmetad -R
-PIDFile=/var/run/lvm/lvmetad.pid
+PIDFile=@DEFAULT_RUN_DIR@/lvmetad.pid
 
 [Install]
 WantedBy=sysinit.target


