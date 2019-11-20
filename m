From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Nov 2019 09:34:04 -0500
Subject: master - test: Fix handling leftovers from previous tests
Message-ID: <07980.119112009335900673@us-mta-225.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e669ab315c32aba3f47c37771f26ab7c8e151dd
Commit:        1e669ab315c32aba3f47c37771f26ab7c8e151dd
Parent:        7474440d3b540d20eb4f997efeb31b881cc6ac8e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Nov 20 15:23:48 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 20 15:27:03 2019 +0100

test: Fix handling leftovers from previous tests

teardown fails current PREFIX is prefix of previously failed test with
leftovers in dmtable.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6822d7e..566e9b5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -520,7 +520,7 @@ teardown() {
 
 	if test ! -f SKIP_THIS_TEST ; then
 		# Evaluate left devices only for non-skipped tests
-		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -v "${PREFIX}pv") || true
+		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -Ev "${PREFIX}(pv|[0-9])") || true
 	fi
 
 	kill_tagged_processes



