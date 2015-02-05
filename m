From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:43 +0000 (UTC)
Subject: master - test: Use the new runner in make check.
Message-ID: <20150205134043.84900602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b726d6688260e1e1e98500809eee014b7ceb92b5
Commit:        b726d6688260e1e1e98500809eee014b7ceb92b5
Parent:        1ec2023cbfe40d285a9da55f029fcf173c763b88
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 25 21:35:11 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

test: Use the new runner in make check.

---
 test/Makefile.in |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index e2f2cb8..c88d07a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -101,12 +101,7 @@ help:
 	@echo "  VERBOSE		Verbose output (1), timing (2)."
 
 check: .tests-stamp
-	VERBOSE=$(VERBOSE) \
-	cluster_LVM_TEST_LOCKING=3 \
-	lvmetad_LVM_TEST_LVMETAD=1 \
-	./lib/harness $(patsubst %,normal:%,$(RUN_BASE)) \
-		      $(patsubst %,cluster:%,$(RUN_BASE)) \
-		      $(patsubst %,lvmetad:%,$(LVMETAD_RUN_BASE))
+	VERBOSE=$(VERBOSE) ./lib/runner --testdir shell --outdir results
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) \


