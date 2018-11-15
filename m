From: David Teigland <teigland@sourceware.org>
Date: Thu, 15 Nov 2018 10:23:15 -0500
Subject: master - lvm2-monitoring service shouldn't refer to lvmetad
Message-ID: <201811151523.wAFFNFMn019551@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df2fa88e631b13f0f2cfff4aeab80f12bd93ab72
Commit:        df2fa88e631b13f0f2cfff4aeab80f12bd93ab72
Parent:        16fed9ef0c4ea5ba20063c9fbf36c0c1292f87b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 15 09:20:47 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 15 09:20:47 2018 -0600

lvm2-monitoring service shouldn't refer to lvmetad

---
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 4144862..7ec4e4e 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -1,8 +1,8 @@
 [Unit]
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
-Requires=dm-event.socket lvm2-lvmetad.socket
-After=dm-event.socket dm-event.service lvm2-lvmetad.socket lvm2-activation.service lvm2-lvmetad.service
+Requires=dm-event.socket
+After=dm-event.socket dm-event.service lvm2-activation.service
 Before=local-fs-pre.target
 DefaultDependencies=no
 Conflicts=shutdown.target


