From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:26:07 -0400
Subject: master - tests: shellcheck misc
Message-ID: <201803231626.w2NGQ7uV032008@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a48fb47b771c3f4db4222f0fdaf5eb462803ac5
Commit:        3a48fb47b771c3f4db4222f0fdaf5eb462803ac5
Parent:        1507956383b9b28e52051ecf56d754e8cda6e025
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 17:01:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: shellcheck misc

Few more minor complains from ShellCheck.
---
 test/lib/check.sh |    4 ++--
 test/lib/utils.sh |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 3c7b81a..ed4f8d7 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -240,10 +240,10 @@ in_sync() {
 	fi
 
 	if [[ ${a[$(( idx - 1 ))]} =~ a ]] ; then
-		[ $ignore_a -eq 0 ] && \
+		[ "$ignore_a" = 0 ] && \
 			die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
 		echo "$lvm_name ($type$snap) is not in-sync"
-		[ $ignore_a -eq 1 ] && return 0
+		[ "$ignore_a" = 1 ] && return 0
 		return 1
 	fi
 
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index f2a4bde..36fbf06 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -39,7 +39,7 @@ rand_bytes() {
 
 	# Ensure that $data has length at least 50+$n
 	while :; do
-		len=$(echo "$data" | wc -c)
+		len=${#data} # number of chars in $data
 		test "$n_plus_50" -le "$len" && break;
 		data=$( (echo "$data"; eval "$cmds") 2>&1 | gzip )
 	done
@@ -112,7 +112,7 @@ stacktrace() {
 	# i=1 - ignoring innermost frame - it is always stacktrace function
 	local i=1 n=${#BASH_LINENO[*]}
 	# n-=1 - ignoring last frame as well - it is not interesting
-	let n-=1
+	n=$(( n - 1 ))
 
 	echo "## - $0:${BASH_LINENO[$((n-1))]}"
 	while [[ $i -lt $n ]]; do


