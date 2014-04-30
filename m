From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:03 +0000 (UTC)
Subject: master - makefile: fix regression
Message-ID: <20140430082803.60A6460DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1756bf6c63a69dfc48fc294352978b7f07627536
Commit:        1756bf6c63a69dfc48fc294352978b7f07627536
Parent:        62ad6dee18199f4bf80f5dc0dafa68b7f5396508
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 13:24:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:29 2014 +0200

makefile: fix regression

Commit 1af05a7a166a470d1b9d86f88fdc64c2d984124b was incorrect.
Generated files from configure could be only distclean-ed.
(in-release fix)
---
 scripts/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ed77900..c2842a4 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -125,7 +125,7 @@ install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
 	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
-CLEAN_TARGETS += \
+DIST_TARGETS += \
 	blkdeactivate.sh \
 	blk_availability_init_red_hat \
 	blk_availability_systemd_red_hat.service \


