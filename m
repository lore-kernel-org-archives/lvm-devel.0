From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Nov 2019 09:33:03 -0500
Subject: stable-2.02 - test: Fix handling leftovers from previous tests
Message-ID: <86211.119112009330000855@us-mta-310.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61c321d110630d4fc2ed8f75cb3a9ba78e29599b
Commit:        61c321d110630d4fc2ed8f75cb3a9ba78e29599b
Parent:        26f94d91195531730c22eac26c741f1b4d2e0f1e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Nov 20 15:23:48 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 20 15:31:21 2019 +0100

test: Fix handling leftovers from previous tests

teardown fails current PREFIX is prefix of previously failed test with
leftovers in dmtable.

(cherry picked from commit 1e669ab315c32aba3f47c37771f26ab7c8e151dd)
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2241062..ec0699f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -568,7 +568,7 @@ teardown() {
 
 	if test ! -f SKIP_THIS_TEST ; then
 		# Evaluate left devices only for non-skipped tests
-		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -v "${PREFIX}pv") || true
+		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -Ev "${PREFIX}(pv|[0-9])") || true
 	fi
 
 	kill_tagged_processes



