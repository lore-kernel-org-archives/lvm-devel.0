From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:37:48 -0400
Subject: master - Remove systemd script for starting shared VG
Message-ID: <201806131937.w5DJbmAQ017689@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa00fce97c1eabef9f1ec88dd420660cd4d6f004
Commit:        fa00fce97c1eabef9f1ec88dd420660cd4d6f004
Parent:        a163d5341a90c1c2f656b0d15c055bbd90333a60
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 14:35:27 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 14:37:16 2018 -0500

Remove systemd script for starting shared VG

Shared VGs will generally be started and activated by
the resource agent.  Without the agent, this script doesn't
have a good way to know which LVs to activate.
---
 scripts/lvm2_lvmlocking_systemd_red_hat.service.in |   24 --------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/scripts/lvm2_lvmlocking_systemd_red_hat.service.in b/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
deleted file mode 100644
index 62d8177..0000000
--- a/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
+++ /dev/null
@@ -1,24 +0,0 @@
-[Unit]
-Description=Availability of lockspaces in lvmlockd
-Documentation=man:lvmlockd(8)
-After=lvm2-lvmlockd.service sanlock.service dlm.service
-
-[Service]
-Type=oneshot
-RemainAfterExit=yes
-
-# start lockspaces and wait for them to finish starting
-ExecStart=@SBINDIR@/lvm vgchange --lock-start --lock-opt autowait
-
-# auto activate LVs in the newly started lockd VGs
-ExecStart=@SBINDIR@/lvm vgchange -aay -S 'locktype=sanlock || locktype=dlm'
-
-# deactivate LVs in lockd VGs
-ExecStop=@SBINDIR@/lvm vgchange -an -S 'locktype=sanlock || locktype=dlm'
-
-# stop lockspaces and wait for them to finish stopping
-ExecStop=@SBINDIR@/lvmlockctl --stop-lockspaces --wait 1
-
-[Install]
-WantedBy=multi-user.target
-


