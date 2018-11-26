From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Nov 2018 15:52:41 -0500
Subject: master - blk_availability service drop lvmetad
Message-ID: <201811262052.wAQKqfVv032155@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d1152103f8fce4892380f75f59dd5013bcd84d3
Commit:        2d1152103f8fce4892380f75f59dd5013bcd84d3
Parent:        4b5d6de86b3fd3a06b913708e477b603627c8614
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 26 14:51:32 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 26 14:51:32 2018 -0600

blk_availability service drop lvmetad

---
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 9462072..da332c2 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,6 +1,6 @@
 [Unit]
 Description=Availability of block devices
-After=lvm2-activation.service lvm2-lvmetad.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
+After=lvm2-activation.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
 DefaultDependencies=no
 Conflicts=shutdown.target
 


