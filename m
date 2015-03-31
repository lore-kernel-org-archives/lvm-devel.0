From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 Mar 2015 13:51:40 +0000 (UTC)
Subject: master - systemd: stop lvm2-pvscan@.service before lvm2-lvmetad.service
Message-ID: <20150331135140.9E5D260F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=666738d57a6e6b4005030995a9641933c1a54e9d
Commit:        666738d57a6e6b4005030995a9641933c1a54e9d
Parent:        139df7c4a310486d49fdd95039891b91f793ff44
Author:        Michael Lass <bevan@bi-co.net>
AuthorDate:    Tue Mar 31 15:47:01 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 31 15:47:01 2015 +0200

systemd: stop lvm2-pvscan at .service before lvm2-lvmetad.service

When lvm2-pvscan at .service and lvm2-lvmetad.service are scheduled to be
stopped lvm2-pvscan at .service should be stopped first since pvscan uses
lvmetad.

This is especially important if lvm2-lvmetad.socket is also scheduled to
be stopped as in this case connection requests are suppressed causing
pvscan to fail.
---
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 7d3b291..03651d5 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -4,7 +4,7 @@ Documentation=man:pvscan(8)
 DefaultDependencies=no
 BindsTo=dev-block-%i.device
 Requires=lvm2-lvmetad.socket
-After=lvm2-lvmetad.socket
+After=lvm2-lvmetad.socket lvm2-lvmetad.service
 Before=shutdown.target
 Conflicts=shutdown.target
 


