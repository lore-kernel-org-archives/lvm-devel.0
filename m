From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Oct 2013 07:50:43 +0000 (UTC)
Subject: master - cleanup: for commit 546db1c
Message-ID: <20131023075043.0CFF560EF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1dd6626696b100c8cf176921917418bb8d7f8055
Commit:        1dd6626696b100c8cf176921917418bb8d7f8055
Parent:        9883bffb0403d743641bb0971332b5ff0e373652
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 23 09:48:33 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 23 09:48:33 2013 +0200

cleanup: for commit 546db1c

 - properly clean lvm2-pvscan at .service on distclean
 - use @sbindir@ for sbin path in ExecStop
---
 scripts/Makefile.in                             |    2 +-
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index fac7e40..3616afa 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -119,7 +119,7 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
 		     lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_lvmetad_systemd_red_hat at .service \
+		     lvm2_pvscan_systemd_red_hat at .service \
 		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
 		     blk_availability_systemd_red_hat.service \
 		     blkdeactivate.sh
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 07ea5ca..4225982 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -11,4 +11,4 @@ Conflicts=shutdown.target
 Type=oneshot
 RemainAfterExit=yes
 ExecStart=@sbindir@/pvscan --cache --activate ay /dev/block/%i
-ExecStop=/usr/sbin/pvscan --cache %i
+ExecStop=@sbindir@/pvscan --cache %i


