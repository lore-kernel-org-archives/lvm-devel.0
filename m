From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 1 Nov 2017 10:38:58 -0400
Subject: master - systemd: remove Install sections from socket-activated services
Message-ID: <201711011438.vA1EcwiW006092@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58b763c99cb7620b1cc2313a9f0dccd98def53db
Commit:        58b763c99cb7620b1cc2313a9f0dccd98def53db
Parent:        7a394575fbb11aad1ad61f4caa8f16584ae45102
Author:        Bastian Blank <waldi@debian.org>
AuthorDate:    Wed Nov 1 15:25:54 2017 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 1 15:37:19 2017 +0100

systemd: remove Install sections from socket-activated services

We always preferred and recommended socket activation for our services
so remove the Install section in related .service units which are unused
in this case and keep only the Install section in associated .socket
units.

Signed-off-by: Bastian Blank <waldi@debian.org>
---
 WHATS_NEW                                        |    1 +
 WHATS_NEW_DM                                     |    1 +
 scripts/dm_event_systemd_red_hat.service.in      |    3 ---
 scripts/lvm2_lvmetad_systemd_red_hat.service.in  |    3 ---
 scripts/lvm2_lvmpolld_systemd_red_hat.service.in |    3 ---
 5 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ab4f656..ac4053a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Keep Install section only in lvm2-{lvmetad,lvmpolld}.socket systemd unit.
   liblvm: Fix segfault in lvm_pv_remove. (2.02.173)
   Do not allow storing VG metadata with LV without any segment.
   Fix printed message when thin snapshot was already merged.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6475fbd..12cd7f8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.145 - 
 ===================================
+  Keep Install section only in dm-event.socket systemd unit.
   Issue a specific error with dmsetup status if device is unknown.
   Fix RT_LIBS reference in generated libdevmapper.pc for pkg-config
 
diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index de9aa52..d2c4cf1 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -13,6 +13,3 @@ ExecStart=@SBINDIR@/dmeventd -f
 Environment=SD_ACTIVATION=1
 PIDFile=@DMEVENTD_PIDFILE@
 OOMScoreAdjust=-1000
-
-[Install]
-WantedBy=sysinit.target
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index af34d82..92e6d69 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -13,6 +13,3 @@ ExecStart=@SBINDIR@/lvmetad -f
 Environment=SD_ACTIVATION=1
 Restart=on-abort
 PIDFile=@LVMETAD_PIDFILE@
-
-[Install]
-WantedBy=sysinit.target
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
index 66fbd91..4ad4e61 100644
--- a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
@@ -12,6 +12,3 @@ NonBlocking=true
 ExecStart=@SBINDIR@/lvmpolld -t 60 -f
 Environment=SD_ACTIVATION=1
 PIDFile=@LVMPOLLD_PIDFILE@
-
-[Install]
-WantedBy=sysinit.target


