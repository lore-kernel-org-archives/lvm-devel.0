From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Feb 2014 09:16:07 +0000 (UTC)
Subject: master - systemd: add systemd unit for cmirrord
Message-ID: <20140211091607.C9FFA6135F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef91de2a0cc29dd66a93fc4fb0c873d67328dc7d
Commit:        ef91de2a0cc29dd66a93fc4fb0c873d67328dc7d
Parent:        a0d64554e6067edfcc4ed782d5e685cdd12ff894
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 11 09:55:57 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 11 10:06:19 2014 +0100

systemd: add systemd unit for cmirrord

---
 configure                                        |    3 ++-
 configure.in                                     |    1 +
 scripts/Makefile.in                              |    4 ++++
 scripts/lvm2_cmirrord_systemd_red_hat.service.in |   15 +++++++++++++++
 4 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 735137b..7131300 100755
--- a/configure
+++ b/configure
@@ -11454,7 +11454,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12192,6 +12192,7 @@ do
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/lvm2_clvmd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_red_hat.service" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
+    "scripts/lvm2_cmirrord_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cmirrord_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
diff --git a/configure.in b/configure.in
index 60b816f..ade965b 100644
--- a/configure.in
+++ b/configure.in
@@ -1793,6 +1793,7 @@ scripts/lvm2_cluster_activation_red_hat.service
 scripts/clvmd_init_red_hat
 scripts/lvm2_clvmd_red_hat.service
 scripts/cmirrord_init_red_hat
+scripts/lvm2_cmirrord_systemd_red_hat.service
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2f1fb2a..35e20c5 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -116,6 +116,9 @@ ifneq ("@CLVMD@", "none")
 	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
 	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
 endif
+ifeq ("@BUILD_CMIRRORD@", "yes")
+	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
@@ -130,4 +133,5 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
 		     blk_availability_systemd_red_hat.service \
 		     blkdeactivate.sh lvm2_clvmd_red_hat.service \
+		     lvm2_cmirrord_systemd_red_hat.service \
 		     lvm2_cluster_activation_red_hat.service lvm2_cluster_activation_red_hat.sh
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
new file mode 100644
index 0000000..4ca3eea
--- /dev/null
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -0,0 +1,15 @@
+[Unit]
+Description=Clustered LVM mirror log daemon
+Documentation=man:cmirrord(8)
+Requires=corosync.service
+After=corosync.service
+Before=remote-fs.target
+
+[Service]
+Type=forking
+ExecStart=@sbindir@/cmirrord
+PIDFile=@CMIRRORD_PIDFILE@
+Restart=on-abort
+
+[Install]
+WantedBy=multi-user.target


