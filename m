From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Oct 2012 19:56:05 +0000 (UTC)
Subject: master - systemd: various updates and fixes
Message-ID: <20121030195605.CD1D5350E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=360c569ce8f0bfe936d59ca91de2716958550524
Commit:        360c569ce8f0bfe936d59ca91de2716958550524
Parent:        09d77d0c9455a42bfe7c1c55ac64475fb349b1d6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 30 20:36:49 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 30 20:55:50 2012 +0100

systemd: various updates and fixes

Don't use lvmetad in lvm2-monitor.service ExecStop to avoid a systemd issue.
 - a systemd design issue while processing dependencies
   with socket-based activation that ends up with a hang
 - https://bugzilla.redhat.com/show_bug.cgi?id=843587
   (also tracker bug https://bugzilla.redhat.com/show_bug.cgi?id=871527)
 - not using lvmetad in this case is just a workaround, once the bug
   above is resolved, we should enable the lvmetad in that specific case

Remove dependency on fedora-storage-init.service in lvm2 systemd units.
 - fedora-storage-init.service and fedora-storage-init-late.service is
   going to be separated into respective units that belong to each block
   device subsystem:
     - mpath + mdraid activated via udev solely
     - dmraid with its own dmraid-activation.service unit
     - lvm2 with the lvm2-activation-generator to generate the
       activation units runtime if lvmetad disabled
       (global/use_lvmetad=0 set in lvm.conf) and activation done
       via udev+lvmetad if lvmetad enabled (global/use_lvmetad=1 set
       in lvm.conf)

Depend on lvm2-lvmetad.socket in lvm2-monitor.service systemd unit.
 - as lvm2-monitor uses lvmetad if lvmetad is enabled
---
 WHATS_NEW                                          |    3 +++
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    7 ++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b71402..a3f8142 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.99 - 
 ===================================
+  Don't use lvmetad in lvm2-monitor.service ExecStop to avoid a systemd issue.
+  Remove dependency on fedora-storage-init.service in lvm2 systemd units.
+  Depend on lvm2-lvmetad.socket in lvm2-monitor.service systemd unit.
   Hardcode use_lvmetad=0 if cluster locking used and issue a warning msg.
   Avoid reading mirrors with failed devices in its mirrored log.
   Avoid reading from mirrors that have failed devices if they block I/O.
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 6c4c55f..e6b4814 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -1,8 +1,8 @@
 [Unit]
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
-Requires=dm-event.socket
-After=dm-event.socket fedora-storage-init.service fedora-storage-init-late.service lvm2-activation.service lvm2-lvmetad.service
+Requires=dm-event.socket lvm2-lvmetad.socket
+After=dm-event.socket lvm2-lvmetad.socket lvm2-lvmetad.service
 Before=local-fs.target
 DefaultDependencies=no
 Conflicts=shutdown.target
@@ -11,7 +11,8 @@ Conflicts=shutdown.target
 Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 ExecStart=@sbindir@/lvm vgchange --monitor y
-ExecStop=@sbindir@/lvm vgchange --monitor n
+# The lvmetad must be disabled here, it needs https://bugzilla.redhat.com/show_bug.cgi?id=843587 to be resolved first.
+ExecStop="@sbindir@/lvm vgchange --monitor n --config 'global{use_lvmetad=0}'"
 RemainAfterExit=yes
 
 [Install]


