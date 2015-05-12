From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 May 2015 10:41:36 +0000 (UTC)
Subject: master - tests: ndev by default
Message-ID: <20150512104136.36D8760E21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=100daa7fd882ee4ba8626930283340ed05219470
Commit:        100daa7fd882ee4ba8626930283340ed05219470
Parent:        68e8030fe72fa25aa01c923c120574cd0fbe94ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 20:04:35 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 12 12:40:37 2015 +0200

tests: ndev by default

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bf34201..2a193ab 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -144,7 +144,7 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 check_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--flavours udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpolld --only $(T) --skip $(S)
+		--flavours ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
 endif
 
 DATADIR = $(datadir)/lvm2-testsuite


