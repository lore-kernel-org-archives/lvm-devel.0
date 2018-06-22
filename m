From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:07:55 -0400
Subject: 2018-06-01-stable - systemd: add conficting sockets
Message-ID: <201806221307.w5MD7tuk019637@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9546edeef90af11cd8d80fc586caf40aad3640a0
Commit:        9546edeef90af11cd8d80fc586caf40aad3640a0
Parent:        716199334c09b4acf9f536ee6d4ca5e1d52f37db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 12 16:27:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:32:31 2018 +0200

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


