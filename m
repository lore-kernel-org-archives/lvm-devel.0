From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 10:10:33 +0000 (UTC)
Subject: master - test: Move udev-lvmlockd-test to check_system
Message-ID: <20160309101033.1204F607B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6e1845f769851edbfeb88105ec37e9fe5ad3424
Commit:        c6e1845f769851edbfeb88105ec37e9fe5ad3424
Parent:        2cf13b701aba8b9c23509c91d49dd7ba5b1f4273
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 9 10:50:32 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 10:58:21 2016 +0100

test: Move udev-lvmlockd-test to check_system

---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f1fad14..43e321d 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -117,12 +117,12 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \


