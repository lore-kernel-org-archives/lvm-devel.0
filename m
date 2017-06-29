From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:18 -0400
Subject: master - tests: utils.sh arithmetic
Message-ID: <201706292029.v5TKTInu026940@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4697937af46f2c95b29c627ef60ec37ba1addcf8
Commit:        4697937af46f2c95b29c627ef60ec37ba1addcf8
Parent:        00957450ebc08f82382eccef78ce405eeb4461fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:19:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: utils.sh arithmetic

expr is antiquated. Consider rewriting this using $((..)), ${} or [[ ]].
$ is unnecessary on arithmetic variables.
---
 test/lib/utils.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index fa072ba..6a46649 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -97,7 +97,7 @@ mkdtemp() {
 		err=$(mkdir -m 0700 "$candidate_dir" 2>&1) && \
 			{ echo "$candidate_dir"; return; }
 		test $MAX_TRIES -le $i && break;
-		i=$(expr $i + 1)
+		i=$(( i + 1 ))
 	done
 	die "$err"
 }
@@ -114,7 +114,7 @@ stacktrace() {
 	echo "## - $0:${BASH_LINENO[0]}"
 	while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do
 		echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
-		i=$(($i + 1))
+		i=$(( i + 1 ))
 	done
 }
 
@@ -150,7 +150,7 @@ STACKTRACE() {
 			test -f "$i" || break  # nothing is found (expands to debug.log*)
 			name=${i##debug.log_}
 			name=${name%%_*}
-			test "$name" = "DEBUG" && { name="$name$idx" ; idx=$(($idx + 1)) ; }
+			test "$name" = "DEBUG" && { name="$name$idx" ; idx=$(( idx + 1 )) ; }
 			echo "<======== Debug log $i ========>"
 			sed -e "s,^,## $name: ," "$i"
 		done


