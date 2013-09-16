From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 09:23:12 +0000 (UTC)
Subject: master - tests: update die
Message-ID: <20130916092312.11F1B60E77@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51d3667cb559e77cd43556851922cb5bef0fc9ae
Commit:        51d3667cb559e77cd43556851922cb5bef0fc9ae
Parent:        d6090a10f01e6daf5c66e7098a3b0f85560a80ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 11:05:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 11:22:04 2013 +0200

tests: update die

'die' evaluates given string - so \n could be used for
multiline error report

Also remove debug.log since the command finished properly when we
call 'die'

Note: we should not call 'die' after lvm command failure.
---
 test/lib/check.sh |    3 ++-
 test/lib/utils.sh |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 6eedb47..ecb0721 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -25,7 +25,8 @@
 test -z "$BASH" || set -e -o pipefail
 
 die() {
-	echo "$@" >&2
+	rm -f debug.log
+	echo -e "$@" >&2
 	return 1
 }
 
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 47e89bf..0f58b25 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -15,7 +15,8 @@ IFS_NL='
 '
 
 die() {
-	echo "$@" >&2
+	rm -f debug.log
+	echo -e "$@" >&2
 	return 1
 }
 


