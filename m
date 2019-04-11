From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Apr 2019 06:26:06 -0400
Subject: stable-2.02 - systemd: put back DefaultDependencies=no for lvmpolld and lvmetad socket unit
Message-ID: <201904111026.x3BAQ64r021076@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03d6cfdd99fb1c2fd85721ab6faebbb1b6658873
Commit:        03d6cfdd99fb1c2fd85721ab6faebbb1b6658873
Parent:        6064b9f1b283c63cc3710555a04d2df0c6357cb0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 11 12:22:27 2019 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 11 12:25:45 2019 +0200

systemd: put back DefaultDependencies=no for lvmpolld and lvmetad socket unit

Previous commit 0a726a7e268b31856615491809af73bda5d4d6f9 removed this
by mistake - we have to keep the DefaultDependencies=no - the
sockets.target is after sysinit.target.
---
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in  |    2 ++
 scripts/lvm2_lvmpolld_systemd_red_hat.socket.in |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
index 3201537..2663c72 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
@@ -1,6 +1,8 @@
 [Unit]
 Description=LVM2 metadata daemon socket
 Documentation=man:lvmetad(8)
+DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmetad.socket
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
index 743669e..0537d7f 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
@@ -1,6 +1,8 @@
 [Unit]
 Description=LVM2 poll daemon socket
 Documentation=man:lvmpolld(8)
+DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmpolld.socket


