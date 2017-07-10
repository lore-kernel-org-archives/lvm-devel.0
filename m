From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:47 -0400
Subject: master - tests: use well defined test
Message-ID: <201707101228.v6ACSlvo022112@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c9789b0ccabf95aae84d48d41322d8609ad8d51
Commit:        1c9789b0ccabf95aae84d48d41322d8609ad8d51
Parent:        9c0a92ee8dc4eca67f53b72f190e7c038ae984d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:31:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: use well defined test

Prefer [ p ] && [ q ] as [ p -a q ] is not well defined.

Apparently && and || "short-circuit" while -a and -o do not.
---
 test/lib/aux.sh             |    6 +++---
 test/lib/utils.sh           |    4 ++--
 test/shell/lvchange-raid.sh |    2 +-
 test/shell/name-mangling.sh |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index aa5f0a0..fda826f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1442,13 +1442,13 @@ have_thin() {
 
 	declare -a CONF
 	# disable thin_check if not present in system
-	if test -n "$LVM_TEST_THIN_CHECK_CMD" -a ! -x "$LVM_TEST_THIN_CHECK_CMD" ; then
+	if test -n "$LVM_TEST_THIN_CHECK_CMD" && test ! -x "$LVM_TEST_THIN_CHECK_CMD"; then
 		CONF[0]="global/thin_check_executable = \"\""
 	fi
-	if test -n "$LVM_TEST_THIN_DUMP_CMD" -a ! -x "$LVM_TEST_THIN_DUMP_CMD" ; then
+	if test -n "$LVM_TEST_THIN_DUMP_CMD" && test ! -x "$LVM_TEST_THIN_DUMP_CMD"; then
 		CONF[1]="global/thin_dump_executable = \"\""
 	fi
-	if test -n "$LVM_TEST_THIN_REPAIR_CMD" -a ! -x "$LVM_TEST_THIN_REPAIR_CMD" ; then
+	if test -n "$LVM_TEST_THIN_REPAIR_CMD" && test ! -x "$LVM_TEST_THIN_REPAIR_CMD"; then
 		CONF[2]="global/thin_repair_executable = \"\""
 	fi
 	if test ${#CONF[@]} -ne 0 ; then
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 4e43e64..8545703 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -147,7 +147,7 @@ STACKTRACE() {
 
 	test -f SKIP_THIS_TEST && exit 200
 
-	test -z "$LVM_TEST_NODEBUG" -a -f TESTNAME && {
+	test -z "$LVM_TEST_NODEBUG" && test -f TESTNAME && {
 		local name
 		local idx
 		for i in debug.log* ; do
@@ -200,7 +200,7 @@ init_udev_transaction() {
 }
 
 finish_udev_transaction() {
-	if test "$DM_UDEV_SYNCHRONISATION" = 1 -a -n "$DM_UDEV_COOKIE"; then
+	if test "$DM_UDEV_SYNCHRONISATION" = 1 && test -n "$DM_UDEV_COOKIE" ; then
 		dmsetup udevreleasecookie
 		unset DM_UDEV_COOKIE
 	fi
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index ce29768..8c22481 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -332,7 +332,7 @@ TEST_TYPES="- snapshot"
 # thinpool works EX in cluster
 # but they don't work together in a cluster yet
 #  (nor does thinpool+mirror work in a cluster yet)
-test ! -e LOCAL_CLVMD -a aux have_thin 1 8 0 && TEST_TYPE="$TEST_TYPES thinpool_data thinpool_meta"
+test ! -e LOCAL_CLVMD && aux have_thin 1 8 0 && TEST_TYPE="$TEST_TYPES thinpool_data thinpool_meta"
 
 # Implicit test for 'raid1' only
 if test "${TEST_RAID:-raid1}" = raid1 ; then
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 3b699a2..66c0aeb 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -173,7 +173,7 @@ function check_mangle_cmd()
 		fi
 	fi
 
-	if [ $r = 0 -a $rename_expected = 1 ]; then
+	if [ "$r" = 0 ] && [ "$rename_expected" = 1 ]; then
 		# successfuly renamed to expected name
 		remove_dm_dev none "$expected"
 	elif [ $r = 1 ]; then


