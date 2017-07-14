From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Jul 2017 14:31:04 -0400
Subject: master - tests: utils.sh six stacktrace
Message-ID: <201707141831.v6EIV4su007904@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c95cf8c6f2d024642920c12d91c5de9e31ff7de
Commit:        1c95cf8c6f2d024642920c12d91c5de9e31ff7de
Parent:        34504855a70772e1de3f117a9a610860ead80981
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jul 14 19:51:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 20:18:42 2017 +0200

tests: utils.sh six stacktrace

Changes:

- BASH_SOURCE index was one off.
- The first line of stacktrace was pure confusion displaying executed
  script together with innermost line number (which was either 125 when
  STACKTRACE or 229 when skip was called.)
- We can safely ignore innermost call, as stack trace is always produced
  by stacktrace function.
- It is safer to test for array length, instead of testing FUNCNAME is
  main - if main function were introduced.
- Bashishm is safe to use as this function as a whole is relying on bash.
---
 test/lib/utils.sh |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 4d46ca9..61ccf9b 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -109,11 +109,14 @@ grep1_() {
 
 stacktrace() {
 	trap - ERR
-	local i=0
-
-	echo "## - $0:${BASH_LINENO[0]}"
-	while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do
-		echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
+	# i=1 - ignoring innermost frame - it is always stacktrace function
+	local i=1 n=${#BASH_LINENO[*]}
+	# n-=1 - ignoring last frame as well - it is not interesting
+	let n-=1
+
+	echo "## - $0:${BASH_LINENO[$((n-1))]}"
+	while [[ $i -lt $n ]]; do
+		echo "## $i ${FUNCNAME[$i]}() called from ${BASH_SOURCE[$((i+1))]}:${BASH_LINENO[$i]}"
 		i=$(( i + 1 ))
 	done
 }


