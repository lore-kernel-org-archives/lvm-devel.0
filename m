From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 28 Jul 2011 14:27:03 +0200
Subject: [PATCH 1/3] Add systemd units for dmeventd and lvm2 monitoring
Message-ID: <4E315597.4040103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These units are already being used and tested in Fedora rawhide directly:

  dm_event_systemd_red_hat.service.in (dm-event.service)
  dm_event_systemd_red_hat.socket (dm-event.socket)
  lvm2_monitoring_systemd_red_hat.service.in (lvm2-monitor.service)

I'm just resending them here for any additional comments
(I've just added the OOMScoreAdjust to dm-event.service
and SocketMode to dm-event.socket when compared to rawhide).

Note: Conflicts: shutdown.target will stop monitoring before
unmounting any mounted filesystems. But this is as far as we
can go now. Monitor deactivation should be done later, but
that will be handled properly if we have shutdown ramfs in
place (which is also planned, at least for Fedora 16).

Peter

---

 scripts/dm_event_systemd_red_hat.service.in        |   14 ++++++++++++++
 scripts/dm_event_systemd_red_hat.socket            |   11 +++++++++++
 scripts/lvm2_monitoring_systemd_red_hat.service.in |   17 +++++++++++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
new file mode 100644
index 0000000..32295d3
--- /dev/null
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -0,0 +1,14 @@
+[Unit]
+Description=Device-mapper event daemon
+After=fedora-storage-init.service fedora-storage-init-late.service
+Before=local-fs.target
+DefaultDependencies=no
+
+[Service]
+Type=forking
+ExecStart=@sbindir@/dmeventd
+PIDFile=@DMEVENTD_PIDFILE@
+OOMScoreAdjust=-1000
+
+[Install]
+WantedBy=sysinit.target
diff --git a/scripts/dm_event_systemd_red_hat.socket b/scripts/dm_event_systemd_red_hat.socket
new file mode 100644
index 0000000..c580555
--- /dev/null
+++ b/scripts/dm_event_systemd_red_hat.socket
@@ -0,0 +1,11 @@
+[Unit]
+Description=Device-mapper event daemon FIFOs
+DefaultDependencies=no
+
+[Socket]
+ListenFIFO=/var/run/dmeventd-server
+ListenFIFO=/var/run/dmeventd-client
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
new file mode 100644
index 0000000..4715416
--- /dev/null
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -0,0 +1,17 @@
+[Unit]
+Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
+Requires=dm-event.socket
+After=fedora-storage-init.service fedora-storage-init-late.service
+Before=local-fs.target
+DefaultDependencies=no
+Conflicts=shutdown.target
+
+[Service]
+Type=oneshot
+ExecStart=@sbindir@/lvm vgchange --monitor y
+ExecStop=@sbindir@/lvm vgchange --monitor n
+RemainAfterExit=yes
+
+[Install]
+WantedBy=sysinit.target
+Also=dm-event.socket



