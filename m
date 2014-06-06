From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:08 +0000 (UTC)
Subject: dev-prajnoha-report-select - tests: use manglename none for dmsetup
Message-ID: <20140606120308.43DA3612AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77d4e317a44213baff566f6b13b4a7d930f446b4
Commit:        77d4e317a44213baff566f6b13b4a7d930f446b4
Parent:        9196942312cadea3cd4bf850442d556b07ad88d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 12:09:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:34 2014 +0200

tests: use manglename none for dmsetup

---
 test/lib/aux.sh   |    4 ++--
 test/lib/test.sh  |    3 ++-
 test/lib/utils.sh |    2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b093e3c..445bf26 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -151,7 +151,7 @@ teardown_devs_prefixed() {
 	local need_udev_wait=0
 	init_udev_transaction
 	for dm in $(dm_info name --sort open | grep "$prefix"); do
-		dmsetup remove --mangle none "$dm" &>/dev/null || remfail=yes
+		dmsetup remove "$dm" &>/dev/null || remfail=yes
 		need_udev_wait=1
 	done
 	finish_udev_transaction
@@ -164,7 +164,7 @@ teardown_devs_prefixed() {
 		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
 			for dm in $(dm_info name --sort open | grep "$prefix") ; do
-				dmsetup remove --mangle none -f "$dm" || true
+				dmsetup remove -f "$dm" || true
 			done
 			num_remaining_devs=$num_devs
 		done
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 3bde1e3..731cd7a 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -48,6 +48,7 @@ if test -n "$LVM_TEST_FLAVOUR"; then
 	. flavour_overrides
 fi
 
+DM_DEFAULT_NAME_MANGLING_MODE=none
 DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
 mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
@@ -63,7 +64,7 @@ fi
 # abort on the internal dm errors in the tests (allowing test user override)
 DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
 
-export DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
+export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 
 echo "$TESTNAME" >TESTNAME
 
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index f28b37b..b4cfdeb 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -159,7 +159,7 @@ teardown_udev_cookies() {
 }
 
 dm_info() {
-	should dmsetup info --mangle none --noheadings -c -o "$@"
+	should dmsetup info --noheadings -c -o "$@"
 }
 
 dm_table() {


