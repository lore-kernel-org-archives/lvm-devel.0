From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Jun 2014 13:51:45 +0000 (UTC)
Subject: master - systemd: use RemoveOnStop for dm-event.socket and lvm2-lvmetad.socket
Message-ID: <20140613135145.8DFB060E06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fea8abe56ae506e8c924a317cd701e159aab824c
Commit:        fea8abe56ae506e8c924a317cd701e159aab824c
Parent:        4c9fbe048fa9a7b9c21ef96aa431a28151acdb1d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 13 15:45:25 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 13 15:45:25 2014 +0200

systemd: use RemoveOnStop for dm-event.socket and lvm2-lvmetad.socket

Systemd version 214 introduced new "RemoveOnStop" option for socket
units to remove the socket/FIFO when the particular unit is stopped.

Also https://bugzilla.redhat.com/show_bug.cgi?id=802748.
---
 WHATS_NEW                                      |    1 +
 WHATS_NEW_DM                                   |    1 +
 scripts/dm_event_systemd_red_hat.socket.in     |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.socket.in |    1 +
 4 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6791f34..dcde550 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
   Add thin-generic configuration profile for generic thin settings.
   Fix crash when reporting of empty labels on pvs.
   Use retry_deactivation also when cleaning orphan devices.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 976f927..90dd5f5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Use RemoveOnStop for dm-event.socket systemd unit.
   Document env var 'DM_DEFAULT_NAME_MANGLING_MODE' in dmsetup man page.
   Warn user about incorrect use of cookie with 'dmsetup remove --force'.
   Also recognize 'help'/'?' as reserved sort key name to show help.
diff --git a/scripts/dm_event_systemd_red_hat.socket.in b/scripts/dm_event_systemd_red_hat.socket.in
index b27c68d..80bcbb9 100644
--- a/scripts/dm_event_systemd_red_hat.socket.in
+++ b/scripts/dm_event_systemd_red_hat.socket.in
@@ -7,6 +7,7 @@ DefaultDependencies=no
 ListenFIFO=@DEFAULT_DM_RUN_DIR@/dmeventd-server
 ListenFIFO=@DEFAULT_DM_RUN_DIR@/dmeventd-client
 SocketMode=0600
+RemoveOnStop=true
 
 [Install]
 WantedBy=sockets.target
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
index 071fd64..9575f98 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.socket.in
@@ -6,6 +6,7 @@ DefaultDependencies=no
 [Socket]
 ListenStream=@DEFAULT_RUN_DIR@/lvmetad.socket
 SocketMode=0600
+RemoveOnStop=true
 
 [Install]
 WantedBy=sysinit.target


