From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:44 -0400
Subject: master - tests: use bash array
Message-ID: <201707101232.v6ACWi6b022667@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bdd95051ed6a71e447474e96f770b2d79baf4889
Commit:        bdd95051ed6a71e447474e96f770b2d79baf4889
Parent:        efcbad25ee85c2f672ba8f4e30be9fe07d6c34a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 3 20:36:27 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: use bash array

---
 test/shell/mirror-names.sh |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index f3bfe41..899d63d 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -22,27 +22,33 @@ SKIP_WITH_LVMLOCKD=1
 
 lv_devices_() {
 	local d
+	local i
 	local lv=$1
 	shift
-	local devices=$@
+	local devices=( "$@" )
 	local devs
 
 	devs=$(get lv_devices "$lv")
 
 	for d in $devs; do
-		(echo "$devices" | grep "$d") || return 1
-		devices=$(echo "$devices" | sed "s/$d//")
+		(echo "${devices[@]}" | grep "$d") || return 1
+		for i in "${!devices[@]}"; do
+			if [ "${devices[i]}" = "$d" ] ; then
+				unset "devices[i]"
+			fi
+		done
 	done
 
-	test -z "$(echo $devices | sed 's/ //g')"
+	test "${#devices[@]}" -eq 0 ||
+		die "Left devices " "${devices[@]}"
 }
 
 lv_mirror_log_() {
-	get lv_field $1 mirror_log | tr -d []
+	get lv_field "$1" mirror_log | tr -d []
 }
 
 lv_convert_lv_() {
-	get lv_field $1 convert_lv | tr -d []
+	get lv_field "$1" convert_lv | tr -d []
 }
 
 enable_devs() {
@@ -84,7 +90,7 @@ lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg
 lv_devices_ $vg/$lv1 ${lv1}_mimage_0 ${lv1}_mimage_1
 
 #COMM "mirror log is ${lv1}_mlog"
-test $(lv_mirror_log_ $vg/$lv1) = ${lv1}_mlog
+test "$(lv_mirror_log_ $vg/$lv1)" = "${lv1}_mlog"
 
 # "cleanup"
 check_and_cleanup_lvs_
@@ -119,13 +125,13 @@ lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
 delay_devs
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
-test $convlv = ${lv1}_mimagetmp_2
+test "$convlv" = "${lv1}_mimagetmp_2"
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
 lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv1}_mlog
 enable_devs
 
-#COMM "mirror log name after re-adding is ${lv1}_mlog" \
+#COMM "mirror log name after re-adding is ${lv1}_mlog"
 lvconvert -f --mirrorlog core $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
@@ -133,7 +139,7 @@ lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
 lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv1}_mlog
 
-#COMM "renamed converting mirror names: $lv1 to $lv2" \
+#COMM "renamed converting mirror names: $lv1 to $lv2"
 lvrename $vg/$lv1 $vg/$lv2
 convlv=$(lv_convert_lv_ $vg/$lv2)
 lv_devices_ $vg/$lv2 $convlv ${lv2}_mimage_2


