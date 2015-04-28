From: okozina <okozina@fedoraproject.org>
Date: Tue, 28 Apr 2015 20:32:50 +0000 (UTC)
Subject: master - tests: try harder to kill all dangling procs
Message-ID: <20150428203250.7742361383@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90cbc5576fa8511c7045700fa7de0bc3b01e2225
Commit:        90cbc5576fa8511c7045700fa7de0bc3b01e2225
Parent:        8c9ab2a4dd827b575a7a8b501c5ca3474508f964
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Apr 28 15:31:47 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Apr 28 22:31:50 2015 +0200

tests: try harder to kill all dangling procs

also simplify and make less prone to an error checks
for running bg processes inside a pvmove-resume tests
---
 test/shell/lvconvert-mirror.sh       |   10 ++--
 test/shell/mirror-names.sh           |    2 +-
 test/shell/pvmove-background.sh      |    4 +-
 test/shell/pvmove-resume-1.sh        |   94 ++++++++++++++--------------------
 test/shell/pvmove-resume-2.sh        |   83 +++++++++++++-----------------
 test/shell/pvmove-resume-multiseg.sh |   84 +++++++++++++------------------
 6 files changed, 117 insertions(+), 160 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 6ba2ab2..5dde921 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -99,7 +99,7 @@ lvremove -ff $vg
 lvcreate -aey -l5 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
-lvconvert -m+1 -b $vg/$lv1 "$dev4"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 
 # Next convert should fail b/c we can't have 2 at once
 should not lvconvert -m+1 $vg/$lv1 "$dev5"
@@ -156,7 +156,7 @@ lvremove -ff $vg
 
 # "remove newly added mirror"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
-lvconvert -m+1 -b $vg/$lv1 "$dev4"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
 
@@ -167,7 +167,7 @@ lvremove -ff $vg
 
 # "remove one of newly added mirrors"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
-lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
 
@@ -178,7 +178,7 @@ lvremove -ff $vg
 
 # "remove from original mirror (the original is still mirror)"
 lvcreate -aey -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:$DEVRANGE"
-lvconvert -m+1 -b $vg/$lv1 "$dev4"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
@@ -193,7 +193,7 @@ lvremove -ff $vg
 
 # "remove from original mirror (the original becomes linear)"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
-lvconvert -m+1 -b $vg/$lv1 "$dev4"
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 9022ff9..aa640c2 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -101,7 +101,7 @@ check_and_cleanup_lvs_
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
-lvconvert -m+1 -i+40 -b $vg/$lv1
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test $convlv = ${lv1}_mimagetmp_2
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 590c77b..7cb21d5 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -20,10 +20,10 @@ do
 lvcreate -aey -l1 -n $lv1 $vg "$dev1"
 
 lvs -o +devices | grep "$dev1"
-pvmove $mode -i 1 -b "$dev1" "$dev2"
+LVM_TEST_TAG="kill_me_$PREFIX" pvmove $mode -i 1 -b "$dev1" "$dev2"
 sleep 5 # arbitrary...
 lvs -o +devices | not grep "pvmove"
 lvs -o +devices | grep "$dev2"
 
 lvremove -ff $vg
-done
\ No newline at end of file
+done
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 0731c48..9825e76 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -44,13 +44,6 @@ test_pvmove_resume() {
 	kill -9 $PVMOVE
 
 	if test -e LOCAL_LVMPOLLD ; then
-		# inforestart lvmpolld
-		kill $(< LOCAL_LVMPOLLD)
-		for i in $(seq 1 100) ; do
-			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
-			test -e "$LVM_LVMPOLLD_PIDFILE" || break
-			sleep .1
-		done # wait for the pid removal
 		aux prepare_lvmpolld
 	fi
 
@@ -81,14 +74,7 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	if test -e LOCAL_LVMETAD ; then
-		# Restart lvmetad
-		kill $(< LOCAL_LVMETAD)
-		aux prepare_lvmetad
-	fi
-
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	aux notify_lvmetad "$dev1" "$dev2" "$dev3" "$dev4"
 
 	# call resume function (see below)
 	# with expected number of spawned
@@ -112,47 +98,45 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
+	aux kill_listed_processes
+
 	lvremove -ff $vg $vg1
 }
 
 lvchange_single() {
-	lvchange -aey $vg/$lv1
-	lvchange -aey $vg1/$lv1
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg1/$lv1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 lvchange_all() {
-	lvchange -aey $vg/$lv1 $vg1/$lv1
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1 $vg1/$lv1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 vgchange_single() {
-	vgchange -aey $vg
-	vgchange -aey $vg1
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 vgchange_all()  {
-	vgchange -aey $vg $vg1
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg $vg1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 pvmove_fg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg $vg1
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg $vg1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
 
@@ -161,31 +145,31 @@ pvmove_fg() {
 	aux enable_dev "$dev3"
 	aux enable_dev "$dev4"
 
-	pvmove -i0
+	pvmove
 }
 
 pvmove_bg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg $vg1
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg $vg1
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
 
-	pvmove -b -i0
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b -i0
 }
 
 pvmove_fg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
 
@@ -194,23 +178,23 @@ pvmove_fg_single() {
 	aux enable_dev "$dev3"
 	aux enable_dev "$dev4"
 
-	pvmove -i0 "$dev1"
-	pvmove -i0 "$dev2"
+	pvmove "$dev1"
+	pvmove "$dev2"
 }
 
 pvmove_bg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
 
-	pvmove -i0 -b "$dev1"
-	pvmove -i0 -b "$dev2"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev2"
 }
 
 test -e LOCAL_CLVMD && skip
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 0b938f8..dee82cc 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -16,7 +16,7 @@
 
 . lib/inittest
 
-aux prepare_pvs 9 30
+aux prepare_pvs 2 30
 
 vgcreate -s 128k $vg "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
@@ -35,13 +35,6 @@ test_pvmove_resume() {
 	kill -9 $PVMOVE
 
 	if test -e LOCAL_LVMPOLLD ; then
-		# inforestart lvmpolld
-		kill $(< LOCAL_LVMPOLLD)
-		for i in $(seq 1 100) ; do
-			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
-			test -e "$LVM_LVMPOLLD_PIDFILE" || break
-			sleep .1
-		done # wait for the pid removal
 		aux prepare_lvmpolld
 	fi
 
@@ -70,14 +63,7 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	if test -e LOCAL_LVMETAD ; then
-		# Restart lvmetad
-		kill $(< LOCAL_LVMETAD)
-		aux prepare_lvmetad
-	fi
-
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	aux notify_lvmetad "$dev1" "$dev2"
 
 	# call resume function (see below)
 	# with expected number of spawned
@@ -94,83 +80,84 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
+	aux kill_listed_processes
+
 	lvremove -ff $vg
 }
 
 lvchange_single() {
-	lvchange -aey $vg/$lv1
-	lvchange -aey $vg/$lv2
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv2
 }
 
 lvchange_all() {
-	lvchange -aey $vg/$lv1 $vg/$lv2
+	# remove -vvvv
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -vvvv -aey $vg/$lv1 $vg/$lv2
 
 	# we don't want to spawn more than $1 background pollings
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1 || should false
+	test $(aux count_processes_with_tag) -eq $1 || should false
 }
 
 vgchange_single() {
-	vgchange -aey $vg
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 pvmove_fg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 
 	aux enable_dev "$dev2"
 
-	pvmove -i0
+	pvmove
 }
 
 pvmove_bg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 
-	pvmove -b -i0
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
 
 pvmove_fg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 
 	aux enable_dev "$dev2"
 
-	pvmove -i0 "$dev1"
+	pvmove "$dev1"
 }
 
 pvmove_bg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 
-	pvmove -i0 -b "$dev1"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 }
 
 test -e LOCAL_CLVMD && skip
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 829178c..d70662d 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -44,13 +44,6 @@ test_pvmove_resume() {
 	kill -9 $PVMOVE
 
 	if test -e LOCAL_LVMPOLLD ; then
-		# inforestart lvmpolld
-		kill $(< LOCAL_LVMPOLLD)
-		for i in $(seq 1 100) ; do
-			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
-			test -e "$LVM_LVMPOLLD_PIDFILE" || break
-			sleep .1
-		done # wait for the pid removal
 		aux prepare_lvmpolld
 	fi
 
@@ -81,14 +74,7 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
-	if test -e LOCAL_LVMETAD ; then
-		# Restart lvmetad
-		kill $(< LOCAL_LVMETAD)
-		aux prepare_lvmetad
-	fi
-
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	aux notify_lvmetad "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
 	# call resume function (see below)
 	# with expected number of spawned
@@ -106,37 +92,37 @@ test_pvmove_resume() {
 		i=$((i + 1))
 	done
 
+	aux kill_listed_processes
+
 	lvremove -ff $vg
 }
 
 lvchange_single() {
-	lvchange -aey $vg/$lv1
-	lvchange -aey $vg/$lv2
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv2
 }
 
 lvchange_all() {
-	lvchange -aey $vg/$lv1 $vg/$lv2
+	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1 $vg/$lv2
 
 	# we don't want to spawn more than $1 background pollings
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1 || should false
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 vgchange_single() {
-	vgchange -aey -vvvv $vg
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq $1
+	test $(aux count_processes_with_tag) -eq $1
 }
 
 pvmove_fg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg name -a | grep "^\[pvmove1\]"
 
@@ -145,31 +131,31 @@ pvmove_fg() {
 	aux enable_dev "$dev4"
 	aux enable_dev "$dev5"
 
-	pvmove -i0
+	pvmove
 }
 
 pvmove_bg() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg name -a | grep "^\[pvmove1\]"
 
-	pvmove -b -i0
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
 
 pvmove_fg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg name -a | grep "^\[pvmove1\]"
 
@@ -178,23 +164,23 @@ pvmove_fg_single() {
 	aux enable_dev "$dev4"
 	aux enable_dev "$dev5"
 
-	pvmove -i0 "$dev1"
-	pvmove -i0 "$dev3"
+	pvmove "$dev1"
+	pvmove "$dev3"
 }
 
 pvmove_bg_single() {
-	# pvmove resume requires LVs active
-	vgchange -aey --poll n $vg
+	# pvmove resume requires LVs active...
+	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
-	ps h -C lvm | tee out || true
-	test $(wc -l < out) -eq 0
+	# ...also vgchange --poll n must not spawn any bg processes...
+	test $(aux count_processes_with_tag) -eq 0
 
-	# vgchange must not spawn (thus finish) background polling
+	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
 	get lv_field $vg name -a | grep "^\[pvmove1\]"
 
-	pvmove -i0 -b "$dev1"
-	pvmove -i0 -b "$dev3"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev3"
 }
 
 test -e LOCAL_CLVMD && skip


