From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 14 Jun 2012 14:47:50 +0200
Subject: [PATCH] Add documentation referencies in systemd units.
Message-ID: <4FD9DD76.5060504@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just a nice thing for users to see in systemd unit status output.
---
 scripts/dm_event_systemd_red_hat.service.in        |    1 +
 scripts/dm_event_systemd_red_hat.socket.in         |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.service.in    |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in     |    1 +
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    1 +
 5 files changed, 5 insertions(+)

diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 02a24c6..96c5225 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=Device-mapper event daemon
+Documentation=man:dmeventd(8)
 Requires=dm-event.socket
 After=dm-event.socket
 Before=local-fs.target
diff --git a/scripts/dm_event_systemd_red_hat.socket.in b/scripts/dm_event_systemd_red_hat.socket.in
index c6c480c..b27c68d 100644
--- a/scripts/dm_event_systemd_red_hat.socket.in
+++ b/scripts/dm_event_systemd_red_hat.socket.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=Device-mapper event daemon FIFOs
+Documentation=man:dmeventd(8)
 DefaultDependencies=no
 
 [Socket]
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index 2b6a7eb..e527369 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=LVM2 metadata daemon
+Documentation=man:lvmetad(8)
 Requires=lvm2-lvmetad.socket
 After=lvm2-lvmetad.socket
 DefaultDependencies=no
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
index f4c82a5..9a46f50 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=LVM2 metadata daemon socket
+Documentation=man:lvmetad(8)
 DefaultDependencies=no
 
 [Socket]
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index e93414d..a8d5183 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
+Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket
 After=dm-event.socket fedora-storage-init.service fedora-storage-init-late.service
 Before=local-fs.target
-- 
1.7.10.2


