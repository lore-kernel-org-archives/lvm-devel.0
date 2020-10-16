From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:18 +0000 (GMT)
Subject: stable-2.02 - tests: aux hides zero and error device
Message-ID: <20201016191218.6003A396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d8d8856f12cab71663325eefe59c06f10cb884d
Commit:        4d8d8856f12cab71663325eefe59c06f10cb884d
Parent:        bd860802d4cfabaef1da46140895826a80932d6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:19:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: aux hides zero and error device

When ERR_DEV and ZERO_DEV are used, they are automatically
taken down when the last user no longer needs them,
so hide them from 'forgotten' device check.
---
 test/lib/aux.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1a66df16e..667ca14ac 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -564,14 +564,14 @@ teardown() {
 	echo -n "## teardown..."
 	unset LVM_LOG_FILE_EPOCH
 
-	test ! -f ERR_DEV || should dmsetup remove $(cat ERR_DEV_NAME)
-	test ! -f ZERO_DEV || should dmsetup remove $(cat ZERO_DEV_NAME)
-
 	if test -f TESTNAME ; then
 
 	if test ! -f SKIP_THIS_TEST ; then
 		# Evaluate left devices only for non-skipped tests
-		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -Ev "${PREFIX}(pv|[0-9])") || true
+		TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | \
+			grep -Ev "${PREFIX}(pv|[0-9])" | \
+			grep -v "$(cat ERR_DEV_NAME 2>/dev/null)" | \
+			grep -v "$(cat ZERO_DEV_NAME 2>/dev/null)") || true
 	fi
 
 	kill_tagged_processes


