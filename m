From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:46 +0000 (UTC)
Subject: master - tests: minor simplifications
Message-ID: <20150501130846.BF35160FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79844b9066e53d9618f6641d5cee9c7264fe01fd
Commit:        79844b9066e53d9618f6641d5cee9c7264fe01fd
Parent:        fee09f0964bd64dee982eb615a6853e770ad0a4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 21:51:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:59 2015 +0200

tests: minor simplifications

minor updates
---
 test/lib/aux.sh                              |    9 ++++-----
 test/shell/lvchange-raid.sh                  |    2 +-
 test/shell/lvmetad-pvscan-nomda.sh           |    6 ++----
 test/shell/process-each-duplicate-vgnames.sh |   13 ++++---------
 test/shell/process-each-pv-nomda-all.sh      |    1 -
 5 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ae15235..c1889ac 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -34,8 +34,6 @@ prepare_clvmd() {
 	if test -z "${installed_testsuite+varset}"; then
 		(which clvmd 2>/dev/null | grep -q "$abs_builddir") || skip
 	fi
-	# lvs is executed from clvmd - use our version
-	export LVM_BINARY=$(which lvm)
 
 	test -e "$DM_DEV_DIR/control" || dmsetup table >/dev/null # create control node
 	# skip if singlenode is not compiled in
@@ -46,7 +44,8 @@ prepare_clvmd() {
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	rm -f "$CLVMD_PIDFILE"
 	echo "<======== Starting CLVMD ========>"
-	LVM_LOG_FILE_EPOCH=CLVMD $run_valgrind clvmd -Isinglenode -d 1 -f &
+	# lvs is executed from clvmd - use our version
+	LVM_LOG_FILE_EPOCH=CLVMD LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in $(seq 1 100) ; do
@@ -422,7 +421,7 @@ prepare_md_dev() {
 		mddev=/dev/md_lvm_test0
 
 	mdadm --create --metadata=1.0 "$mddev" --auto=md --level $level --chunk $rchunk --raid-devices=$rdevs "${@:4}"
-	test -b "$mddev" || skip "mdadm has not create device!"
+	test -b "$mddev" || skip "mdadm has not created device!"
 
 	# LVM/DM will see this device
 	case "$DM_DEV_DIR" in
@@ -467,7 +466,7 @@ prepare_backing_dev() {
 	if test -f BACKING_DEV; then
 		BACKING_DEV=$(< BACKING_DEV)
 	elif test -b "$LVM_TEST_BACKING_DEVICE"; then
-		BACKING_DEV="$LVM_TEST_BACKING_DEVICE"
+		BACKING_DEV=$LVM_TEST_BACKING_DEVICE
 		echo "$BACKING_DEV" > BACKING_DEV
 	else
 		prepare_loop "$@"
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 00b5265..4ce776f 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -209,7 +209,7 @@ run_refresh_check() {
 
 	# Disable dev2 and do some I/O to make the kernel notice
 	aux disable_dev "$dev2"
-	dd if=/dev/urandom of=$DM_DEV_DIR/$sizelv bs=1k count=$size
+	dd if=/dev/urandom of="$DM_DEV_DIR/$sizelv" bs=1k count=$size
 	sync
 
 	# Check for 'p'artial flag
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 39604d0..395e326 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -23,13 +23,11 @@ vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n foo -l 1 -an --zero n $vg1
 
 # start lvmetad but make sure it doesn't know about $dev1 or $dev2
-aux disable_dev "$dev1"
-aux disable_dev "$dev2"
+aux disable_dev "$dev1" "$dev2"
 aux prepare_lvmetad
 lvs
 mv LOCAL_LVMETAD XXX
-aux enable_dev "$dev2"
-aux enable_dev "$dev1"
+aux enable_dev "$dev2" "$dev1"
 mv XXX LOCAL_LVMETAD
 
 aux lvmconf 'global/use_lvmetad = 0'
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 5867fd1..9b1f807 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -14,8 +14,7 @@ aux prepare_devs 2
 pvcreate "$dev1"
 pvcreate "$dev2"
 
-aux disable_dev "$dev1"
-aux disable_dev "$dev2"
+aux disable_dev "$dev1" "$dev2"
 
 aux enable_dev "$dev1"
 vgscan
@@ -35,8 +34,7 @@ vgscan
 pvs "$dev1"
 pvs "$dev2"
 
-vgs -o+vg_uuid >err
-cat err
+vgs -o+vg_uuid | tee err
 grep $UUID1 err
 grep $UUID2 err
 
@@ -45,18 +43,15 @@ grep $UUID2 err
 # grep $UUID1 err
 
 aux disable_dev "$dev2"
-vgs -o+vg_uuid >err
-cat err
+vgs -o+vg_uuid | tee err
 grep $UUID1 err
 not grep $UUID2 err
 aux enable_dev "$dev2"
 vgscan
 
 aux disable_dev "$dev1"
-vgs -o+vg_uuid >err
-cat err
+vgs -o+vg_uuid | tee err
 grep $UUID2 err
 not grep $UUID1 err
 aux enable_dev "$dev1"
 vgscan
-
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index 93eb0bd..44cde5a 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -57,4 +57,3 @@ grep "$dev11" err
 grep "$dev12" err
 grep "$dev13" err
 grep "$dev14" err
-


