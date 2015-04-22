From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:37 +0000 (UTC)
Subject: master - tests: simplify teardown
Message-ID: <20150422092037.16ADB60E46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a64a157e13154a9b6a37a12a8d50a8e63f51478
Commit:        7a64a157e13154a9b6a37a12a8d50a8e63f51478
Parent:        7f8d942268161abcb56700c027f82a87f20f0abf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 11:03:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 11:18:31 2015 +0200

tests: simplify teardown

If TESTNAME has not been created yet, avoid running complex teardown.
---
 test/lib/aux.sh   |    4 ++++
 test/lib/utils.sh |    2 +-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 737050d..15a689a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -254,6 +254,8 @@ kill_listed_processes() {
 teardown() {
 	echo -n "## teardown..."
 
+	if test -f TESTNAME ; then
+
 	kill_listed_processes
 
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
@@ -277,6 +279,8 @@ teardown() {
 
 	echo -n .
 
+	fi
+
 	test -n "$TESTDIR" && {
 		cd "$TESTOLDPWD"
 		rm -rf "$TESTDIR" || echo BLA
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 87152a4..a610632 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -134,7 +134,7 @@ STACKTRACE() {
 
 	test -f SKIP_THIS_TEST && exit 200
 
-	test -z "$LVM_TEST_NODEBUG" && {
+	test -z "$LVM_TEST_NODEBUG" -a -f TESTNAME && {
 		local name
 		local idx
 		for i in debug.log* ; do


