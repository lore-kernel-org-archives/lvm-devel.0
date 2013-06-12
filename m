From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:17:04 +0000 (UTC)
Subject: master - distclean: add missing items
Message-ID: <20130612111704.46E1560FAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56ee1de7e4509aff264d2c682e7690101248b73d
Commit:        56ee1de7e4509aff264d2c682e7690101248b73d
Parent:        8bade9bfeae9b4205472d70232676d70412eefa8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 12:51:38 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 13:14:49 2013 +0200

distclean: add missing items

These were missing in distclean target under scripts dir:
  blk_availability_init_red_hat
  blk_availability_systemd_red_hat.service
  blkdeactivate.sh
---
 scripts/Makefile.in |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 91e2e94..a658903 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -118,4 +118,6 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
 		     lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_tmpfiles_red_hat.conf
+		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
+		     blk_availability_systemd_red_hat.service \
+		     blkdeactivate.sh


