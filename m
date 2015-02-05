From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:45 +0000 (UTC)
Subject: master - test: Fix implementation of check targets with new flavour system.
Message-ID: <20150205134245.92D0C601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d04c7ca0b61e42f831b90e54ecbb7fa6e943edd4
Commit:        d04c7ca0b61e42f831b90e54ecbb7fa6e943edd4
Parent:        68f7b422c10cc0c042d74ceac4bf9a27c625a99c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 11:11:12 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Fix implementation of check targets with new flavour system.

---
 test/Makefile.in |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 82adf20..690e7e4 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -102,28 +102,28 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--only $(T) --skip $(S)
+		--flavours ndev-vanilla,ndev-cluster,ndev-lvmetad --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--only udev- --only $(T) --skip $(S)
+		--flavours udev-vanilla,udev-cluster,udev-lvmetad --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--only ndev-cluster --only $(T) --skip $(S)
+		--flavours ndev-cluster --only $(T) --skip $(S)
 
 check_local: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--only ndev- --only $(T) --skip $(S)
+		--flavours ndev-vanilla --only $(T) --skip $(S)
 
 ifeq ("@BUILD_LVMETAD@", "yes")
 check_lvmetad: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
-		--only ndev-lvmetad --only $(T) --skip $(S)
+		--flavours ndev-lvmetad --only $(T) --skip $(S)
 endif
 
 DATADIR = $(datadir)/lvm2-testsuite


