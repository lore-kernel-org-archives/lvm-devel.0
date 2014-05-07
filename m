From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  7 May 2014 10:15:23 +0000 (UTC)
Subject: master - make: fix commit 1756bf6
Message-ID: <20140507101523.CDD7660302@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d64573da135b489e1b3079612e77363526ca44d
Commit:        9d64573da135b489e1b3079612e77363526ca44d
Parent:        1899783aa646cfc7f4851de7231f4f2db65b6986
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 7 12:13:36 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 7 12:13:36 2014 +0200

make: fix commit 1756bf6

"DIST_TARGET" should be "DISTCLEAN_TARGET"
---
 scripts/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index c2842a4..2c92033 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -125,7 +125,7 @@ install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
 	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
-DIST_TARGETS += \
+DISTCLEAN_TARGETS += \
 	blkdeactivate.sh \
 	blk_availability_init_red_hat \
 	blk_availability_systemd_red_hat.service \


