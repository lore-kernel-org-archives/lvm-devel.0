From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Jul 2018 09:03:20 -0400
Subject: master - test: Remove excessive comma resulting in empty flavour
Message-ID: <201807261303.w6QD3KoU018278@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f49d463d6c362a472d3ba721f91558602901a33
Commit:        7f49d463d6c362a472d3ba721f91558602901a33
Parent:        a004bb07f14baeed158ac9ea571cf5a6882c436f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 26 14:56:08 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 26 14:56:08 2018 +0200

test: Remove excessive comma resulting in empty flavour

---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5185322..a9bb083 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -123,12 +123,12 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours ndev-vanilla$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours udev-vanilla,$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours udev-vanilla$(LVMPOLLD_UDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_local: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \


