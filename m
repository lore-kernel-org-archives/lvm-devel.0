From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 9 Apr 2019 06:27:50 -0400
Subject: master - systemd: add missing Before=shutdown.target to LVM2 services to fix shutdown ordering
Message-ID: <201904091027.x39ARoDQ001665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cab341e1d0e8f9089d3c62d3adbec24dfd5e124
Commit:        0cab341e1d0e8f9089d3c62d3adbec24dfd5e124
Parent:        344a9e9afd9f9038f53887e55e721033d1dc3b65
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 9 12:10:17 2019 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 9 12:24:37 2019 +0200

systemd: add missing Before=shutdown.target to LVM2 services to fix shutdown ordering

We already used Conflicts=shutdown target to stop LVM2 services on shutdown.
But we still missed the ordering - the shutdown.target should be reached
only after all the services are really stopped.

Reported here: https://github.com/lvmteam/lvm2/issues/17
---
 WHATS_NEW                                          |    1 +
 .../blk_availability_systemd_red_hat.service.in    |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 ++
 scripts/lvm2_cmirrord_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_lvmpolld_systemd_red_hat.service.in   |    1 +
 scripts/lvm2_lvmpolld_systemd_red_hat.socket.in    |    2 --
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 7 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 728019e..0f0c6ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
   Skip autoactivation for a PV when PV size does not match device size.
   Remove first-pvscan-initialization which should no longer be needed.
   Add remote refresh through lvmlockd/dlm for shared LVs after lvextend.
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index da332c2..82d3b82 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=Availability of block devices
+Before=shutdown.target
 After=lvm2-activation.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
 DefaultDependencies=no
 Conflicts=shutdown.target
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index f906f08..0f4ac8d 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -139,6 +139,8 @@ static int generate_unit(struct generator *gen, int unit)
 	      "Documentation=man:lvm2-activation-generator(8)\n"
 	      "SourcePath=/etc/lvm/lvm.conf\n" "DefaultDependencies=no\n", f);
 
+	fputs("Conflicts=shutdown.target\n", f);
+
 	if (unit == UNIT_NET) {
 		fprintf(f, "After=%s iscsi.service fcoe.service rbdmap.service\n"
 			"Before=remote-fs-pre.target shutdown.target\n\n"
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index e482b9a..fc73aea 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -3,7 +3,7 @@ Description=Clustered LVM mirror log daemon
 Documentation=man:cmirrord(8)
 Requires=corosync.service
 After=corosync.service
-Before=remote-fs-pre.target
+Before=remote-fs-pre.target shutdown.target
 DefaultDependencies=no
 Conflicts=shutdown.target
 
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
index 4ad4e61..a06cbe9 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
@@ -2,6 +2,7 @@
 Description=LVM2 poll daemon
 Documentation=man:lvmpolld(8)
 Requires=lvm2-lvmpolld.socket
+Before=shutdown.target
 After=lvm2-lvmpolld.socket
 DefaultDependencies=no
 Conflicts=shutdown.target
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
index 0537d7f..743669e 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
@@ -1,8 +1,6 @@
 [Unit]
 Description=LVM2 poll daemon socket
 Documentation=man:lvmpolld(8)
-DefaultDependencies=no
-Conflicts=shutdown.target
 
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmpolld.socket
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 7ec4e4e..4bf744a 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -3,7 +3,7 @@ Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progres
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket
 After=dm-event.socket dm-event.service lvm2-activation.service
-Before=local-fs-pre.target
+Before=local-fs-pre.target shutdown.target
 DefaultDependencies=no
 Conflicts=shutdown.target
 


