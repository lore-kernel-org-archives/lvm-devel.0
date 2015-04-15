From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:19 +0000 (UTC)
Subject: master - tests: fix aux have test
Message-ID: <20150415113819.B01F060DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=930f0aae845e65f3673d14df97e141baccf37849
Commit:        930f0aae845e65f3673d14df97e141baccf37849
Parent:        1a7dd13e70e32bc519b27b509b67b0de8f86e631
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 11:51:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: fix aux have test

Previous commit has made have_cache & have_thin producing
false return value.

Fix it and at the some time provide much better reconfiguring
warning message.

If the test machine is missing needed and configured binaries
it will produce TEST WARNING result.
---
 test/lib/aux.sh |   48 ++++++++++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bc70cc0..505d15e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -893,17 +893,21 @@ have_thin() {
 	test "$THIN" = shared -o "$THIN" = internal || return 1
 	target_at_least dm-thin-pool "$@" || return 1
 
+	declare -a CONF
 	# disable thin_check if not present in system
-	test -x "$LVM_TEST_THIN_CHECK_CMD" || LVM_TEST_THIN_CHECK_CMD=""
-	test -x "$LVM_TEST_THIN_DUMP_CMD" || LVM_TEST_THIN_DUMP_CMD=""
-	test -x "$LVM_TEST_THIN_REPAIR_CMD" || LVM_TEST_THIN_REPAIR_CMD=""
-	test -z "$LVM_TEST_THIN_CHECK_CMD" -o \
-	     -z "$LVM_TEST_THIN_DUMP_CMD" -o \
-	     -z "$LVM_TEST_THIN_REPAIR_CMD" && {
-	lvmconf "global/thin_check_executable = \"$LVM_TEST_THIN_CHECK_CMD\"" \
-		"global/thin_dump_executable = \"$LVM_TEST_THIN_DUMP_CMD\"" \
-		"global/thin_repair_executable = \"$LVM_TEST_THIN_REPAIR_CMD\""
-	}
+	if test -n "$LVM_TEST_THIN_CHECK_CMD" -a ! -x "$LVM_TEST_THIN_CHECK_CMD" ; then
+		CONF[0]="global/thin_check_executable = \"\""
+	fi
+	if test -n "$LVM_TEST_THIN_DUMP_CMD" -a ! -x "$LVM_TEST_THIN_DUMP_CMD" ; then
+		CONF[1]="global/thin_dump_executable = \"\""
+	fi
+	if test -n "$LVM_TEST_THIN_REPAIR_CMD" -a ! -x "$LVM_TEST_THIN_REPAIR_CMD" ; then
+		CONF[2]="global/thin_repair_executable = \"\""
+	fi
+	if test ${#CONF[@]} -ne 0 ; then
+		echo "TEST WARNING: Reconfiguring ${CONF[@]}"
+		lvmconf "${CONF[@]}"
+	fi
 }
 
 have_raid() {
@@ -915,17 +919,21 @@ have_cache() {
 	test "$CACHE" = shared -o "$CACHE" = internal || return 1
 	target_at_least dm-cache "$@"
 
+	declare -a CONF
 	# disable cache_check if not present in system
-	test -x "$LVM_TEST_CACHE_CHECK_CMD" || LVM_TEST_CACHE_CHECK_CMD=""
-	test -x "$LVM_TEST_CACHE_DUMP_CMD" || LVM_TEST_CACHE_DUMP_CMD=""
-	test -x "$LVM_TEST_CACHE_REPAIR_CMD" || LVM_TEST_CACHE_REPAIR_CMD=""
-	test -z "$LVM_TEST_CACHE_CHECK_CMD" -o \
-	     -z "$LVM_TEST_CACHE_DUMP_CMD" -o \
-	     -z "$LVM_TEST_CACHE_REPAIR_CMD" && {
-	lvmconf "global/cache_check_executable = \"$LVM_TEST_CACHE_CHECK_CMD\"" \
-		"global/cache_dump_executable = \"$LVM_TEST_CACHE_DUMP_CMD\"" \
-		"global/cache_repair_executable = \"$LVM_TEST_CACHE_REPAIR_CMD\""
-	}
+	if test -n "$LVM_TEST_CACHE_CHECK_CMD" -a ! -x "$LVM_TEST_CACHE_CHECK_CMD" ; then
+		CONF[0]="global/cache_check_executable = \"\""
+	fi
+	if test -n "$LVM_TEST_CACHE_DUMP_CMD" -a ! -x "$LVM_TEST_CACHE_DUMP_CMD" ; then
+		CONF[1]="global/cache_dump_executable = \"\""
+	fi
+	if test -n "$LVM_TEST_CACHE_REPAIR_CMD" -a ! -x "$LVM_TEST_CACHE_REPAIR_CMD" ; then
+		CONF[2]="global/cache_repair_executable = \"\""
+	fi
+	if test ${#CONF[@]} -ne 0 ; then
+		echo "TEST WARNING: Reconfiguring ${CONF[@]}"
+		lvmconf "${CONF[@]}"
+	fi
 }
 
 have_tool_at_least() {


