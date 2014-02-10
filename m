From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 10 Feb 2014 15:20:58 +0000 (UTC)
Subject: master - systemd: cleanup for lvmetad systemd unit
Message-ID: <20140210152058.E8B4D60DB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffa623c53d94a75e40067a2d186ac65a64abb890
Commit:        ffa623c53d94a75e40067a2d186ac65a64abb890
Parent:        38457e1be9c3363126eadc3e04ae8b8780832668
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 10 16:18:48 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 10 16:20:45 2014 +0100

systemd: cleanup for lvmetad systemd unit

No need to fork lvmetad when running under systemd.
Also, the "lvmetad -R" support has been removed in lvm2 v2.02.98
so remove the ExecReload line that called it on "systemctl reload".
---
 WHATS_NEW                                       |    2 ++
 scripts/lvm2_lvmetad_systemd_red_hat.service.in |    5 ++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 043feae..c4a3dcb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.106 - 
 ====================================
+  Remove ExecReload from lvmetad systemd unit: lvmetad -R undefined. (2.02.98)
+  Do not fork lvmetad if running under systemd.
   Wipe DM_snapshot_cow signature without prompt in new LVs with blkid wiping.
   Avoid exposing temporary devices when initializing raid metadata volumes.
   Add internal tags command to display any tags defined on the host.
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index 0150726..8f4c60d 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -7,10 +7,9 @@ DefaultDependencies=no
 Conflicts=shutdown.target
 
 [Service]
-Type=forking
+Type=simple
 NonBlocking=true
-ExecStart=@sbindir@/lvmetad
-ExecReload=@sbindir@/lvmetad -R
+ExecStart=@sbindir@/lvmetad -f
 Environment=SD_ACTIVATION=1
 Restart=on-abort
 PIDFile=@LVMETAD_PIDFILE@


