From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Apr 2019 06:20:31 -0400
Subject: master - systemd: put back DefaultDependencies=no for lvmpolld socket unit
Message-ID: <201904111020.x3BAKVtJ020273@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25f231cf06c3938838a64f5b88834d831f45c1c2
Commit:        25f231cf06c3938838a64f5b88834d831f45c1c2
Parent:        0cab341e1d0e8f9089d3c62d3adbec24dfd5e124
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 11 12:18:02 2019 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 11 12:18:02 2019 +0200

systemd: put back DefaultDependencies=no for lvmpolld socket unit

Previous commit 0cab341e1d0e8f9089d3c62d3adbec24dfd5e124 removed this
by mistake - we have to keep the DefaultDependencies=no - the
sockets.target is after sysinit.target.
---
 scripts/lvm2_lvmpolld_systemd_red_hat.socket.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

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


