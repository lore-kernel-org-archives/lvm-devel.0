From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:53:59 +0000 (UTC)
Subject: master - test: Add a new "check_full" target, which also tests with real /dev.
Message-ID: <20130828125359.C6FCD60FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64fe17dc94ce3b7cc547c9fc544c34460d99d5b3
Commit:        64fe17dc94ce3b7cc547c9fc544c34460d99d5b3
Parent:        b516a72b117eeee627f469369fadf56caf3041a7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 23 10:09:23 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

test: Add a new "check_full" target, which also tests with real /dev.

The original "check" target stays confined to a local device directory, while
check_full does 6 flavours, 3 with a local device directory and 3 with the
global /dev directory (the latter are prefixed with "s" for
"system"). I.e.: normal, cluster, lvmetad, snormal, scluster, slvmetad.
---
 Makefile.in      |    2 +-
 test/Makefile.in |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 2ee20e5..81002ea 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -94,7 +94,7 @@ all: cscope.out
 endif
 DISTCLEAN_TARGETS += cscope.out
 
-check check_cluster check_local check_lvmetad unit: all
+check check_full check_cluster check_local check_lvmetad unit: all
 	$(MAKE) -C test $(@)
 
 install_system_dirs:
diff --git a/test/Makefile.in b/test/Makefile.in
index 89092d0..b663e7a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -77,6 +77,22 @@ check: .tests-stamp
 		      $(patsubst %,cluster:%,$(RUN_BASE)) \
 		      $(patsubst %,lvmetad:%,$(RUN_BASE))
 
+check_full: .tests-stamp
+	VERBOSE=$(VEROSE) \
+	cluster_LVM_TEST_LOCKING=3 \
+	scluster_LVM_TEST_LOCKING=3 \
+	lvmetad_LVM_TEST_LVMETAD=1 \
+	slvmetad_LVM_TEST_LVMETAD=1 \
+	snormal_LVM_TEST_DEVDIR=/dev \
+	scluster_LVM_TEST_DEVDIR=/dev \
+	slvmetad_LVM_TEST_DEVDIR=/dev \
+	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
+		      $(patsubst %,cluster:%,$(RUN_BASE)) \
+		      $(patsubst %,lvmetad:%,$(RUN_BASE)) \
+		      $(patsubst %,snormal:%,$(RUN_BASE)) \
+		      $(patsubst %,scluster:%,$(RUN_BASE)) \
+		      $(patsubst %,slvmetad:%,$(RUN_BASE))
+
 check_cluster: .tests-stamp
 	@echo Testing with locking_type 3
 	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)


