From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 13:46:58 +0000 (UTC)
Subject: master - tests: fix name-mangling test and remove udev transaction in dmsetup wrapper
Message-ID: <20140306134658.6D66960FDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfc9e178bf24982f14c4d1e9034056ff6c3d3e31
Commit:        cfc9e178bf24982f14c4d1e9034056ff6c3d3e31
Parent:        42eb9b45262f3cb9d9baf0903249128bb6923d4e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 6 14:46:50 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 14:46:50 2014 +0100

tests: fix name-mangling test and remove udev transaction in dmsetup wrapper

---
 test/lib/aux.sh             |    2 --
 test/shell/name-mangling.sh |   15 ++++++---------
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c178ab5..5d2d188 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -763,9 +763,7 @@ have_readline()
 dmsetup_wrapped()
 {
 	udev_wait
-	init_udev_transaction
 	dmsetup "$@"
-	finish_udev_transaction
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index b5906c1..2f07523 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -15,7 +15,7 @@ CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
 FAIL_MULTI_STR="seems to be mangled more than once"
 FAIL_BLACK_STR="should be mangled but it contains blacklisted characters"
-CORRECT_FORM_STR="name already in correct form"
+CORRECT_FORM_STR="already in correct form"
 RENAMING_STR="renaming to"
 
 function create_dm_dev()
@@ -66,13 +66,13 @@ function check_create_and_remove()
 	test -b "$DM_DEV_DIR/mapper/${PREFIX}$dm_name" && \
 	aux dmsetup remove "${PREFIX}$input_name" $verify_udev --manglename $mode || r=1
 
-	if [ $dm_name = "FAIL_MIXED" ]; then
+	if [ "$dm_name" = "FAIL_MIXED" ]; then
 		r=0
 		grep "$FAILED_MIXED_STR" err || r=1
-	elif [ $dm_name = "FAIL_MULTI" ]; then
+	elif [ "$dm_name" = "FAIL_MULTI" ]; then
 		r=0
 		grep "$FAILED_MULTI_STR" err || r=1
-	elif [ $dm_name = "FAIL_BLACK" ]; then
+	elif [ "$dm_name" = "FAIL_BLACK" ]; then
 		r=0
 		grep "$FAILED_BLACK_STR" err || r=1
 	fi
@@ -164,6 +164,7 @@ r=0
 create_dm_dev auto "abc"
 ln -s "$DM_DEV_DIR/mapper/${PREFIX}abc" "$DM_DEV_DIR/${PREFIX}xyz"
 aux dmsetup status "$DM_DEV_DIR/${PREFIX}xyz" || r=1
+rm -f "$DM_DEV_DIR/${PREFIX}xyz"
 remove_dm_dev auto "abc"
 if [ r = 1 ]; then
 	exit 1
@@ -191,11 +192,7 @@ check_expected_names none 'a\x5cx20b' 'a\x5cx20b' 'a\x5cx20b' 'a\x20b'
 
 check_mangle_cmd none 'a b' 'OK'
 check_mangle_cmd none 'a\x20b' 'a b'
-#
-# FIXME: this test leave entry in /dev/mapper dir
-#        and is not detected nor cleaned
-#
-#check_mangle_cmd none 'a b\x20c' 'a b c'
+check_mangle_cmd none 'a b\x20c' 'a b c'
 check_mangle_cmd none 'a\x5cx20b' 'a\x20b'
 
 


