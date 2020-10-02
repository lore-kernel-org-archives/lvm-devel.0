From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:04 +0000 (GMT)
Subject: master - tests: aux hides zero and error device
Message-ID: <20201002202804.C1FA3398E4B4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e26a2b74d14bebeeba20ec5b082fac752cc7236
Commit:        5e26a2b74d14bebeeba20ec5b082fac752cc7236
Parent:        8d9b4c624f5738035ef9a7af19cb85b6960ca080
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:19:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 22:27:00 2020 +0200

tests: aux hides zero and error device

When ERR_DEV and ZERO_DEV are used, they are automatically
taken down when the last user no longer needs them,
so hide them from 'forgotten' device check.
---
 test/lib/aux.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 02989c5cb..5dbb580be 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -516,14 +516,14 @@ teardown() {
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


