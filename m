From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:54 -0400
Subject: master - tests: shellcheck liter
Message-ID: <201803231625.w2NGPsSE031968@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=397b7891ff79ba7c31040c31c17aa8587e78a9a6
Commit:        397b7891ff79ba7c31040c31c17aa8587e78a9a6
Parent:        410c99274418f0ce184f670522939ff14a06217f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 17:02:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: shellcheck liter

---
 test/lib/aux.sh      |   10 +++++-----
 test/lib/check.sh    |    4 ++--
 test/lib/inittest.sh |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a22f858..f8fb8a3 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -885,7 +885,7 @@ prepare_devs() {
 	#	dmsetup table $name
 	#done
 
-	printf "%s\n" "${DEVICES[@]}" > DEVICES
+	printf "%s\\n" "${DEVICES[@]}" > DEVICES
 #	( IFS=$'\n'; echo "${DEVICES[*]}" ) >DEVICES
 	echo "ok"
 
@@ -1109,7 +1109,7 @@ prepare_vg() {
 extend_filter() {
 	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
-		filter=$(echo "$filter" | sed -e "s:\[:[ \"$rx\", :")
+		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
 	done
 	lvmconf "$filter"
 }
@@ -1121,7 +1121,7 @@ extend_filter_LVMTEST() {
 hide_dev() {
 	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in "$@"; do
-		filter=$(echo "$filter" | sed -e "s:\[:[ \"r|$dev|\", :")
+		filter=$(echo "$filter" | sed -e "s:\\[:[ \"r|$dev|\", :")
 	done
 	lvmconf "$filter"
 }
@@ -1223,7 +1223,7 @@ EOF
 
 	# append all parameters  (avoid adding empty \n)
 	local v
-	test $# -gt 0 && printf "%s\n" "$@" >> "$config_values"
+	test $# -gt 0 && printf "%s\\n" "$@" >> "$config_values"
 
 	declare -A CONF 2>/dev/null || {
 		# Associative arrays is not available
@@ -1249,7 +1249,7 @@ EOF
 	done < "$config_values"
 
 	# sort by section and iterate through them
-	printf "%s\n" "${!CONF[@]}" | sort | while read -r v ; do
+	printf "%s\\n" "${!CONF[@]}" | sort | while read -r v ; do
 		sec=${v%%/*} # split on section'/'param_name
 		test "$sec" = "$last_sec" || {
 			test -z "$last_sec" || echo "}"
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 1829857..3c7b81a 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -65,8 +65,8 @@ lv_on_diff_() {
 	local diff_e
 
 	# Find diff between 2 shell arrays, print them as stdin files
-	printf "%s\n" "${expect[@]}" | sort | uniq >_lv_on_diff1
-	printf "%s\n" "${xdevs[@]}" >_lv_on_diff2
+	printf "%s\\n" "${expect[@]}" | sort | uniq >_lv_on_diff1
+	printf "%s\\n" "${xdevs[@]}" >_lv_on_diff2
 	diff_e=$(diff _lv_on_diff1 _lv_on_diff2) ||
 		die "LV $2/$3 $(lv_err_list_ "^>" "${diff_e}" found)$(lv_err_list_ "^<" "${diff_e}" "not found")."
 }
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 20bc345..62ec494 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -126,8 +126,8 @@ fi
 echo "$TESTNAME" >TESTNAME
 
 # Require 50M of free space in testdir
-test $(df -k -P . | awk '/\// {print $4}') -gt 51200  ||
-	skip "Testing requires more then 50M of free space in directory $TESTDIR!\n$(df -H | sed -e 's,^,## DF:   ,')"
+test "$(df -k -P . | awk '/\// {print $4}')" -gt 51200 || \
+	skip "Testing requires more then 50M of free space in directory $TESTDIR!\\n$(df -H | sed -e 's,^,## DF:   ,')"
 
 echo "Kernel is $(uname -a)"
 # Report SELinux mode


