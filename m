From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 24 Feb 2016 15:58:20 +0000 (UTC)
Subject: master - tests: include lvmlockd in default make check
Message-ID: <20160224155820.B43AA60F99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77f034bfa3d85600ec9b9581c17352202ce09ae8
Commit:        77f034bfa3d85600ec9b9581c17352202ce09ae8
Parent:        e79325308454814d968dd3e06cd261a269716675
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 23 16:34:46 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 16:34:46 2016 -0600

tests: include lvmlockd in default make check

---
 test/Makefile.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 6ed9b9e..98f6cc9 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -54,6 +54,11 @@ LVMPOLLD_NDEV_FLAVOUR = ,ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpol
 LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpolld
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+LVMLOCKD_RUN_BASE = $(RUN_BASE)
+LVMLOCKD_UDEV_FLAVOUR = ,udev-lvmlockd-test
+endif
+
 # Shell quote;
 SHELL_PATH_SQ := $(subst ','\'',$(SHELL_PATH))
 
@@ -112,7 +117,7 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR)$(LVMLOCKD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \


