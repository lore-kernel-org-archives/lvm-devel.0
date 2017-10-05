From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 5 Oct 2017 07:03:02 -0400
Subject: master - dmeventd: ensure systemd service gets stopped on shutdown
Message-ID: <201710051103.v95B325p015066@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a781b1c1788461595f382918bb1fc210d248d444
Commit:        a781b1c1788461595f382918bb1fc210d248d444
Parent:        3ae8adce928d4ce6ef36c87c2a0bb8aa737346b8
Author:        Thomas Lamprecht <t.lamprecht@proxmox.com>
AuthorDate:    Thu Oct 5 12:52:15 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 5 13:01:55 2017 +0200

dmeventd: ensure systemd service gets stopped on shutdown

Add these for dmeventd systemd unit (dm-event.service):

  Before: shutdown.target
  Conflicts: shutdown.target

This will cause the dmeventd to be properly stopped at shutdown (after
all the dmeventd clients unregistered their devices from monitoring)
with dm-event.service's stop action (there's no direct action defined
for the "stop" so systemd sends SIGTERM instead).

Before, we let dmeventd to get killed only as part of the very last
SIGTERM/SIGKILL for all the remaining processes late in the shutdown
sequence so we may have missed some logs if dmeventd encountered an
error during its shutdown (logging facilities are already off at this
late time in shutdown sequence).

Ref: https://www.redhat.com/archives/lvm-devel/2017-October/msg00000.html
---
 scripts/dm_event_systemd_red_hat.service.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 7c607aa..4924d39 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -3,7 +3,8 @@ Description=Device-mapper event daemon
 Documentation=man:dmeventd(8)
 Requires=dm-event.socket
 After=dm-event.socket
-Before=local-fs-pre.target
+Before=local-fs-pre.target shutdown.target
+Conflicts=shutdown.target
 DefaultDependencies=no
 
 [Service]


