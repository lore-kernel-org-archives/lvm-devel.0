From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:36 +0000 (GMT)
Subject: main - tests: handle multiple devs with wait_pvmove_lv_ready
Message-ID: <20230424221436.3C8023858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8aea8ae7d000f972d2643a3f097b46c4dbb1fe7
Commit:        b8aea8ae7d000f972d2643a3f097b46c4dbb1fe7
Parent:        8476a09ee5b761d393a26145d2da23615d31579f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 15:24:20 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

tests: handle multiple devs with wait_pvmove_lv_ready

aux wait_pvmove_lv_ready() now handles multiple pvmove LVs
at one go - which allows a bit fast checking - although
at some point we may need to switch to use delayed devs
since mirror throttling seems to be no longer working well,
as CPU are getting so fast, that most of data are already
pvmoved before throttling has any chance to do something...
---
 test/lib/aux.sh                | 51 +++++++++++++++++++++---------------------
 test/shell/pvmove-abort-all.sh |  4 +---
 test/shell/pvmove-abort.sh     |  3 +--
 3 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b2660b65c..d33a13882 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1994,37 +1994,36 @@ check_lvmpolld_init_rq_count() {
 
 wait_pvmove_lv_ready() {
 	# given sleep .1 this is about 20 secs of waiting
-	local retries=${2-100}
+	local lvid=()
+	local all
 
-	if [ -e LOCAL_LVMPOLLD ]; then
-		local lvid=""
-		while : ; do
-			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
-			test -n "$lvid" || {
-				# wait till wanted LV really appears
-				lvid=$(dmsetup info --noheadings -c -o uuid "$1" 2>/dev/null || true)
-				lvid=${lvid##LVM-}
-			}
-			test -z "$lvid" || {
+	for i in {100..0}; do
+		if [ -e LOCAL_LVMPOLLD ]; then
+			if test "${#lvid[@]}" -eq "$#" ; then
 				lvmpolld_dump > lvmpolld_dump.txt
-				check_lvmpolld_init_rq_count 1 "$lvid" lvid && break;
-			}
-			sleep .1
-			retries=$((retries-1))
-		done
-	else
-		while : ; do
-			test "$retries" -le 0 && die "Waiting for pvmove LV to get activated has timed out"
-			dmsetup info -c -o tables_loaded "$1" >out 2>/dev/null|| true;
-			not grep Live out >/dev/null || break
-			sleep .1
-			retries=$((retries-1))
-		done
-	fi
+				all=1
+				for l in "${lvid[@]}" ; do
+					check_lvmpolld_init_rq_count 1 "${l##LVM-}" lvid || all=0
+				done
+				test "$all" = 1 && return
+			else
+				# wait till wanted LV really appears
+				lvid=( $(dmsetup info --noheadings -c -o uuid "$@" 2>/dev/null) ) || true
+			fi
+		else
+			dmsetup info -c --noheadings -o tables_loaded "$@" >out 2>/dev/null || true
+			test "$(grep -c Live out)" = "$#" && return
+		fi
+		sleep .1
+	done
+
+	test -e LOCAL_LVMPOLLD && die "Waiting for lvmpolld timed out"
+	die "Waiting for pvmove LV to get activated has timed out"
 
+	# TODO: remove, uneedeed ??
 	# Adding settle here, to avoid remove, before processing of 'add' is finished
 	# (masking systemd-udevd issue)
-	udevadm settle --timeout=2 || true
+	#udev_wait 2 || true
 }
 
 # Holds device open with sleep which automatically expires after given timeout
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 893223f12..c18467c87 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -53,11 +53,9 @@ cmd3=(pvmove -i1 $backgroundarg $mode -n $vg1/$lv1 "$dev4" "$dev6")
 
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove0"
 	"${cmd2[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove1"
 	"${cmd3[@]}" &
-	aux wait_pvmove_lv_ready "$vg1-pvmove0"
+	aux wait_pvmove_lv_ready "$vg-pvmove0" "$vg-pvmove1" "$vg1-pvmove0"
         lvs -a $vg $vg1
 else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index f5744d430..2917318f4 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -42,9 +42,8 @@ cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove0"
 	"${cmd2[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove1"
+	aux wait_pvmove_lv_ready "$vg-pvmove0" "$vg-pvmove1"
 else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd2[@]}"

