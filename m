From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:05:04 -0400
Subject: master - tests: skip test when not enough space
Message-ID: <201803151005.w2FA54oI023769@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6f8f0c7fda823b1d7261472a6d724118ed19007
Commit:        f6f8f0c7fda823b1d7261472a6d724118ed19007
Parent:        bed869a8a0e66bc4a760b6f56b0d199fc226a179
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 11:21:56 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 11:01:04 2018 +0100

tests: skip test when not enough space

Make the test skipped instead of failing when there was not
enough space.
---
 test/lib/inittest.sh |    2 +-
 test/lib/utils.sh    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 8e4e064..20bc345 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -127,7 +127,7 @@ echo "$TESTNAME" >TESTNAME
 
 # Require 50M of free space in testdir
 test $(df -k -P . | awk '/\// {print $4}') -gt 51200  ||
-	die "Testing requires more then 50M of free space in directory $TESTDIR!\n$(df -H)"
+	skip "Testing requires more then 50M of free space in directory $TESTDIR!\n$(df -H | sed -e 's,^,## DF:   ,')"
 
 echo "Kernel is $(uname -a)"
 # Report SELinux mode
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index b6c2ab0..f2a4bde 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -241,7 +241,7 @@ skip() {
 	if test "$#" -eq 0; then
 		stacktrace
 	else
-		echo "TEST SKIPPED:" "$@"
+		echo -e "TEST SKIPPED:" "$@"
 	fi
 	touch SKIP_THIS_TEST
 	exit 200


