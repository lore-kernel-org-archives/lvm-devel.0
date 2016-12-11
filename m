From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:10 +0000 (UTC)
Subject: master - tests: track leaked devices in tests
Message-ID: <20161211223510.9FD6A60C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56e4e2ce2ba05990eb4e8ced8a9a966b986f14ab
Commit:        56e4e2ce2ba05990eb4e8ced8a9a966b986f14ab
Parent:        273ccb11704075b1876f6931e9e8de19ff2b31a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 10:25:15 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

tests: track leaked devices in tests

When test calls teardown, no devices created by test are expected
to be left in table. Trap such orphans and make the test fail.
---
 test/lib/aux.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7f3c84a..4749f81 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -520,6 +520,8 @@ teardown() {
 
 	if test -f TESTNAME ; then
 
+	TEST_LEAKED_DEVICES=$(dmsetup table | grep "$PREFIX" | grep -v "${PREFIX}pv") || true
+
 	kill_tagged_processes
 
 	if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
@@ -567,6 +569,12 @@ teardown() {
 
 	fi
 
+	test -z "$TEST_LEAKED_DEVICES" || {
+		echo "Unexpected devices left dm table:"
+		echo "$TEST_LEAKED_DEVICES"
+		return 1
+	}
+
 	test -n "$TESTDIR" && {
 		cd "$TESTOLDPWD"
 		rm -rf "$TESTDIR" || echo BLA


