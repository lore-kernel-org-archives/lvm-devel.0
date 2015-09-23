From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Sep 2015 11:31:12 +0000 (UTC)
Subject: master - systemd: use {local, remote}-fs-pre.target instead of {local, remote}-fs.target
Message-ID: <20150923113112.09AD161084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb82919b0d77ebeeb7d35d39b9c8584e806433bf
Commit:        cb82919b0d77ebeeb7d35d39b9c8584e806433bf
Parent:        28aff5d240bd73ad0501504ed596819f2d4f058a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 23 13:17:12 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 23 13:30:51 2015 +0200

systemd: use {local,remote}-fs-pre.target instead of {local,remote}-fs.target

We want most of our units to be started before any local/remote mount
points are mounted - we used {local,remote}-fs.target for this purpose
before, but it was not 100% correct as there's even {local,remote}-fs-pre.target
special systemd unit reserved for this exact purpose.

See also man 7 systemd.special and "local-fs-pre.target"/"remote-fs-pre.target"
description.
---
 WHATS_NEW                                          |    1 +
 WHATS_NEW_DM                                       |    1 +
 man/lvm2-activation-generator.8.in                 |    4 ++--
 scripts/dm_event_systemd_red_hat.service.in        |    2 +-
 .../lvm2_activation_generator_systemd_red_hat.c    |    8 ++++----
 scripts/lvm2_clvmd_systemd_red_hat.service.in      |    2 +-
 scripts/lvm2_cmirrord_systemd_red_hat.service.in   |    2 +-
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 8 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a97dc4..d693ab8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Fix lvm2-{activation,clvmd,cmirrord,monitor} service to exec before mounting.
 
 Version 2.02.132 - 22nd September 2015
 ======================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 51e1be6..f198a50 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Fix dm-event systemd service to make sure it is executed before mounting.
 
 Version 1.02.109 - 22nd September 2016
 ======================================
diff --git a/man/lvm2-activation-generator.8.in b/man/lvm2-activation-generator.8.in
index 0f6d838..e1be5e1 100644
--- a/man/lvm2-activation-generator.8.in
+++ b/man/lvm2-activation-generator.8.in
@@ -28,8 +28,8 @@ layered on top of encrypted devices.
 
 \fIlvm2-activation-net.service\fP
 used for activation of LVM2 volumes that is ordered after systemd's
-special \fBremote-fs.target\fP to support LVM2 volumes which are layered
-on attached remote devices.
+special \fBremote-fs-pre.target\fP to support LVM2 volumes which are
+layered on attached remote devices.
 
 Note that all the underlying devices (Physical Volumes) need to be present
 when the service is run. If the there are any devices presented in the system
diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 3791618..7c607aa 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -3,7 +3,7 @@ Description=Device-mapper event daemon
 Documentation=man:dmeventd(8)
 Requires=dm-event.socket
 After=dm-event.socket
-Before=local-fs.target
+Before=local-fs-pre.target
 DefaultDependencies=no
 
 [Service]
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index cd71b9c..8a1b173 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -28,8 +28,8 @@
 #define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
 #define LVM_CONF_USE_LVMPOLLD	"global/use_lvmpolld"
 
-#define UNIT_TARGET_LOCAL_FS  "local-fs.target"
-#define UNIT_TARGET_REMOTE_FS "remote-fs.target"
+#define UNIT_TARGET_LOCAL_FS  "local-fs-pre.target"
+#define UNIT_TARGET_REMOTE_FS "remote-fs-pre.target"
 
 static char unit_path[PATH_MAX];
 static char target_path[PATH_MAX];
@@ -135,7 +135,7 @@ static int generate_unit(const char *dir, int unit, int sysinit_needed)
 
 	if (unit == UNIT_NET) {
 		fprintf(f, "After=%s iscsi.service fcoe.service\n"
-			"Before=remote-fs.target shutdown.target\n\n"
+			"Before=remote-fs-pre.target shutdown.target\n\n"
 			"[Service]\n"
 			"ExecStartPre=/usr/bin/udevadm settle\n", unit_names[UNIT_MAIN]);
 	} else {
@@ -145,7 +145,7 @@ static int generate_unit(const char *dir, int unit, int sysinit_needed)
 		} else
 			fprintf(f, "After= %s cryptsetup.target\n", unit_names[UNIT_EARLY]);
 
-		fputs("Before=local-fs.target shutdown.target\n"
+		fputs("Before=local-fs-pre.target shutdown.target\n"
 		      "Wants=systemd-udev-settle.service\n\n"
 		      "[Service]\n", f);
 	}
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index 2978d21..f506fa8 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -2,7 +2,7 @@
 Description=Clustered LVM daemon
 Documentation=man:clvmd(8)
 After=dlm.service corosync.service
-Before=remote-fs.target
+Before=remote-fs-pre.target
 Requires=network.target dlm.service corosync.service
 RefuseManualStart=true
 RefuseManualStop=true
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index 16d38ce..2dfc2a4 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -3,7 +3,7 @@ Description=Clustered LVM mirror log daemon
 Documentation=man:cmirrord(8)
 Requires=corosync.service
 After=corosync.service
-Before=remote-fs.target
+Before=remote-fs-pre.target
 DefaultDependencies=no
 Conflicts=shutdown.target
 
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 6aacdc2..22238b7 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -3,7 +3,7 @@ Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progres
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket lvm2-lvmetad.socket
 After=dm-event.socket dm-event.service lvm2-lvmetad.socket lvm2-activation.service lvm2-lvmetad.service
-Before=local-fs.target
+Before=local-fs-pre.target
 DefaultDependencies=no
 Conflicts=shutdown.target
 


