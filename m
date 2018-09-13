From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Sep 2018 12:10:01 -0400
Subject: master - More cleanup needed for dropped scripts
Message-ID: <201809131610.w8DGA1kH026971@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19a59cc53c723f3614d68edcdd9dfabe15c1299b
Commit:        19a59cc53c723f3614d68edcdd9dfabe15c1299b
Parent:        e9b6cdd6e65196d6ada6ce54e8d256c3dc57329b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 13 11:02:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 13 11:09:25 2018 -0500

More cleanup needed for dropped scripts

and drop the lvm2 prefix from lvmlockd service
---
 configure.ac                                     |    4 +-
 man/Makefile.in                                  |    2 +-
 man/lvmconf.8_main                               |   70 ----------------------
 man/lvmlockd.8_main                              |    2 +-
 scripts/Makefile.in                              |    8 ++-
 scripts/lvm2_lvmlockd_systemd_red_hat.service.in |   13 ----
 scripts/lvmlockd.service.in                      |   13 ++++
 scripts/lvmlocks.service.in                      |    2 +-
 spec/packages.inc                                |    3 +-
 9 files changed, 25 insertions(+), 92 deletions(-)

diff --git a/configure.ac b/configure.ac
index 6d9308f..32cd921 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1819,10 +1819,10 @@ scripts/lvm2_lvmdbusd_systemd_red_hat.service
 scripts/lvm2_lvmpolld_init_red_hat
 scripts/lvm2_lvmpolld_systemd_red_hat.service
 scripts/lvm2_lvmpolld_systemd_red_hat.socket
-scripts/lvm2_lvmlockd_systemd_red_hat.service
+scripts/lvmlockd.service
+scripts/lvmlocks.service
 scripts/lvm2_monitoring_init_red_hat
 scripts/lvm2_monitoring_systemd_red_hat.service
-scripts/lvm2_pvscan_systemd_red_hat at .service
 scripts/lvm2_tmpfiles_red_hat.conf
 scripts/lvmdump.sh
 scripts/Makefile
diff --git a/man/Makefile.in b/man/Makefile.in
index aefda2d..6d5e2ac 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -37,7 +37,7 @@ LVMRAIDMAN = lvmraid.7
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7 lvmreport.7 
-MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
+MAN8=lvm.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 \
      lvextend.8 lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
      lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
diff --git a/man/lvmconf.8_main b/man/lvmconf.8_main
deleted file mode 100644
index ca66ae6..0000000
--- a/man/lvmconf.8_main
+++ /dev/null
@@ -1,70 +0,0 @@
-.TH "LVMCONF" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
-.SH "NAME"
-lvmconf \(em LVM configuration modifier
-.SH "SYNOPSIS"
-.B lvmconf
-.RB [ --disable-cluster ]
-.RB [ --enable-cluster ]
-.RB [ --enable-halvm ]
-.RB [ --disable-halvm ]
-.RB [ --file
-.RI < configfile >]
-.RB [ --lockinglib
-.RI < lib >]
-.RB [ --lockinglibdir
-.RI < dir >]
-.RB [ --services ]
-.RB [ --mirrorservice ]
-.RB [ --startstopservices ]
-
-.SH "DESCRIPTION"
-lvmconf is a script that modifies the locking configuration in
-an lvm configuration file. See \fBlvm.conf\fP(5). In addition
-to that, it can also set Systemd or SysV services according to
-changes in the lvm configuration if needed.
-
-.SH "OPTIONS"
-.TP
-.BR --disable-cluster
-Set \fBlocking_type\fR to the default non-clustered type. Also reset
-lvmetad use to its default.
-.TP
-.BR --enable-cluster
-Set \fBlocking_type\fR to the default clustered type on this system.
-Also disable lvmetad use as it is not yet supported in clustered environment.
-.TP
-.BR --disable-halvm
-Set \fBlocking_type\fR to the default non-clustered type. Also reset
-lvmetad use to its default.
-.TP
-.BR --enable-halvm
-Set \fBlocking_type\fR suitable for HA LVM use.
-Also disable lvmetad use as it is not yet supported in HA LVM environment.
-.TP
-.BR --file " <" \fIconfigfile >
-Apply the changes to \fIconfigfile\fP instead of the default
-\fI#DEFAULT_SYS_DIR#/lvm.conf\fP.
-.TP
-.BR --lockinglib " <" \fIlib >
-Set external \fBlocking_library\fR locking library to load if an external locking type is used.
-.TP
-.BR --lockinglibdir " <" \fIdir >
-.TP
-.BR --services
-In addition to setting the lvm configuration, also enable or disable related Systemd or SysV
-clvmd and lvmetad services. This script does not configure services provided by cluster resource
-agents.
-.TP
-.BR --mirrorservice
-Also enable or disable optional cmirrord service when handling services (applicable only with --services).
-.TP
-.BR --startstopservices
-In addition to enabling or disabling related services, start or stop them immediately
-(applicable only with --services).
-.SH FILES
-.I #DEFAULT_SYS_DIR#/lvm.conf
-
-.SH "SEE ALSO"
-.BR lvm (8),
-.BR lvm.conf (5)
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index cfb45b2..1a52fc5 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -121,7 +121,7 @@ Start the lvmlockd daemon.
 .br
 Use systemctl, a cluster resource agent, or run directly, e.g.
 .br
-systemctl start lvm2-lvmlockd
+systemctl start lvmlockd
 
 .SS 4. start lock manager
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 6d32b63..039cac2 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -24,7 +24,7 @@ ifeq ("@BUILD_DMEVENTD@", "yes")
 	LDFLAGS += -Wl,-rpath-link,$(top_builddir)/daemons/dmeventd
 endif
 
-LVM_SCRIPTS = lvmdump.sh lvmconf.sh
+LVM_SCRIPTS = lvmdump.sh
 DM_SCRIPTS =
 
 ifeq ("@FSADM@", "yes")
@@ -105,7 +105,8 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
 endif
 ifeq ("@BUILD_LVMLOCKD@", "yes")
-	$(INSTALL_DATA) lvm2_lvmlockd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlockd.service
+	$(INSTALL_DATA) lvmlockd.service $(systemd_unit_dir)/lvmlockd.service
+	$(INSTALL_DATA) lvmlocks.service $(systemd_unit_dir)/lvmlocks.service
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
@@ -149,7 +150,8 @@ DISTCLEAN_TARGETS += \
 	lvm2_lvmetad_systemd_red_hat.socket \
 	lvm2_lvmpolld_systemd_red_hat.service \
 	lvm2_lvmpolld_systemd_red_hat.socket \
-	lvm2_lvmlockd_systemd_red_hat.service \
+	lvmlockd.service \
+	lvmlocks.service \
 	lvm2_monitoring_init_red_hat \
 	lvm2_monitoring_systemd_red_hat.service \
 	lvm2_pvscan_systemd_red_hat at .service \
diff --git a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
deleted file mode 100644
index efe489a..0000000
--- a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
+++ /dev/null
@@ -1,13 +0,0 @@
-[Unit]
-Description=LVM lock daemon
-Documentation=man:lvmlockd(8)
-
-[Service]
-Type=notify
-ExecStart=@SBINDIR@/lvmlockd --foreground
-PIDFile=@LVMLOCKD_PIDFILE@
-SendSIGKILL=no
-
-[Install]
-WantedBy=multi-user.target
-
diff --git a/scripts/lvmlockd.service.in b/scripts/lvmlockd.service.in
new file mode 100644
index 0000000..efe489a
--- /dev/null
+++ b/scripts/lvmlockd.service.in
@@ -0,0 +1,13 @@
+[Unit]
+Description=LVM lock daemon
+Documentation=man:lvmlockd(8)
+
+[Service]
+Type=notify
+ExecStart=@SBINDIR@/lvmlockd --foreground
+PIDFile=@LVMLOCKD_PIDFILE@
+SendSIGKILL=no
+
+[Install]
+WantedBy=multi-user.target
+
diff --git a/scripts/lvmlocks.service.in b/scripts/lvmlocks.service.in
index 79598db..f6a951f 100644
--- a/scripts/lvmlocks.service.in
+++ b/scripts/lvmlocks.service.in
@@ -1,7 +1,7 @@
 [Unit]
 Description=LVM locking start and stop
 Documentation=man:lvmlockd(8)
-After=lvm2-lvmlockd.service sanlock.service dlm.service
+After=lvmlockd.service sanlock.service dlm.service
 
 [Service]
 Type=oneshot
diff --git a/spec/packages.inc b/spec/packages.inc
index 38f90ec..4049f27 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -285,7 +285,8 @@ fi
 %{_mandir}/man8/lvmlockd.8.gz
 %{_mandir}/man8/lvmlockctl.8.gz
 %dir %{_default_locking_dir}
-%{_unitdir}/lvm2-lvmlockd.service
+%{_unitdir}/lvmlockd.service
+%{_unitdir}/lvmlocks.service
 %endif
 
 ##############################################################################


