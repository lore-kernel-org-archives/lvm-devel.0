From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:20 -0400
Subject: master - systemd: add conficting sockets
Message-ID: <201806142003.w5EK3KYT004079@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b58160a1913fdd61c378479f6362bd904e7de942
Commit:        b58160a1913fdd61c378479f6362bd904e7de942
Parent:        a35098b1102eb7f387e90bd16da4cf3ed833ca57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 12 16:27:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

systemd: add conficting sockets

Since we are using "DefaultDependencies=no" we do not get automatic STOP
job on socket connection - so automatically refuse connection on
shutdown by adding this Conflict definition to socket Unit.
---
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in  |    1 +
 scripts/lvm2_lvmpolld_systemd_red_hat.socket.in |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
index 9575f98..2663c72 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
@@ -2,6 +2,7 @@
 Description=LVM2 metadata daemon socket
 Documentation=man:lvmetad(8)
 DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmetad.socket
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
index ca9f123..0537d7f 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
@@ -2,6 +2,7 @@
 Description=LVM2 poll daemon socket
 Documentation=man:lvmpolld(8)
 DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmpolld.socket


