From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 15 Dec 2013 16:27:37 +0000 (UTC)
Subject: master - test: Turn check_full into check_system complementary with normal check.
Message-ID: <20131215162737.1D755603A0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56af6cae087259f620a356a6706ea10249015069
Commit:        56af6cae087259f620a356a6706ea10249015069
Parent:        18afca5ddded15c528a88a11fe1ea29c8a29cbcd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 17:26:28 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Dec 15 17:26:28 2013 +0100

test: Turn check_full into check_system complementary with normal check.

---
 Makefile.in      |    2 +-
 test/Makefile.in |    9 ++-------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index e1178ee..ce61957 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -91,7 +91,7 @@ all: cscope.out
 endif
 DISTCLEAN_TARGETS += cscope.out
 
-check check_full check_cluster check_local check_lvmetad unit: all
+check check_system check_cluster check_local check_lvmetad unit: all
 	$(MAKE) -C test $(@)
 
 install_system_dirs:
diff --git a/test/Makefile.in b/test/Makefile.in
index 96c4fdb..5c9f5d5 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -90,19 +90,14 @@ check: .tests-stamp
 		      $(patsubst %,cluster:%,$(RUN_BASE)) \
 		      $(patsubst %,lvmetad:%,$(LVMETAD_RUN_BASE))
 
-check_full: .tests-stamp
+check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) \
-	cluster_LVM_TEST_LOCKING=3 \
 	scluster_LVM_TEST_LOCKING=3 \
-	lvmetad_LVM_TEST_LVMETAD=1 \
 	slvmetad_LVM_TEST_LVMETAD=1 \
 	snormal_LVM_TEST_DEVDIR=/dev \
 	scluster_LVM_TEST_DEVDIR=/dev \
 	slvmetad_LVM_TEST_DEVDIR=/dev \
-	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
-		      $(patsubst %,cluster:%,$(RUN_BASE)) \
-		      $(patsubst %,lvmetad:%,$(LVMETAD_RUN_BASE)) \
-		      $(patsubst %,snormal:%,$(RUN_BASE)) \
+	./lib/harness $(patsubst %,snormal:%,$(RUN_BASE)) \
 		      $(patsubst %,scluster:%,$(RUN_BASE)) \
 		      $(patsubst %,slvmetad:%,$(LVMETAD_RUN_BASE))
 


