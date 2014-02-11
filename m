From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Feb 2014 09:16:09 +0000 (UTC)
Subject: master - systemd: rename lvm2-cluster-activation and lvm2-clvmd services to follow existing naming
Message-ID: <20140211091609.E6AC26135F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a092cd33be13229b288ab44fb39e410c1ca57175
Commit:        a092cd33be13229b288ab44fb39e410c1ca57175
Parent:        ef91de2a0cc29dd66a93fc4fb0c873d67328dc7d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 11 10:03:19 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 11 10:12:39 2014 +0100

systemd: rename lvm2-cluster-activation and lvm2-clvmd services to follow existing naming

lvm2_cluster_activation_red_hat.service.in -> lvm2_cluster_activation_systemd_red_hat.service.in
lvm2_clvmd_red_hat.service.in -> lvm2_clvmd_red_hat.service.in

Edit lvm2-cluster-activation reference on cmirror - take new
lvm2-cmirrord.service, it was just cmirrord(.service) before
as the old initscript was used in compatibility mode.

Also, use WantedBy=multi-user.target instead of sysinit.target
in lvm2-cluster-activation.service.
---
 WHATS_NEW                                          |    2 +-
 configure                                          |    6 ++--
 configure.in                                       |    4 +-
 scripts/Makefile.in                                |    9 ++++---
 scripts/lvm2_cluster_activation_red_hat.service.in |   16 ---------------
 ...2_cluster_activation_systemd_red_hat.service.in |   16 +++++++++++++++
 scripts/lvm2_clvmd_red_hat.service.in              |   21 --------------------
 scripts/lvm2_clvmd_systemd_red_hat.service.in      |   21 ++++++++++++++++++++
 8 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1b24781..c5bb6de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add systemd native service for clvmd, cmirrord and cluster activation.
   Remove ExecReload from lvmetad systemd unit: lvmetad -R undefined. (2.02.98)
   Do not fork lvmetad if running under systemd.
   Wipe DM_snapshot_cow signature without prompt in new LVs with blkid wiping.
@@ -17,7 +18,6 @@ Version 2.02.106 -
   Issue error if libbblkid detects signature and fails to return offset/length.
   Update autoconf config.guess/sub to 2014-01-01.
   Online thin pool metadata resize requires 1.10 kernel thin pool target.
-  Add systemd native service for the clvmd and cluster activation.
 
 Version 2.02.105 - 20th January 2014
 ====================================
diff --git a/configure b/configure
index 7131300..f6463f0 100755
--- a/configure
+++ b/configure
@@ -11454,7 +11454,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12188,9 +12188,9 @@ do
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
     "scripts/lvm2_cluster_activation_red_hat.sh") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.sh" ;;
-    "scripts/lvm2_cluster_activation_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_red_hat.service" ;;
+    "scripts/lvm2_cluster_activation_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cluster_activation_systemd_red_hat.service" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
-    "scripts/lvm2_clvmd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_red_hat.service" ;;
+    "scripts/lvm2_clvmd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_clvmd_systemd_red_hat.service" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_cmirrord_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_cmirrord_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
diff --git a/configure.in b/configure.in
index ade965b..8fdc8b1 100644
--- a/configure.in
+++ b/configure.in
@@ -1789,9 +1789,9 @@ scripts/blkdeactivate.sh
 scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
 scripts/lvm2_cluster_activation_red_hat.sh
-scripts/lvm2_cluster_activation_red_hat.service
+scripts/lvm2_cluster_activation_systemd_red_hat.service
 scripts/clvmd_init_red_hat
-scripts/lvm2_clvmd_red_hat.service
+scripts/lvm2_clvmd_systemd_red_hat.service
 scripts/cmirrord_init_red_hat
 scripts/lvm2_cmirrord_systemd_red_hat.service
 scripts/lvm2_lvmetad_init_red_hat
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 35e20c5..8fdb5f7 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -112,8 +112,8 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_pvscan_systemd_red_hat at .service $(systemd_unit_dir)/lvm2-pvscan at .service
 endif
 ifneq ("@CLVMD@", "none")
-	$(INSTALL_DATA) lvm2_clvmd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
-	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
+	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
+	$(INSTALL_DATA) lvm2_cluster_activation_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
 	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
@@ -132,6 +132,7 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     lvm2_pvscan_systemd_red_hat at .service \
 		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
 		     blk_availability_systemd_red_hat.service \
-		     blkdeactivate.sh lvm2_clvmd_red_hat.service \
+		     blkdeactivate.sh lvm2_clvmd_systemd_red_hat.service \
 		     lvm2_cmirrord_systemd_red_hat.service \
-		     lvm2_cluster_activation_red_hat.service lvm2_cluster_activation_red_hat.sh
+		     lvm2_cluster_activation_systemd_red_hat.service \
+		     lvm2_cluster_activation_red_hat.sh
diff --git a/scripts/lvm2_cluster_activation_red_hat.service.in b/scripts/lvm2_cluster_activation_red_hat.service.in
deleted file mode 100644
index b6887c3..0000000
--- a/scripts/lvm2_cluster_activation_red_hat.service.in
+++ /dev/null
@@ -1,16 +0,0 @@
-[Unit]
-Description=Clustered LVM volumes activation service
-Requires=lvm2-clvmd.service
-After=lvm2-clvmd.service cmirrord.service
-OnFailure=lvm2-clvmd.service
-DefaultDependencies=false
-
-[Service]
-Type=simple
-RemainAfterExit=yes
-EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@systemdutildir@/lvm2-cluster-activation activate
-ExecStop=@systemdutildir@/lvm2-cluster-activation deactivate
-
-[Install]
-WantedBy=sysinit.target
diff --git a/scripts/lvm2_cluster_activation_systemd_red_hat.service.in b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
new file mode 100644
index 0000000..03ed9d2
--- /dev/null
+++ b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
@@ -0,0 +1,16 @@
+[Unit]
+Description=Clustered LVM volumes activation service
+Requires=lvm2-clvmd.service
+After=lvm2-clvmd.service lvm2-cmirrord.service
+OnFailure=lvm2-clvmd.service
+DefaultDependencies=false
+
+[Service]
+Type=simple
+RemainAfterExit=yes
+EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
+ExecStart=@systemdutildir@/lvm2-cluster-activation activate
+ExecStop=@systemdutildir@/lvm2-cluster-activation deactivate
+
+[Install]
+WantedBy=multi-user.target
diff --git a/scripts/lvm2_clvmd_red_hat.service.in b/scripts/lvm2_clvmd_red_hat.service.in
deleted file mode 100644
index c10bdc4..0000000
--- a/scripts/lvm2_clvmd_red_hat.service.in
+++ /dev/null
@@ -1,21 +0,0 @@
-[Unit]
-Description=Clustered LVM daemon
-Documentation=man:clvmd(8)
-After=dlm.service corosync.service
-Before=remote-fs.target
-Requires=network.target dlm.service corosync.service
-RefuseManualStart=true
-RefuseManualStop=true
-StopWhenUnneeded=true
-
-[Service]
-Type=forking
-Environment=CLVMD_OPTS=-T30
-EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@sbindir@/clvmd $CLVMD_OPTS
-SuccessExitStatus=5
-TimeoutStartSec=30
-TimeoutStopSec=10
-OOMScoreAdjust=-1000
-Restart=on-abort
-PIDFile=@CLVMD_PIDFILE@
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
new file mode 100644
index 0000000..c10bdc4
--- /dev/null
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -0,0 +1,21 @@
+[Unit]
+Description=Clustered LVM daemon
+Documentation=man:clvmd(8)
+After=dlm.service corosync.service
+Before=remote-fs.target
+Requires=network.target dlm.service corosync.service
+RefuseManualStart=true
+RefuseManualStop=true
+StopWhenUnneeded=true
+
+[Service]
+Type=forking
+Environment=CLVMD_OPTS=-T30
+EnvironmentFile=-@sysconfdir@/sysconfig/clvmd
+ExecStart=@sbindir@/clvmd $CLVMD_OPTS
+SuccessExitStatus=5
+TimeoutStartSec=30
+TimeoutStopSec=10
+OOMScoreAdjust=-1000
+Restart=on-abort
+PIDFile=@CLVMD_PIDFILE@


