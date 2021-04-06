From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:34 +0000 (GMT)
Subject: main - tests: pvmove updates
Message-ID: <20210406200734.37A58384607B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79a168d119d31b99463a286dff8a42e25863895a
Commit:        79a168d119d31b99463a286dff8a42e25863895a
Parent:        b99f7d0df95e24ee367ce0973924ebfdd62a207a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 1 11:33:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

tests: pvmove updates

Switch to plain 'kill' we should no longer need SIGKILL
as polling can be interrupted.

Resolve problem in aux wait_pvmove_lv_ready() that was using
lvm command to check for UUID - but this was interferring with
VG lock and it's been delaying confirmation.

So reducing slow-down of test - so it can run faster.
---
 test/lib/aux.sh                      | 19 +++++++++---------
 test/shell/pvmove-resume-1.sh        | 37 ++++++++++++++----------------------
 test/shell/pvmove-resume-2.sh        | 18 +++++++-----------
 test/shell/pvmove-resume-multiseg.sh | 26 ++++++++++---------------
 4 files changed, 41 insertions(+), 59 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6177de4d4..5cdbe1302 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -215,7 +215,7 @@ prepare_dmeventd() {
 }
 
 prepare_lvmpolld() {
-	lvmconf "global/use_lvmpolld = 1"
+	test -e LOCAL_LVMPOLLD || lvmconf "global/use_lvmpolld = 1"
 
 	local run_valgrind=""
 	test "${LVM_VALGRIND_LVMPOLLD:-0}" -eq 0 || run_valgrind="run_valgrind"
@@ -226,11 +226,11 @@ prepare_lvmpolld() {
 	$run_valgrind lvmpolld -f "$@" -s "$TESTDIR/lvmpolld.socket" -B "$TESTDIR/lib/lvm" -l all &
 	echo $! > LOCAL_LVMPOLLD
 	for i in {200..0} ; do
-		test "$i" -eq 0 && die "Startup of lvmpolld is too slow."
 		test -e "$TESTDIR/lvmpolld.socket" && break
 		echo -n .;
 		sleep .1;
 	done # wait for the socket
+	test "$i" -gt 0 || die "Startup of lvmpolld is too slow."
 	echo ok
 }
 
@@ -1126,7 +1126,10 @@ remove_dm_devs() {
 				}
 			}
 		done
-		test ${#held[@]} -eq 0 && return
+		test ${#held[@]} -eq 0 && {
+		        rm -f debug.log*
+			return
+		}
 		remove=( "${held[@]}" )
 	done
 	die "Can't remove device(s) ${held[@]}"
@@ -1801,8 +1804,8 @@ check_lvmpolld_init_rq_count() {
 }
 
 wait_pvmove_lv_ready() {
-	# given sleep .1 this is about 60 secs of waiting
-	local retries=${2-300}
+	# given sleep .1 this is about 20 secs of waiting
+	local retries=${2-100}
 
 	if [ -e LOCAL_LVMPOLLD ]; then
 		local lvid=""
@@ -1810,10 +1813,8 @@ wait_pvmove_lv_ready() {
 			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
 			test -n "$lvid" || {
 				# wait till wanted LV really appears
-				lvid=$(get lv_field "${1//-//}" vg_uuid,lv_uuid -a 2>/dev/null) && {
-					lvid=${lvid//\ /}
-					lvid=${lvid//-/}
-				}
+				lvid=$(dmsetup info --noheadings -c -o uuid "$1" 2>/dev/null || true)
+				lvid=${lvid##LVM-}
 			}
 			test -z "$lvid" || {
 				lvmpolld_dump > lvmpolld_dump.txt
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 00a8f2dcd..14db30840 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -20,8 +20,6 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
-
 aux prepare_pvs 4 30
 
 vgcreate -s 128k $vg "$dev1"
@@ -36,24 +34,25 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l30 -n $lv1 $vg
 	lvcreate -an -Zn -l30 -n $lv1 $vg1
 
-	aux delay_dev "$dev3" 0 200 "$(get first_extent_sector "$dev3"):"
+	aux delay_dev "$dev3" 0 30 "$(get first_extent_sector "$dev3"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg $vg1; return 0; }
-	aux delay_dev "$dev4" 0 200 "$(get first_extent_sector "$dev4"):"
+	aux delay_dev "$dev4" 0 30 "$(get first_extent_sector "$dev4"):"
 
 	pvmove -i5 "$dev1" &
 	PVMOVE=$!
-	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
-	kill -9 $PVMOVE
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
+	kill $PVMOVE
+	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 
 	pvmove -i5 "$dev2" &
 	PVMOVE=$!
-	aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
-	kill -9 $PVMOVE
-
-	aux remove_dm_devs "$vg-$lv1" "$vg1-$lv1" "$vg-pvmove0" "$vg1-pvmove0"
+	aux wait_pvmove_lv_ready "$vg1-pvmove0"
+	kill $PVMOVE
 	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
 
+	aux remove_dm_devs "$vg-$lv1" "$vg1-$lv1" "$vg-pvmove0" "$vg1-pvmove0"
+
 	check lv_attr_bit type $vg/pvmove0 "p"
 	check lv_attr_bit type $vg1/pvmove0 "p"
 
@@ -79,22 +78,14 @@ test_pvmove_resume() {
 	# bg polling as parameter
 	$1 2
 
-	aux enable_dev "$dev3"
-	aux enable_dev "$dev4"
+	aux enable_dev "$dev3" "$dev4"
 
-	i=0
-	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
-		# wait for 30 secs at max
-		test $i -ge 300 && die "Pvmove is too slow or does not progress."
-		sleep .1
-		i=$((i + 1))
-	done
-	while get lv_field $vg1 name -a | grep -E "^\[?pvmove"; do
-		# wait for 30 secs at max
-		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+	for i in {100..0} ; do
+		lvs -ao name $vg $vg1 | grep "\[pvmove" || break
 		sleep .1
-		i=$((i + 1))
 	done
+	# wait for 10 secs at max
+	test $i -eq 0 && die "Pvmove is too slow or does not progress."
 
 	aux kill_tagged_processes
 
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 233aec3c1..1ba4bc662 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -20,8 +20,6 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
-
 aux prepare_pvs 2 30
 
 vgcreate -s 128k $vg "$dev1"
@@ -33,16 +31,16 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l15 -n $lv1 $vg "$dev1"
 	lvcreate -an -Zn -l15 -n $lv2 $vg "$dev1"
 
-	aux delay_dev "$dev2" 0 200 "$(get first_extent_sector "$dev2"):"
+	aux delay_dev "$dev2" 0 30 "$(get first_extent_sector "$dev2"):"
 
 	pvmove -i5 "$dev1" &
 	PVMOVE=$!
-	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
-	kill -9 $PVMOVE
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
+	kill $PVMOVE
 
-	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" 
 	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
+	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0"
 
 	check lv_attr_bit type $vg/pvmove0 "p"
 
@@ -70,13 +68,11 @@ test_pvmove_resume() {
 
 	aux enable_dev "$dev2"
 
-	i=0
-	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
-		# wait for 30 secs at max
-		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+	for i in {100..0} ; do # wait for 10 secs at max
+		get lv_field $vg name -a | grep -E "^\[?pvmove" || break
 		sleep .1
-		i=$((i + 1))
 	done
+	test $i -gt 0 || die "Pvmove is too slow or does not progress."
 
 	aux kill_tagged_processes
 
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 73c7cf354..af26e5692 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -19,8 +19,6 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
-
 aux prepare_pvs 5 40
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
@@ -35,23 +33,23 @@ test_pvmove_resume() {
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
 	lvcreate -an -Zn -l50 -n $lv2 $vg "$dev3"
 
-	aux delay_dev "$dev4" 0 200 "$(get first_extent_sector "$dev4"):"
+	aux delay_dev "$dev4" 0 30 "$(get first_extent_sector "$dev4"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
-	aux delay_dev "$dev5" 0 200 "$(get first_extent_sector "$dev5"):"
+	aux delay_dev "$dev5" 0 30 "$(get first_extent_sector "$dev5"):"
 
 	pvmove -i5 "$dev1" "$dev4" &
 	PVMOVE=$!
-	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
-	kill -9 $PVMOVE
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
+	kill $PVMOVE
 
 	pvmove -i5 -n $vg/$lv2 "$dev3" "$dev5" &
 	PVMOVE=$!
-	aux wait_pvmove_lv_ready "$vg-pvmove1" 300
-	kill -9 $PVMOVE
+	aux wait_pvmove_lv_ready "$vg-pvmove1"
+	kill $PVMOVE
 
-	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" "$vg-pvmove1"
 	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
+	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" "$vg-pvmove1"
 
 	check lv_attr_bit type $vg/pvmove0 "p"
 	check lv_attr_bit type $vg/pvmove1 "p"
@@ -73,22 +71,18 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-##	rm -f debug.log_DEBUG*
-#	lvs -ao+devices  $vg
-
 	# call resume function (see below)
 	# with expected number of spawned
 	# bg polling as parameter
 	$1 2
 
-	aux enable_dev "$dev4"
-	aux enable_dev "$dev5"
+	aux enable_dev "$dev4" "$dev5"
 
-	for i in {0..300} ; do # wait for 30 secs at max
+	for i in {100..0} ; do # wait for 10 secs at max
 		get lv_field $vg name -a | grep -E "^\[?pvmove" || break
 		sleep .1
 	done
-	test $i -ge 300 && die "Pvmove is too slow or does not progress."
+	test $i -gt 0 || die "Pvmove is too slow or does not progress."
 
 	aux kill_tagged_processes
 


