From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:25:21 +0000 (UTC)
Subject: master - systemd: Add Documentation references
Message-ID: <20120620122521.345C91684@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e77803edc95d9b40e367bc447ad316bb5f9d9d8a
Commit:        e77803edc95d9b40e367bc447ad316bb5f9d9d8a
Parent:        2f99e5e35a9918c337e66b74aa6126cca9328c64
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 20 14:23:50 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 20 14:23:50 2012 +0200

systemd: Add Documentation references

These documentation references show up in "systemctl status" output.
---
 WHATS_NEW_DM                                       |    1 +
 scripts/dm_event_systemd_red_hat.service.in        |    1 +
 scripts/dm_event_systemd_red_hat.socket            |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.service.in    |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in     |    1 +
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    1 +
 6 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a0440da..33f8515 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.76 - 
 ===============================
+  Add documentation references in systemd units.
   Remove veritysetup.  Now maintained with cryptsetup.
 
 Version 1.02.75 - 8th June 2012
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
diff --git a/scripts/dm_event_systemd_red_hat.socket b/scripts/dm_event_systemd_red_hat.socket
index c580555..bfc8ea1 100644
--- a/scripts/dm_event_systemd_red_hat.socket
+++ b/scripts/dm_event_systemd_red_hat.socket
@@ -1,5 +1,6 @@
 [Unit]
 Description=Device-mapper event daemon FIFOs
+Documentation=man:dmeventd(8)
 DefaultDependencies=no
 
 [Socket]
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index e32c8a1..7552240 100644
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


