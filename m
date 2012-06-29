From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 29 Jun 2012 11:55:53 +0000 (UTC)
Subject: master - systemd: add doc reference in dm-event.socket
Message-ID: <20120629115553.DA5F016AA@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d84e1ae5f2de569db06293aac371ce7dde1cfd62
Commit:        d84e1ae5f2de569db06293aac371ce7dde1cfd62
Parent:        a54285a715b5e34808632b4973942db354fd089a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 29 13:54:35 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 29 13:54:35 2012 +0200

systemd: add doc reference in dm-event.socket

---
 scripts/dm_event_systemd_red_hat.socket.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/dm_event_systemd_red_hat.socket.in b/scripts/dm_event_systemd_red_hat.socket.in
index c6c480c..b27c68d 100644
--- a/scripts/dm_event_systemd_red_hat.socket.in
+++ b/scripts/dm_event_systemd_red_hat.socket.in
@@ -1,5 +1,6 @@
 [Unit]
 Description=Device-mapper event daemon FIFOs
+Documentation=man:dmeventd(8)
 DefaultDependencies=no
 
 [Socket]


