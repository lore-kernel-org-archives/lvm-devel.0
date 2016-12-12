From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Dec 2016 10:24:23 +0000 (UTC)
Subject: master - tests: no left devices check for skipped test
Message-ID: <20161212102423.362AA60C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c9c6ab66060cfc3383297a6baed229f9f341d4a
Commit:        8c9c6ab66060cfc3383297a6baed229f9f341d4a
Parent:        48d33e5fb671af16f84d74afab9f86d47ca112fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 12 11:22:10 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 12 11:22:10 2016 +0100

tests: no left devices check for skipped test

---
 test/lib/aux.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4749f81..a195883 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -520,7 +520,10 @@ teardown() {
 
 	if test -f TESTNAME ; then
 
-	TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -v "${PREFIX}pv") || true
+	if test ! -f SKIP_THIS_TEST ; then
+		# Evaluate left devices only for non-skipped tests
+		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -v "${PREFIX}pv") || true
+	fi
 
 	kill_tagged_processes
 


