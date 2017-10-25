From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:05:13 -0400
Subject: master - systemd: use proper sbindir path
Message-ID: <201710252005.v9PK5DgC029395@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d809fbb541a63002214ed1d77914c7a4c7d02c60
Commit:        d809fbb541a63002214ed1d77914c7a4c7d02c60
Parent:        3f59969c3fcbff2a3bb177fc07262f1ea569e134
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 17:06:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:54 2017 +0200

systemd: use proper sbindir path

Replace lowercase  @sbindir@  with  @SBINDIR@ which contains
fully decoded path.

Same with  @usrsbindir@ which is also used with clvmd and cmirrord.

Also handle SYSCONFDIR for EnvironmentFile.

Patch fixes generated unit files with strings like:
ExecStart=${exec_prefix}/sbin/lvm
---
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 scripts/com.redhat.lvmdbus1.service.in             |    2 +-
 scripts/dm_event_systemd_red_hat.service.in        |    2 +-
 ...2_cluster_activation_systemd_red_hat.service.in |    2 +-
 scripts/lvm2_clvmd_systemd_red_hat.service.in      |    4 ++--
 scripts/lvm2_cmirrord_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_lvmdbusd_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_lvmetad_systemd_red_hat.service.in    |    2 +-
 scripts/lvm2_lvmlockd_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_lvmlocking_systemd_red_hat.service.in |    8 ++++----
 scripts/lvm2_lvmpolld_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    4 ++--
 scripts/lvm2_pvscan_systemd_red_hat at .service.in    |    4 ++--
 13 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 10c3f44..1198baa 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -7,7 +7,7 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 ExecStart=/usr/bin/true
-ExecStop=@sbindir@/blkdeactivate -u -l wholevg -m disablequeueing -r wait
+ExecStop=@SBINDIR@/blkdeactivate -u -l wholevg -m disablequeueing -r wait
 RemainAfterExit=yes
 
 [Install]
diff --git a/scripts/com.redhat.lvmdbus1.service.in b/scripts/com.redhat.lvmdbus1.service.in
index 5578ed1..02d8ac1 100644
--- a/scripts/com.redhat.lvmdbus1.service.in
+++ b/scripts/com.redhat.lvmdbus1.service.in
@@ -1,5 +1,5 @@
 [D-BUS Service]
 Name=com.redhat.lvmdbus1
-Exec=@sbindir@/lvmdbusd --udev
+Exec=@SBINDIR@/lvmdbusd --udev
 User=root
 SystemdService=lvm2-lvmdbusd.service
diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 4924d39..de9aa52 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ DefaultDependencies=no
 
 [Service]
 Type=simple
-ExecStart=@sbindir@/dmeventd -f
+ExecStart=@SBINDIR@/dmeventd -f
 Environment=SD_ACTIVATION=1
 PIDFile=@DMEVENTD_PIDFILE@
 OOMScoreAdjust=-1000
diff --git a/scripts/lvm2_cluster_activation_systemd_red_hat.service.in b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
index 970e93a..bf4aa1e 100644
--- a/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
+++ b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 [Service]
 Type=simple
 RemainAfterExit=yes
-EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
+EnvironmentFile=- at SYSCONFDIR@/sysconfig/clvmd
 ExecStart=@systemdutildir@/lvm2-cluster-activation activate
 ExecStop=@systemdutildir@/lvm2-cluster-activation deactivate
 
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index f506fa8..ced2774 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -13,8 +13,8 @@ Conflicts=shutdown.target
 [Service]
 Type=forking
 Environment=CLVMD_OPTS=-T30
-EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@sbindir@/clvmd $CLVMD_OPTS
+EnvironmentFile=- at SYSCONFDIR@/sysconfig/clvmd
+ExecStart=@USRSBINDIR@/clvmd $CLVMD_OPTS
 SuccessExitStatus=5
 TimeoutStartSec=30
 TimeoutStopSec=10
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index 2dfc2a4..e482b9a 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 
 [Service]
 Type=forking
-ExecStart=@sbindir@/cmirrord
+ExecStart=@USRSBINDIR@/cmirrord
 PIDFile=@CMIRRORD_PIDFILE@
 Restart=on-abort
 
diff --git a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
index 64cec4e..7e4d7e4 100644
--- a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
@@ -5,7 +5,7 @@ Documentation=man:lvmdbusd(8)
 [Service]
 Type=dbus
 BusName=com.redhat.lvmdbus1
-ExecStart=@sbindir@/lvmdbusd
+ExecStart=@SBINDIR@/lvmdbusd
 
 [Install]
 WantedBy=multi-user.target
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index 8f4c60d..af34d82 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 [Service]
 Type=simple
 NonBlocking=true
-ExecStart=@sbindir@/lvmetad -f
+ExecStart=@SBINDIR@/lvmetad -f
 Environment=SD_ACTIVATION=1
 Restart=on-abort
 PIDFile=@LVMETAD_PIDFILE@
diff --git a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
index 17c7dbf..2a7544a 100644
--- a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
@@ -6,7 +6,7 @@ After=lvm2-lvmetad.service
 [Service]
 Type=simple
 NonBlocking=true
-ExecStart=@sbindir@/lvmlockd -f
+ExecStart=@SBINDIR@/lvmlockd -f
 Environment=SD_ACTIVATION=1
 PIDFile=@LVMLOCKD_PIDFILE@
 SendSIGKILL=no
diff --git a/scripts/lvm2_lvmlocking_systemd_red_hat.service.in b/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
index bfac578..62d8177 100644
--- a/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
@@ -8,16 +8,16 @@ Type=oneshot
 RemainAfterExit=yes
 
 # start lockspaces and wait for them to finish starting
-ExecStart=@sbindir@/vgchange --lock-start --lock-opt autowait
+ExecStart=@SBINDIR@/lvm vgchange --lock-start --lock-opt autowait
 
 # auto activate LVs in the newly started lockd VGs
-ExecStart=@sbindir@/vgchange -aay -S 'locktype=sanlock || locktype=dlm'
+ExecStart=@SBINDIR@/lvm vgchange -aay -S 'locktype=sanlock || locktype=dlm'
 
 # deactivate LVs in lockd VGs
-ExecStop=@sbindir@/vgchange -an -S 'locktype=sanlock || locktype=dlm'
+ExecStop=@SBINDIR@/lvm vgchange -an -S 'locktype=sanlock || locktype=dlm'
 
 # stop lockspaces and wait for them to finish stopping
-ExecStop=@sbindir@/lvmlockctl --stop-lockspaces --wait 1
+ExecStop=@SBINDIR@/lvmlockctl --stop-lockspaces --wait 1
 
 [Install]
 WantedBy=multi-user.target
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
index d7ff492..66fbd91 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
@@ -9,7 +9,7 @@ Conflicts=shutdown.target
 [Service]
 Type=simple
 NonBlocking=true
-ExecStart=@sbindir@/lvmpolld -t 60 -f
+ExecStart=@SBINDIR@/lvmpolld -t 60 -f
 Environment=SD_ACTIVATION=1
 PIDFile=@LVMPOLLD_PIDFILE@
 
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 22238b7..ebc069e 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -10,8 +10,8 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
-ExecStart=@sbindir@/lvm vgchange --monitor y --ignoreskippedcluster
-ExecStop=@sbindir@/lvm vgchange --monitor n --ignoreskippedcluster
+ExecStart=@SBINDIR@/lvm vgchange --monitor y --ignoreskippedcluster
+ExecStop=@SBINDIR@/lvm vgchange --monitor n --ignoreskippedcluster
 RemainAfterExit=yes
 
 [Install]
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 0989590..839bfd1 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -12,5 +12,5 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 RemainAfterExit=yes
-ExecStart=@sbindir@/lvm pvscan --cache --activate ay %i
-ExecStop=@sbindir@/lvm pvscan --cache %i
+ExecStart=@SBINDIR@/lvm pvscan --cache --activate ay %i
+ExecStop=@SBINDIR@/lvm pvscan --cache %i


