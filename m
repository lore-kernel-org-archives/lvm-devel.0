From: Michael Lass <bevan@bi-co.net>
Date: Sun, 29 Mar 2015 23:06:40 +0200
Subject: [PATCH] systemd: stop lvm2-pvscan@.service before lvm2-lvmetad.service
Message-ID: <1427663200-2349-1-git-send-email-bevan@bi-co.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When lvm2-pvscan at .service and lvm2-lvmetad.service are scheduled to be stopped
lvm2-pvscan at .service should be stopped first since pvscan uses lvmetad.

This is especially important if lvm2-lvmetad.socket is also scheduled to be
stopped as in this case connection requests are suppressed causing pvscan to
fail.
---
 scripts/lvm2_pvscan_systemd_red_hat at .service.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
 
-- 
2.3.4


