From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 08:12:06 +0000 (UTC)
Subject: master - tests: integrate default thin/cache tool paths
Message-ID: <20150414081206.6687F60E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a084b3122f5df4d9dcd244762132abcb5f46ea6a
Commit:        a084b3122f5df4d9dcd244762132abcb5f46ea6a
Parent:        c6bcfcba8541d053f142496c30f437a694daf5ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 10:08:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 10:11:36 2015 +0200

tests: integrate default thin/cache tool paths

If the system is correctly configure (cache & thin tools are present)
avoid 'extra' rebuild of configuration.

On the other hand - if some tool is missing - duplicate ##LVMCONF should
make it more straighforward to see.
---
 test/lib/aux.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bccc30c..8e729a7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -690,6 +690,12 @@ global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
 global/si_unit_consistency = 1
 global/fallback_to_local_locking = 0
+global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
+global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
+global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
+global/thin_check_executable = "$LVM_TEST_THIN_CHECK_CMD"
+global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"
+global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
 activation/checks = 1
 activation/udev_sync = 1
 activation/udev_rules = 1
@@ -887,9 +893,13 @@ have_thin() {
 	test -x "$LVM_TEST_THIN_CHECK_CMD" || LVM_TEST_THIN_CHECK_CMD=""
 	test -x "$LVM_TEST_THIN_DUMP_CMD" || LVM_TEST_THIN_DUMP_CMD=""
 	test -x "$LVM_TEST_THIN_REPAIR_CMD" || LVM_TEST_THIN_REPAIR_CMD=""
+	test -z "$LVM_TEST_THIN_CHECK_CMD" -o \
+	     -z "$LVM_TEST_THIN_DUMP_CMD" -o \
+	     -z "$LVM_TEST_THIN_REPAIR_CMD" && {
 	lvmconf "global/thin_check_executable = \"$LVM_TEST_THIN_CHECK_CMD\"" \
 		"global/thin_dump_executable = \"$LVM_TEST_THIN_DUMP_CMD\"" \
 		"global/thin_repair_executable = \"$LVM_TEST_THIN_REPAIR_CMD\""
+	}
 }
 
 have_raid() {
@@ -901,12 +911,17 @@ have_cache() {
 	test "$CACHE" = shared -o "$CACHE" = internal || return 1
 	target_at_least dm-cache "$@"
 
+	# disable cache_check if not present in system
 	test -x "$LVM_TEST_CACHE_CHECK_CMD" || LVM_TEST_CACHE_CHECK_CMD=""
 	test -x "$LVM_TEST_CACHE_DUMP_CMD" || LVM_TEST_CACHE_DUMP_CMD=""
 	test -x "$LVM_TEST_CACHE_REPAIR_CMD" || LVM_TEST_CACHE_REPAIR_CMD=""
+	test -z "$LVM_TEST_CACHE_CHECK_CMD" -o \
+	     -z "$LVM_TEST_CACHE_DUMP_CMD" -o \
+	     -z "$LVM_TEST_CACHE_REPAIR_CMD" && {
 	lvmconf "global/cache_check_executable = \"$LVM_TEST_CACHE_CHECK_CMD\"" \
 		"global/cache_dump_executable = \"$LVM_TEST_CACHE_DUMP_CMD\"" \
 		"global/cache_repair_executable = \"$LVM_TEST_CACHE_REPAIR_CMD\""
+	}
 }
 
 have_tool_at_least() {


