From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:34 +0000 (UTC)
Subject: master - tests: fix typo VEROSE->VERBOSE in Makefile.in
Message-ID: <20130923101634.3174260FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec66ff818cd670228bd299fa51f8867fe7e50a3e
Commit:        ec66ff818cd670228bd299fa51f8867fe7e50a3e
Parent:        ced563e3a729f3440cf69c4ed1f290d474fbd791
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 14:03:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:14:21 2013 +0200

tests: fix typo VEROSE->VERBOSE in Makefile.in

---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index b663e7a..1b9789f 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -70,7 +70,7 @@ help:
 	@echo "  VERBOSE		Verbose output (1), timing (2)."
 
 check: .tests-stamp
-	VERBOSE=$(VEROSE) \
+	VERBOSE=$(VERBOSE) \
 	cluster_LVM_TEST_LOCKING=3 \
 	lvmetad_LVM_TEST_LVMETAD=1 \
 	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
@@ -78,7 +78,7 @@ check: .tests-stamp
 		      $(patsubst %,lvmetad:%,$(RUN_BASE))
 
 check_full: .tests-stamp
-	VERBOSE=$(VEROSE) \
+	VERBOSE=$(VERBOSE) \
 	cluster_LVM_TEST_LOCKING=3 \
 	scluster_LVM_TEST_LOCKING=3 \
 	lvmetad_LVM_TEST_LVMETAD=1 \


