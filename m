From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 14 Jul 2017 19:51:59 +0200
Subject: [PATCH] test: Fix stacktrace
Message-ID: <1500054719-5394-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
 test/lib/utils.sh | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

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
-- 
1.8.3.1


