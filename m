From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 28 Jul 2011 14:27:55 +0200
Subject: [PATCH 2/3] Configure and makefile changes for systemd units inclusion
Message-ID: <4E3155CB.1020407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 Makefile.in         |    3 +++
 WHATS_NEW           |    1 +
 configure.in        |    3 +++
 make.tmpl.in        |    1 +
 scripts/Makefile.in |    9 ++++++++-
 5 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index f7e34f4..38c41a3 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -92,6 +92,9 @@ install_system_dirs:
 install_initscripts: 
 	$(MAKE) -C scripts install_initscripts
 
+install_systemd_units:
+	$(MAKE) -C scripts install_systemd_units
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)
diff --git a/configure.in b/configure.in
index 60796ad..d54d7d8 100644
--- a/configure.in
+++ b/configure.in
@@ -1371,6 +1371,7 @@ AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(WRITE_INSTALL)
+AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
@@ -1417,6 +1418,8 @@ po/Makefile
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
 scripts/lvm2_monitoring_init_red_hat
+scripts/dm_event_systemd_red_hat.service
+scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/Makefile
 test/Makefile
 test/api/Makefile
diff --git a/make.tmpl.in b/make.tmpl.in
index cd8ae35..f003149 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -65,6 +65,7 @@ staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
+systemd_dir = $(DESTDIR)/lib/systemd/system
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 5293cc3..7262fbb 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -53,4 +53,11 @@ ifeq ("@BUILD_CMIRRORD@", "yes")
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


