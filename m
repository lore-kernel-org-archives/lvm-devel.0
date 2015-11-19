From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 11:21:23 +0000 (UTC)
Subject: master - tests: stacktrace on skip if message is empty
Message-ID: <20151119112123.E6014601BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f002c29a56d4e80ff7ebc9b8a5334c2599e663a
Commit:        6f002c29a56d4e80ff7ebc9b8a5334c2599e663a
Parent:        2a23550cf3f3ecf6f3daec211e2304444170daf3
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 19 12:11:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 12:18:33 2015 +0100

tests: stacktrace on skip if message is empty

---
 test/lib/utils.sh |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 24c9076..6745c1b 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -107,7 +107,7 @@ grep1_() {
 	awk -v pattern="${1}" 'NR==1 || $0~pattern' "${@:2}"
 }
 
-STACKTRACE() {
+stacktrace() {
 	trap - ERR
 	local i=0
 
@@ -116,6 +116,13 @@ STACKTRACE() {
 		echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
 		i=$(($i + 1))
 	done
+}
+
+STACKTRACE() {
+	trap - ERR
+	local i=0
+
+	stacktrace
 
 	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
 		pgrep dmeventd &>/dev/null && \
@@ -211,7 +218,11 @@ dm_table() {
 }
 
 skip() {
-	test "$#" -eq 0 || echo "TEST SKIPPED: $@"
+	if test "$#" -eq 0; then
+		stacktrace
+	else
+		echo "TEST SKIPPED: $@"
+	fi
 	touch SKIP_THIS_TEST
 	exit 200
 }


