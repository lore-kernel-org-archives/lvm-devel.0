From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  2 Mar 2014 19:54:26 +0000 (UTC)
Subject: master - test: Properly synchronize direct dmsetup calls.
Message-ID: <20140302195426.2EA0E6118D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b958984f185fdbc220085b9faef04d11ae6ecf4
Commit:        3b958984f185fdbc220085b9faef04d11ae6ecf4
Parent:        72ecf8e591d1ee6b863d814114a7a8045598efc0
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 2 20:11:44 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Sun Mar 2 20:53:43 2014 +0100

test: Properly synchronize direct dmsetup calls.

---
 test/lib/aux.sh                     |   16 ++++++++++++++--
 test/shell/lvconvert-repair-thin.sh |    4 ++--
 test/shell/name-mangling.sh         |   28 +++++++++++++---------------
 3 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5ae40e8..eae01ee 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -754,7 +754,19 @@ have_readline()
 	echo version | lvm &>/dev/null
 }
 
+dmsetup_wrapped()
+{
+	udev_wait
+	init_udev_transaction
+	dmsetup "$@"
+	finish_udev_transaction
+}
+
 test -f DEVICES && devs=$(cat DEVICES)
 
-#unset LVM_VALGRIND
-"$@"
+if test "$1" = dmsetup; then
+    shift
+    dmsetup_wrapped "$@"
+else
+    "$@"
+fi
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index b80b855..30cd76d 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -94,8 +94,8 @@ lvchange -an $vg
 should lvremove -ff $vg
 
 # let's not block PVs with openned _tdata/_tmeta devices
-dmsetup remove $vg-pool_tdata || true
-dmsetup remove $vg-pool_tmeta || true
+aux dmsetup remove $vg-pool_tdata || true
+aux dmsetup remove $vg-pool_tmeta || true
 
 dmsetup table
 
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 76d90fa..4522a55 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -11,8 +11,6 @@
 
 . lib/test
 
-name_prefix=$RANDOM
-
 CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#+-.:=@_"
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
 FAIL_MULTI_STR="seems to be mangled more than once"
@@ -34,7 +32,7 @@ function create_dm_dev()
 		verify_udev=""
 	fi
 
-	dmsetup create "${name_prefix}$name" $verify_udev --manglename $mode --table "0 1 zero"
+	aux dmsetup create "${PREFIX}$name" $verify_udev --manglename $mode --table "0 1 zero"
 }
 
 function remove_dm_dev()
@@ -48,7 +46,7 @@ function remove_dm_dev()
 		verify_udev=""
 	fi
 
-	dmsetup remove $verify_udev --manglename $mode "${name_prefix}$name"
+	aux dmsetup remove $verify_udev --manglename $mode "${PREFIX}$name"
 }
 
 function check_create_and_remove()
@@ -64,9 +62,9 @@ function check_create_and_remove()
 		verify_udev=""
 	fi
 
-	dmsetup create "${name_prefix}$input_name" $verify_udev --manglename $mode --table "0 1 zero" 2>err && \
-	test -b "$DM_DEV_DIR/mapper/${name_prefix}$dm_name" && \
-	dmsetup remove "${name_prefix}$input_name" $verify_udev --manglename $mode || r=1
+	aux dmsetup create "${PREFIX}$input_name" $verify_udev --manglename $mode --table "0 1 zero" 2>err && \
+	test -b "$DM_DEV_DIR/mapper/${PREFIX}$dm_name" && \
+	aux dmsetup remove "${PREFIX}$input_name" $verify_udev --manglename $mode || r=1
 
 	if [ $dm_name = "FAIL_MIXED" ]; then
 		r=0
@@ -89,7 +87,7 @@ function check_dm_field()
 	local field=$3
 	local expected="$4"
 
-	value=$(dmsetup info --rows --noheadings --manglename $mode -c -o $field "${DM_DEV_DIR}/mapper/${name_prefix}$dm_name" 2> err || true)
+	value=$(dmsetup info --rows --noheadings --manglename $mode -c -o $field "${DM_DEV_DIR}/mapper/${PREFIX}$dm_name" 2> err || true)
 
 	if [ "$expected" = "FAIL_MIXED" ]; then
 		grep "$FAIL_MIXED_STR" err
@@ -98,7 +96,7 @@ function check_dm_field()
 	elif [ "$expected" = "FAIL_BLACK" ]; then
 		grep "$FAIL_BLACK_STR" err
 	else
-		test "$value" = "${name_prefix}$expected"
+		test "$value" = "${PREFIX}$expected"
 	fi
 }
 
@@ -110,7 +108,7 @@ function check_expected_names()
 
 	create_dm_dev none "$dm_name"
 
-	test -b "$DM_DEV_DIR/mapper/${name_prefix}$dm_name" && \
+	test -b "$DM_DEV_DIR/mapper/${PREFIX}$dm_name" && \
 	check_dm_field none "$dm_name" name "$dm_name" && \
 	check_dm_field $mode "$dm_name" name "$3" && \
 	check_dm_field $mode "$dm_name" mangled_name "$4" && \
@@ -131,7 +129,7 @@ function check_mangle_cmd()
 
 	create_dm_dev none "$dm_name"
 
-	dmsetup mangle --manglename $mode "${name_prefix}$dm_name" 1>out 2>err || true;
+	dmsetup mangle --manglename $mode "${PREFIX}$dm_name" 1>out 2>err || true;
 
 	if [ "$expected" = "OK" ]; then
 		grep "$CORRECT_FORM_STR" out || r=1
@@ -141,7 +139,7 @@ function check_mangle_cmd()
 		grep "$FAIL_MULTI_STR" err || r=1
 	else
 		rename_expected=1
-		grep -F "$RENAMING_STR ${name_prefix}$expected" out || r=1
+		grep -F "$RENAMING_STR ${PREFIX}$expected" out || r=1
 	fi
 
 	if [ $r = 0 -a $rename_expected = 1 ]; then
@@ -151,7 +149,7 @@ function check_mangle_cmd()
 		# failed to rename to expected or renamed when it should not - find the new name
 		new_name=$(sed -e "s/.*: $RENAMING_STR //g" out)
 		# try to remove any of the form - falling back to less probable error scenario
-		dmsetup remove --verifyudev --manglename none "$new_name" || \
+		aux dmsetup remove --verifyudev --manglename none "$new_name" || \
 		remove_dm_dev none "$dm_name" || remove_dm_dev none "$expected"
 	else
 		# successfuly done nothing
@@ -164,8 +162,8 @@ function check_mangle_cmd()
 # check dmsetup can process path where the last component is not equal dm name (rhbz #797322)
 r=0
 create_dm_dev auto "abc"
-ln -s "$DM_DEV_DIR/mapper/${name_prefix}abc" "$DM_DEV_DIR/${name_prefix}xyz"
-dmsetup status "$DM_DEV_DIR/${name_prefix}xyz" || r=1
+ln -s "$DM_DEV_DIR/mapper/${PREFIX}abc" "$DM_DEV_DIR/${PREFIX}xyz"
+aux dmsetup status "$DM_DEV_DIR/${PREFIX}xyz" || r=1
 remove_dm_dev auto "abc"
 if [ r = 1 ]; then
 	exit 1


