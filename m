From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:41 -0400
Subject: master - tests: double quote
Message-ID: <201707101232.v6ACWfZO022652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24751b45bdb1e2f0dc120ccfab7c10b820a1ec53
Commit:        24751b45bdb1e2f0dc120ccfab7c10b820a1ec53
Parent:        5ca4fd0478f239cc04233612bdf52019733b6bef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 10:40:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: double quote

---
 test/lib/check.sh                                  |    4 +-
 test/lib/inittest.sh                               |    2 +-
 test/shell/clvmd-restart.sh                        |    2 +-
 test/shell/dmeventd-restart.sh                     |    2 +-
 test/shell/dmsetup-keyring.sh                      |   56 +++++-----
 test/shell/listings.sh                             |   12 +-
 test/shell/lock-blocking.sh                        |   16 ++--
 test/shell/lock-parallel.sh                        |    2 +-
 test/shell/losetup-partscan.sh                     |   12 +-
 test/shell/lvchange-raid-transient-failures.sh     |   10 +-
 test/shell/lvchange-raid.sh                        |    6 +-
 test/shell/lvchange-raid1-writemostly.sh           |    8 +-
 test/shell/lvchange-rebuild-raid.sh                |    2 +-
 test/shell/lvchange-thin.sh                        |    2 +-
 test/shell/lvconvert-cache-abort.sh                |    2 +-
 test/shell/lvconvert-cache-chunks.sh               |    2 +-
 test/shell/lvconvert-mirror.sh                     |    2 +-
 test/shell/lvconvert-raid-status-validation.sh     |   81 +++++++-------
 test/shell/lvconvert-raid.sh                       |   62 +++++-----
 test/shell/lvconvert-raid10.sh                     |   12 +-
 test/shell/lvconvert-repair-mirror.sh              |    4 +-
 test/shell/lvconvert-repair-raid.sh                |    2 +-
 test/shell/lvcreate-large-raid.sh                  |    2 +-
 test/shell/lvcreate-raid-nosync.sh                 |    2 +-
 test/shell/lvcreate-raid.sh                        |    4 +-
 test/shell/lvcreate-raid10.sh                      |    2 +-
 test/shell/lvcreate-thin-snap.sh                   |    4 +-
 test/shell/lvextend-percent-extents.sh             |   14 +-
 test/shell/lvextend-snapshot-dmeventd.sh           |   10 +-
 test/shell/lvextend-snapshot-policy.sh             |    4 +-
 test/shell/lvmetad-autoshutdown.sh                 |   12 +-
 test/shell/lvmetad-disabled.sh                     |    2 +-
 test/shell/lvmetad-override.sh                     |    2 +-
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    4 +-
 test/shell/lvmetad-pvscan-nomda-bg.sh              |    2 +-
 test/shell/lvmetad-pvscan-nomda.sh                 |    2 +-
 test/shell/lvmetad-restart.sh                      |    2 +-
 test/shell/lvmetad-sysinit.sh                      |    2 +-
 test/shell/metadata.sh                             |    6 +-
 test/shell/mirror-names.sh                         |   16 +--
 test/shell/process-each-duplicate-pvs.sh           |  121 ++++++++++----------
 test/shell/pv-check-dev-size.sh                    |   10 +-
 test/shell/pv-ext-flags.sh                         |    4 +-
 test/shell/pvcreate-bootloaderarea.sh              |    6 +-
 test/shell/pvcreate-operation.sh                   |   28 +++---
 test/shell/pvmove-abort-all.sh                     |    4 +-
 test/shell/pvmove-abort.sh                         |    2 +-
 test/shell/pvmove-basic.sh                         |    2 +-
 test/shell/pvmove-restart.sh                       |    4 +-
 test/shell/pvmove-resume-1.sh                      |   22 ++--
 test/shell/pvmove-resume-2.sh                      |   16 ++--
 test/shell/pvmove-resume-multiseg.sh               |   18 ++--
 test/shell/read-ahead.sh                           |    2 +-
 test/shell/snapshot-autoumount-dmeventd.sh         |    4 +-
 test/shell/snapshot-merge-stack.sh                 |    4 +-
 test/shell/snapshot-merge.sh                       |   24 ++--
 test/shell/thin-autoumount-dmeventd.sh             |    6 +-
 test/shell/thin-dmeventd-warns.sh                  |    8 +-
 test/shell/thin-foreign-dmeventd.sh                |   10 +-
 test/shell/topology-support.sh                     |    6 +-
 test/shell/vg-check-devs-used.sh                   |    2 +-
 test/shell/vgimportclone.sh                        |    2 +-
 test/shell/vgsplit-usage.sh                        |    2 +-
 63 files changed, 349 insertions(+), 353 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index a1abda8..a7653b5 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -374,8 +374,8 @@ compare_fields() {
 	local field2=$6
 	local val1
 	local val2
-	val1=$($cmd1 --noheadings -o "$field1" "$obj1")
-	val2=$($cmd2 --noheadings -o "$field2" "$obj2")
+	val1=$("$cmd1" --noheadings -o "$field1" "$obj1")
+	val2=$("$cmd2" --noheadings -o "$field2" "$obj2")
 	test "$val1" = "$val2" || \
 		die "compare_fields $obj1($field1): $val1 $obj2($field2): $val2"
 }
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index d3844b4..1dad2eb 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -10,7 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 initskip() {
-	test "$#" -eq 0 || echo "TEST SKIPPED: " "$@"
+	test $# -eq 0 || echo "TEST SKIPPED:" "$@"
 	exit 200
 }
 
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index 39e4420..e6067f5 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -27,7 +27,7 @@ CLVMD_SOCKET="/var/run/lvm/clvmd.sock"
 
 restart_clvmd_() {
 	"$LVM_CLVMD_BINARY" -S
-	ls -la $CLVMD_SOCKET || true
+	ls -la "$CLVMD_SOCKET" || true
 
 	for i in $(seq 1 20) ; do
 		test -S "$CLVMD_SOCKET" && break
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 90f4d9a..a5caf98 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -33,7 +33,7 @@ lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
 grep 'already monitored' lvchange.out
 
 # now try what happens if no dmeventd is running
-kill -9 $(< LOCAL_DMEVENTD)
+kill -9 "$(< LOCAL_DMEVENTD)"
 rm LOCAL_DMEVENTD
 
 dmeventd -R -f &
diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index e333a6e..b308975 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -23,8 +23,8 @@ HIDENKEY_32=0000000000000000000000000000000000000000000000000000000000000000
 KEY_NAME="$PREFIX:keydesc"
 
 function _teardown() {
-	keyctl unlink %:$PREFIX-keyring
-	aux teardown_devs_prefixed $PREFIX
+	keyctl unlink "%:$PREFIX-keyring"
+	aux teardown_devs_prefixed "$PREFIX"
 }
 
 aux target_at_least dm-zero 1 0 0 || skip "missing dm-zero target"
@@ -32,45 +32,45 @@ aux target_at_least dm-crypt 1 15 0 || skip "dm-crypt doesn't support keys in ke
 which keyctl || skip "test requires keyctl utility"
 
 keyctl new_session || true   # fails with 'su', works with 'su -'
-keyctl newring $PREFIX-keyring @s
-keyctl timeout %:$PREFIX-keyring 60
+keyctl newring "$PREFIX-keyring" @s
+keyctl timeout "%:$PREFIX-keyring" 60
 
 trap '_teardown' EXIT
 
-keyctl add logon $KEY_NAME ${HEXKEY_32:0:32} %:$PREFIX-keyring
+keyctl add logon "$KEY_NAME" "${HEXKEY_32:0:32}" "%:$PREFIX-keyring"
 
-dmsetup create $PREFIX-zero --table "0 1 zero"
+dmsetup create "$PREFIX-zero" --table "0 1 zero"
 # put key in kernel keyring for active table
-dmsetup create $PREFIX-crypt --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+dmsetup create "$PREFIX-crypt" --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $DM_DEV_DIR/mapper/$PREFIX-zero 0"
 # put hexbyte key in dm-crypt directly in inactive table
-dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER $HEXKEY_32 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+dmsetup load "$PREFIX-crypt" --table "0 1 crypt $CIPHER $HEXKEY_32 0 $DM_DEV_DIR/mapper/$PREFIX-zero 0"
 
 # test dmsetup doesn't hide key descriptions...
-str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME
-str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME
+str=$(dmsetup table "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = ":32:logon:$KEY_NAME"
+str=$(dmsetup table --showkeys "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = ":32:logon:$KEY_NAME"
 
 # ...but it hides hexbyte representation of keys...
-str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HIDENKEY_32
+str=$(dmsetup table --inactive "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = "$HIDENKEY_32"
 #...unless --showkeys explictly requested
-str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HEXKEY_32
+str=$(dmsetup table --showkeys --inactive "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = "$HEXKEY_32"
 
 # let's swap the tables
-dmsetup resume $PREFIX-crypt
-dmsetup load $PREFIX-crypt --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $TESTDIR/dev$prefix/mapper/$PREFIX-zero 0"
+dmsetup resume "$PREFIX-crypt"
+dmsetup load "$PREFIX-crypt" --table "0 1 crypt $CIPHER :32:logon:$KEY_NAME 0 $DM_DEV_DIR/mapper/$PREFIX-zero 0"
 
-str=`dmsetup table --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME
-str=`dmsetup table --showkeys --inactive $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = :32:logon:$KEY_NAME
+str=$(dmsetup table --inactive "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = ":32:logon:$KEY_NAME"
+str=$(dmsetup table --showkeys --inactive "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = ":32:logon:$KEY_NAME"
 
-str=`dmsetup table $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HIDENKEY_32
-str=`dmsetup table --showkeys $PREFIX-crypt | cut -d ' ' -f 5`
-test $str = $HEXKEY_32
+str=$(dmsetup table "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = "$HIDENKEY_32"
+str=$(dmsetup table --showkeys "$PREFIX-crypt" | cut -d ' ' -f 5)
+test "$str" = "$HEXKEY_32"
 
-dmsetup remove $PREFIX-crypt
-dmsetup remove $PREFIX-zero
+dmsetup remove "$PREFIX-crypt"
+dmsetup remove "$PREFIX-zero"
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index ad4ee15..0eac8f6 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -33,11 +33,11 @@ pvcreate --metadatacopies 0 "$dev5"
 
 #COMM bz195276 -- pvs doesn't show PVs until a VG is created
 pvs --noheadings "${DEVICES[@]}"
-test $(pvs --noheadings "${DEVICES[@]}" | wc -l) -eq 5
+test "$(pvs --noheadings "${DEVICES[@]}" | wc -l)" -eq 5
 pvdisplay
 
 #COMM pvs with segment attributes works even for orphans
-test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all "${DEVICES[@]}" | wc -l) -eq 5
+test "$(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all "${DEVICES[@]}" | wc -l)" -eq 5
 
 vgcreate $vg "${DEVICES[@]}"
 
@@ -59,16 +59,16 @@ check pv_field "$dev2" vg_name $vg
 #COMM lvs displays snapshots (bz171215)
 lvcreate -aey -l4 -n $lv1 $vg
 lvcreate -l4 -s -n $lv2 $vg/$lv1
-test $(lvs --noheadings $vg | wc -l) -eq 2
+test "$(lvs --noheadings $vg | wc -l)" -eq 2
 # should lvs -a display cow && real devices? (it doesn't)
-test $(lvs -a --noheadings $vg | wc -l)  -eq 2
+test "$(lvs -a --noheadings $vg | wc -l)"  -eq 2
 dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
 lvcreate -aey -l2 --type mirror -m2 -n $lv3 $vg
-test $(lvs --noheadings $vg | wc -l) -eq 2
-test $(lvs -a --noheadings $vg | wc -l) -eq 6
+test "$(lvs --noheadings $vg | wc -l)" -eq 2
+test "$(lvs -a --noheadings $vg | wc -l)" -eq 6
 dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 
 # Check we parse /dev/mapper/vg-lv
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 1a14d21..c144a8e 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -22,24 +22,24 @@ vgcreate $vg "$dev1" "$dev2"
 
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans sleep 10 &
-while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
+flock -w 5 "$TESTDIR/var/lock/lvm/P_orphans" sleep 10 &
+while ! test -f "$TESTDIR/var/lock/lvm/P_orphans" ; do sleep .1 ; done
 
 vgremove --config 'global { wait_for_locks = 1 }' $vg
 not vgremove --config 'global { wait_for_locks = 1 }' $vg
 
-test ! -f $TESTDIR/var/lock/lvm/P_orphans
+test ! -f "$TESTDIR/var/lock/lvm/P_orphans"
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
 vgcreate $vg "$dev1" "$dev2"
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans sleep 10 &
+flock -w 5 "$TESTDIR/var/lock/lvm/P_orphans" sleep 10 &
 
-while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
-flock_pid=`jobs -p`
+while ! test -f "$TESTDIR/var/lock/lvm/P_orphans" ; do sleep .1 ; done
+flock_pid=$(jobs -p)
 
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
-test -f $TESTDIR/var/lock/lvm/P_orphans # still running
-kill $flock_pid
+test -f "$TESTDIR/var/lock/lvm/P_orphans" # still running
+kill "$flock_pid"
 
 vgremove -ff $vg
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 4f4b340..6a565a9 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -27,7 +27,7 @@ lvcreate -l1 -n $lv2 $vg
 mkfs.ext3 "$DM_DEV_DIR/$vg/$lv1"
 
 # Slowdown PV for resized LV
-aux delay_dev "$dev1" 50 50 $(get first_extent_sector "$dev1"):
+aux delay_dev "$dev1" 50 50 "$(get first_extent_sector "$dev1"):"
 
 lvresize -L-5 -r $vg/$lv1 &
 
diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
index 90fafc0..1a3c70a 100644
--- a/test/shell/losetup-partscan.sh
+++ b/test/shell/losetup-partscan.sh
@@ -23,7 +23,7 @@ aux prepare_loop 1000 -P || skip
 test -f LOOP
 LOOP=$(< LOOP)
 
-echo "1 2" | sfdisk $LOOP
+echo "1 2" | sfdisk "$LOOP"
 
 # wait for links
 aux udev_wait
@@ -35,8 +35,8 @@ test -e "${LOOP}p1"
 aux extend_filter "a|$LOOP|"
 
 # creation should fail for 'partitioned' loop device
-not pvcreate -y $LOOP
-not vgcreate vg $LOOP
+not pvcreate -y "$LOOP"
+not vgcreate vg "$LOOP"
 
 aux teardown_devs
 
@@ -46,7 +46,7 @@ test -f LOOP
 LOOP=$(< LOOP)
 
 
-echo "1 2" | sfdisk $LOOP
+echo "1 2" | sfdisk "$LOOP"
 
 # wait for links
 aux udev_wait
@@ -58,6 +58,6 @@ test ! -e "${LOOP}p1"
 aux extend_filter "a|$LOOP|"
 
 # creation should pass for 'non-partitioned' loop device
-pvcreate -y $LOOP
+pvcreate -y "$LOOP"
 
-vgcreate vg $LOOP
+vgcreate vg "$LOOP"
diff --git a/test/shell/lvchange-raid-transient-failures.sh b/test/shell/lvchange-raid-transient-failures.sh
index 844f217..3082cd6 100644
--- a/test/shell/lvchange-raid-transient-failures.sh
+++ b/test/shell/lvchange-raid-transient-failures.sh
@@ -34,11 +34,11 @@ function _check_raid
 	local devs=$*
 
 	aux wait_for_sync $vg $lv
-	aux disable_dev --error --silent $devs
+	aux disable_dev --error --silent "$devs"
 	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 	fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv"
 	check raid_leg_status $vg $lv "$fail"
-	aux enable_dev --silent $devs
+	aux enable_dev --silent "$devs"
 	lvs -a -o +devices $vg | tee out
 	not grep unknown out
 	lvchange --refresh $vg/$lv
@@ -51,19 +51,19 @@ function _check_raid
 # raid1 with transiently failing devices
 lv=4way
 lvcreate -aey --type raid1 -m 3 --ignoremonitoring -L 1 -n $lv $vg
-_check_raid $vg $lv "ADAD" "AAAA" $dev2 $dev4
+_check_raid $vg $lv "ADAD" "AAAA" "$dev2" "$dev4"
 lvremove -y $vg/$lv
 
 # raid6 with transiently failing devices
 lv=6way
 lvcreate -aey --type raid6 -i 4 --ignoremonitoring -L 1 -n $lv $vg
-_check_raid $vg $lv "ADADAA" "AAAAAA" $dev2 $dev4
+_check_raid $vg $lv "ADADAA" "AAAAAA" "$dev2" "$dev4"
 lvremove -y $vg/$lv
 
 # raid10 with transiently failing devices
 lv=6way
 lvcreate -aey --type raid10 -i 3 -m 1 --ignoremonitoring -L 1 -n $lv $vg
-_check_raid $vg $lv "ADADDA" "AAAAAA" $dev2 $dev4 $dev5
+_check_raid $vg $lv "ADADDA" "AAAAAA" "$dev2" "$dev4" "$dev5"
 lvremove -y $vg/$lv
 
 vgremove -f $vg
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index ac885be..1677d4f 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -145,7 +145,7 @@ run_syncaction_check() {
 	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_syncaction_check\n#\n#\n#\n" \
-		$vg $lv $(get lv_field $vg/$lv segtype -a)
+		$vg $lv "$(get lv_field "$vg/$lv" segtype -a)"
 	aux wait_for_sync $vg $lv
 
 	device=$(get lv_devices $vg/${lv}_rimage_1)
@@ -203,7 +203,7 @@ run_refresh_check() {
 	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_refresh_check\n#\n#\n#\n" \
-		$vg $lv $(get lv_field $vg/$lv segtype -a)
+		$vg $lv "$(get lv_field $vg/$lv segtype -a)"
 
 	aux wait_for_sync $vg $lv
 
@@ -249,7 +249,7 @@ run_recovery_rate_check() {
 	local lv=${2}${THIN_POSTFIX}
 
 	printf "#\n#\n#\n# %s/%s (%s): run_recovery_rate_check\n#\n#\n#\n" \
-		 $vg $lv $(get lv_field $vg/$lv segtype -a)
+		 $vg $lv "$(get lv_field $vg/$lv segtype -a)"
 	lvchange --minrecoveryrate 50 $vg/$lv
 	lvchange --maxrecoveryrate 100 $vg/$lv
 
diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index a6d5b6e..2466de3 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -19,9 +19,9 @@ aux have_raid 1 3 5 || skip
 
 aux prepare_vg 4
 
-for d in $dev1 $dev2 $dev3 $dev4
+for d in "$dev1" "$dev2" "$dev3" "$dev4"
 do
-	aux delay_dev $d 0 20 $(get first_extent_sector "$d")
+	aux delay_dev "$d" 0 20 "$(get first_extent_sector "$d")"
 done
 
 #
@@ -30,13 +30,13 @@ done
 
 # Create 4-way raid1 LV
 lvcreate -aey --ty raid1 -m 3 -Zn -L16M -n $lv1 $vg
-not lvchange -y --writemostly $dev1 $vg/$lv1
+not lvchange -y --writemostly "$dev1" "$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_attr_bit health $vg/${lv1}_rimage_0 "-"
 aux enable_dev $(< DEVICES)
 aux wait_for_sync $vg $lv1
-lvchange -y --writemostly $dev1 $vg/$lv1
+lvchange -y --writemostly "$dev1" "$vg/$lv1"
 check lv_attr_bit health $vg/${lv1}_rimage_0 "w"
 
 vgremove -ff $vg
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index c90406c..4460a5c 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -31,7 +31,7 @@ _sync() {
 # Delay legs so that rebuilding status characters can be read
 for d in $(< DEVICES)
 do
-	aux delay_dev "$d" 0 50 $(get first_extent_sector "$d")
+	aux delay_dev "$d" 0 50 "$(get first_extent_sector "$d")"
 done
 
 # rhbz 1064592
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 3a8cc52..e45f7c8 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -29,7 +29,7 @@ lvcreate -L10M -T $vg/pool
 # tests for checking thin-pool discard passdown are skipped
 pvmajor=$(get pv_field "$dev1" major)
 pvminor=$(get pv_field "$dev1" minor)
-test "$(< /sys/dev/block/$pvmajor\:$pvminor/queue/discard_granularity)" -ne "0" || \
+test "$(< "/sys/dev/block/$pvmajor\:$pvminor/queue/discard_granularity")" -ne 0 || \
         no_discard=1
 
 #
diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 17b5d27..65a6787 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -37,7 +37,7 @@ done
 
 
 # Delay dev to ensure we have some time to 'capture' interrupt in flush
-aux delay_dev "$dev1" 0 500 $(get first_extent_sector "$dev1"):
+aux delay_dev "$dev1" 0 500 "$(get first_extent_sector "$dev1"):"
 
 lvdisplay --maps $vg
 sync
diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index 7fa5b72..a525a95 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -28,7 +28,7 @@ lvcreate -L1T -n cpool $vg
 lvconvert -y --type cache-pool $vg/cpool
 
 # Check chunk size in sectors is more then 512K
-test $(get lv_field $vg/cpool chunk_size --units s --nosuffix) -gt 1000
+test "$(get lv_field "$vg/cpool" chunk_size --units s --nosuffix)" -gt 1000
 
 lvcreate -L1M -n $lv1 $vg
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 86ae0e3..810d13e 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -234,7 +234,7 @@ lvremove -ff $vg
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-lvcreate -aey -l$(pvs --noheadings -ope_count "$dev1") --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l "$(get pv_field "$dev1" pe_count)" --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 aux wait_for_sync $vg $lv1
 lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index bc9654c..e860f9d 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -1,3 +1,4 @@
+#!/usr/bin/env bash
 #######################################################################
 # This series of tests is meant to validate the correctness of
 # 'dmsetup status' for RAID LVs - especially during various sync action
@@ -20,108 +21,108 @@ vgcreate -s 2m $vg $(cat DEVICES)
 ###########################################
 # Upconverted RAID1 should never have all 'a's in status output
 ###########################################
-aux delay_dev $dev2 0 50
-lvcreate -aey -l 2 -n $lv1 $vg $dev1
-lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+aux delay_dev "$dev2" 0 50
+lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
+lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
 while ! check in_sync $vg $lv1; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-	[ ${a[5]} != "aa" ]
+	[ "${a[5]}" != "aa" ]
         sleep .1
 done
-aux enable_dev $dev2
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 ###########################################
 # Upconverted RAID1 should not be@100% right after upconvert
 ###########################################
-aux delay_dev $dev2 0 50
-lvcreate -aey -l 2 -n $lv1 $vg $dev1
-lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+aux delay_dev "$dev2" 0 50
+lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
+lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
 a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-b=( $(echo ${a[6]} | sed s:/:' ':) )
-[ ${b[0]} -ne ${b[1]} ]
-aux enable_dev $dev2
+b=( $(echo "${a[6]}" | sed s:/:' ':) )
+[ "${b[0]}" -ne "${b[1]}" ]
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 ###########################################
 # Catch anything suspicious with linear -> RAID1 upconvert
 ###########################################
-aux delay_dev $dev2 0 50
-lvcreate -aey -l 2 -n $lv1 $vg $dev1
-lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+aux delay_dev "$dev2" 0 50
+lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
+lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
 while true; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-	b=( $(echo ${a[6]} | sed s:/:' ':) )
-	if [ ${b[0]} -ne ${b[1]} ]; then
+	b=( $(echo "${a[6]}" | sed s:/:' ':) )
+	if [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} = "Aa" ]
-		[ ${a[7]} = "recover" ]
+		[ "${a[5]}" = "Aa" ]
+		[ "${a[7]}" = "recover" ]
 	else
 		# Tough to tell the INVALID case,
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
 		# We'll just put "should" for now
-		should [ ${a[5]} = "AA" ]
-		should [ ${a[7]} = "idle" ]
+		should [ "${a[5]}" = "AA" ]
+		should [ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1
 done
-aux enable_dev $dev2
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 ###########################################
 # Catch anything suspicious with RAID1 2-way -> 3-way upconvert
 ###########################################
-aux delay_dev $dev3 0 50
-lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
-lvconvert -y -m +1 $vg/$lv1 $dev3
+aux delay_dev "$dev3" 0 50
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
+lvconvert -y -m +1 $vg/$lv1 "$dev3"
 while true; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-	b=( $(echo ${a[6]} | sed s:/:' ':) )
-	if [ ${b[0]} -ne ${b[1]} ]; then
+	b=( $(echo "${a[6]}" | sed s:/:' ':) )
+	if [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} = "AAa" ]
-		[ ${a[7]} = "recover" ]
+		[ "${a[5]}" = "AAa" ]
+		[ "${a[7]}" = "recover" ]
 	else
 		# Tough to tell the INVALID case,
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
 		# We'll just put "should" for now
-		should [ ${a[5]} = "AAA" ]
-		should [ ${a[7]} = "idle" ]
+		should [ "${a[5]}" = "AAA" ]
+		should [ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1
 done
-aux enable_dev $dev3
+aux enable_dev "$dev3"
 lvremove -ff $vg
 
 ###########################################
 # Catch anything suspicious with RAID1 initial resync
 ###########################################
-aux delay_dev $dev2 0 50
-lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+aux delay_dev "$dev2" 0 50
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
 while true; do
         a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
-	b=( $(echo ${a[6]} | sed s:/:' ':) )
-	if [ ${b[0]} -ne ${b[1]} ]; then
+	b=( $(echo "${a[6]}" | sed s:/:' ':) )
+	if [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("resync" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} = "aa" ]
-		[ ${a[7]} = "resync" ]
+		[ "${a[5]}" = "aa" ]
+		[ "${a[7]}" = "resync" ]
 	else
-		should [ ${a[5]} = "AA" ]
-		should [ ${a[7]} = "idle" ]
+		should [ "${a[5]}" = "AA" ]
+		should [ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1
 done
-aux enable_dev $dev2
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6c05c67..e748003 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -23,7 +23,7 @@ get_image_pvs() {
 	local images
 
 	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
-	lvs --noheadings -a -o devices $images | sed s/\(.\)//
+	lvs --noheadings -a -o devices "$images" | sed s/\(.\)//
 }
 
 ########################################################
@@ -227,14 +227,14 @@ done
 #  - don't allow removal of primary while syncing
 #  - DO allow removal of secondaries while syncing
 ###########################################
-aux delay_dev $dev2 0 100
-lvcreate -aey -l 2 -n $lv1 $vg $dev1
+aux delay_dev "$dev2" 0 100
+lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert -y -m 1 $vg/$lv1 \
-	--config 'global { mirror_segtype_default = "raid1" }' $dev2
+	--config 'global { mirror_segtype_default = "raid1" }' "$dev2"
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
-not lvconvert --yes -m 0 $vg/$lv1 $dev1
-lvconvert --yes -m 0 $vg/$lv1 $dev2
-aux enable_dev $dev2
+not lvconvert --yes -m 0 $vg/$lv1 "$dev1"
+lvconvert --yes -m 0 $vg/$lv1 "$dev2"
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 ###########################################
@@ -242,11 +242,11 @@ lvremove -ff $vg
 #  - DO allow removal of primary while syncing
 #  - DO allow removal of secondaries while syncing
 ###########################################
-aux delay_dev $dev2 0 100
-lvcreate --type raid1 -m 2 -aey -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
-lvconvert --yes -m 1 $vg/$lv1 $dev3
-lvconvert --yes -m 0 $vg/$lv1 $dev1
-aux enable_dev $dev2
+aux delay_dev "$dev2" 0 100
+lvcreate --type raid1 -m 2 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvconvert --yes -m 1 $vg/$lv1 "$dev3"
+lvconvert --yes -m 0 $vg/$lv1 "$dev1"
+aux enable_dev "$dev2"
 lvremove -ff $vg
 
 ###########################################
@@ -254,17 +254,17 @@ lvremove -ff $vg
 #  - DO allow removal of one of primary sources
 #  - Do not allow removal of all primary sources
 ###########################################
-lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
 aux wait_for_sync $vg $lv1
-aux delay_dev $dev3 0 100
-lvconvert --yes -m +1 $vg/$lv1 $dev3
+aux delay_dev "$dev3" 0 100
+lvconvert --yes -m +1 $vg/$lv1 "$dev3"
 # should allow 1st primary to be removed
-lvconvert --yes -m -1 $vg/$lv1 $dev1
+lvconvert --yes -m -1 $vg/$lv1 "$dev1"
 # should NOT allow last primary to be removed
-not lvconvert --yes -m -1 $vg/$lv1 $dev2
+not lvconvert --yes -m -1 $vg/$lv1 "$dev2"
 # should allow non-primary to be removed
-lvconvert --yes -m 0 $vg/$lv1 $dev3
-aux enable_dev $dev3
+lvconvert --yes -m 0 $vg/$lv1 "$dev3"
+aux enable_dev "$dev3"
 lvremove -ff $vg
 
 ###########################################
@@ -272,15 +272,15 @@ lvremove -ff $vg
 #  - Should allow removal of two devices,
 #    as long as they aren't both primary
 ###########################################
-lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
 aux wait_for_sync $vg $lv1
-aux delay_dev $dev3 0 100
-lvconvert --yes -m +1 $vg/$lv1 $dev3
+aux delay_dev "$dev3" 0 100
+lvconvert --yes -m +1 $vg/$lv1 "$dev3"
 # should NOT allow both primaries to be removed
-not lvconvert -m 0 $vg/$lv1 $dev1 $dev2
+not lvconvert -m 0 $vg/$lv1 "$dev1" "$dev2"
 # should allow primary + non-primary
-lvconvert --yes -m 0 $vg/$lv1 $dev1 $dev3
-aux enable_dev $dev3
+lvconvert --yes -m 0 $vg/$lv1 "$dev1" "$dev3"
+aux enable_dev "$dev3"
 lvremove -ff $vg
 
 ###########################################
@@ -289,25 +289,25 @@ lvremove -ff $vg
 # RAID1: Replace up to n-1 devices - trying different combinations
 # Test for 2-way to 4-way RAID1 LVs
 for i in {1..3}; do
-	lvcreate --type raid1 -m $i -l 2 -n $lv1 $vg
+	lvcreate --type raid1 -m "$i" -l 2 -n $lv1 $vg
 
-	for j in $(seq $(($i + 1))); do # The number of devs to replace at once
+	for j in $(seq $(( i + 1 ))); do # The number of devs to replace at once
 	for o in $(seq 0 $i); do        # The offset into the device list
 		replace=""
 
 		devices=( $(get_image_pvs $vg $lv1) )
 
-		for k in $(seq $j); do
+		for k in $(seq "$j"); do
 			index=$((($k + $o) % ($i + 1)))
 			replace="$replace --replace ${devices[$index]}"
 		done
 		aux wait_for_sync $vg $lv1
 
-		if [ $j -ge $((i + 1)) ]; then
+		if [ "$j" -ge $(( i + 1 )) ]; then
 			# Can't replace all at once.
-			not lvconvert $replace $vg/$lv1
+			not lvconvert "$replace" $vg/$lv1
 		else
-			lvconvert $replace $vg/$lv1
+			lvconvert "$replace" $vg/$lv1
 		fi
 	done
 	done
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index ceeaa55..e41b5bf 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -44,16 +44,16 @@ done
 
 # Can't replace adjacent devices
 devices=( $(get_image_pvs $vg $lv1) )
-not lvconvert --replace ${devices[0]} --replace ${devices[1]} $vg/$lv1
-not lvconvert --replace ${devices[2]} --replace ${devices[3]} $vg/$lv1
-not lvconvert --replace ${devices[4]} --replace ${devices[5]} $vg/$lv1
+not lvconvert --replace "${devices[0]}" --replace "${devices[1]}" $vg/$lv1
+not lvconvert --replace "${devices[2]}" --replace "${devices[3]}" $vg/$lv1
+not lvconvert --replace "${devices[4]}" --replace "${devices[5]}" $vg/$lv1
 
 # Can replace non-adjacent devices
 for i in 0 1; do
 	lvconvert \
-		--replace ${devices[$i]} \
-		--replace ${devices[$(($i + 2))]} \
-		--replace ${devices[$(($i + 4))]} \
+		--replace "${devices[$i]}" \
+		--replace "${devices[$(( i + 2 ))]}" \
+		--replace "${devices[$(( i + 4 ))]}" \
 		 $vg/$lv1
 	aux wait_for_sync $vg $lv1
 done
diff --git a/test/shell/lvconvert-repair-mirror.sh b/test/shell/lvconvert-repair-mirror.sh
index e40f9aa..a4d3a73 100644
--- a/test/shell/lvconvert-repair-mirror.sh
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -39,8 +39,8 @@ lvcreate -aey --type mirror -L10 --regionsize 1M -m1 -n $lv1 $vg "$dev1" "$dev2"
 "$MKFS" "$DM_DEV_DIR/$vg/$lv1"
 mkdir "$MOUNT_DIR"
 
-aux delay_dev "$dev2" 0 500 $(get first_extent_sector "$dev2"):
-aux delay_dev "$dev4" 0 500 $(get first_extent_sector "$dev4"):
+aux delay_dev "$dev2" 0 500 "$(get first_extent_sector "$dev2"):"
+aux delay_dev "$dev4" 0 500 "$(get first_extent_sector "$dev4"):"
 #
 # Enforce syncronization
 # ATM requires unmounted/unused LV??
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 86ac261..db38e98 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -27,7 +27,7 @@ function delay
 {
 	for d in $(< DEVICES)
 	do
-		aux delay_dev "$d" 0 $1 $(get first_extent_sector "$d")
+		aux delay_dev "$d" 0 $1 "$(get first_extent_sector "$d")"
 	done
 }
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 7ec140b..27015b7 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -34,7 +34,7 @@ aux lvmconf 'devices/issue_discards = 1'
 # Delay PVs so that resynchronization doesn't fill too much space
 for device in $(< DEVICES)
 do
-	aux delay_dev "$device" 0 10  $(get first_extent_sector "$device")
+	aux delay_dev "$device" 0 10  "$(get first_extent_sector "$device")"
 done
 
 # bz837927 START
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index bd7ec81..9bbc226 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -35,7 +35,7 @@ _sync() {
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 100 $(get first_extent_sector "$dev1")
+aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1")"
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index f1a4a68..61032c9 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 lv_devices() {
-	test $3 -eq $(get lv_devices $1/$2 | wc -w)
+	test "$3" -eq "$(get lv_devices "$1/$2" | wc -w)"
 }
 
 ########################################################
@@ -120,7 +120,7 @@ EAT_SIZE=$(get lv_field $vg/eat_space size)
 lvcreate --type raid1 -m 1 -l 100%FREE -an -Zn -n raid1 $vg "$dev1" "$dev2"
 check lv_field $vg/raid1 size "9.50m"
 # Ensure image size is the same as the RAID1 size
-check lv_field $vg/raid1 size $(get lv_field $vg/raid1_rimage_0 size -a)
+check lv_field $vg/raid1 size "$(get lv_field $vg/raid1_rimage_0 size -a)"
 # Amount remaining in dev2 should equal the amount taken by 'lv' in dev1
 check pv_field "$dev2" pv_free "$EAT_SIZE"
 lvremove -ff $vg/raid1
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 68b4f46..be2bd45 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 lv_devices() {
-	test $3 -eq $(get lv_devices $1/$2 | wc -w)
+	test "$3" -eq "$(get lv_devices "$1/$2" | wc -w)"
 }
 
 ########################################################
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 91de11b..da02641 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -22,8 +22,8 @@ check_lv_field_modules_()
 	mod=$1
 	shift
 
-	for d in $*; do
-		check lv_field $vg/$d modules $mod
+	for d in "$@"; do
+		check lv_field "$vg/$d" modules "$mod"
 	done
 }
 
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 56932a7..83e5994 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -39,7 +39,7 @@ lvremove -f $vg/$lv
 # 'lvextend computes necessary free space correctly - bz213552'
 vgsize=$(get vg_field $vg vg_extent_count)
 lvcreate -l $vgsize  -n $lv $vg
-lvreduce -f -l $(( $vgsize / 2 )) $vg/$lv
+lvreduce -f -l $(( vgsize / 2 )) $vg/$lv
 lvextend -l $vgsize $vg/$lv
 
 # 'Reset LV to original size'
@@ -73,13 +73,13 @@ check pv_field "$dev2" pv_free "0"
 # Thus, total size for the LV should be 18 * 4M = 72M
 #
 # 'Reset LV to 12 extents, allocate every other 2 extents'
-create_pvs=$(for i in $(seq 0 4 20); do echo -n "$dev1:$i-$(($i + 1)) "; done)
+create_pvs=$(for i in $(seq 0 4 20); do echo -n "$dev1:$i-$(( i + 1 )) "; done)
 lvremove -f $vg/$lv
 lvcreate -l 12 -n $lv $vg $create_pvs
 check lv_field $vg/$lv lv_size "48.00m"
 
 # 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges'
-extend_pvs=$(for i in $(seq 0 6 18); do echo -n "$dev1:$i-$(($i + 2)) "; done)
+extend_pvs=$(for i in $(seq 0 6 18); do echo -n "$dev1:$i-$(( i + 2 )) "; done)
 lvextend -l +100%PVS $vg/$lv $extend_pvs | tee out
 grep "Logical volume $vg/$lv successfully resized" out
 check lv_field $vg/$lv lv_size "72.00m"
@@ -90,17 +90,17 @@ check lv_field $vg/$lv lv_size "72.00m"
 # FIXME: test other segment fields such as seg_size, pvseg_start, pvseg_size
 lvremove -f $vg/$lv
 pe_count=$(get pv_field "$dev1" pv_pe_count)
-pe1=$(( $pe_count / 2 ))
+pe1=$(( pe_count / 2 ))
 lvcreate -l $pe1 -n $lv $vg
 pesize=$(get lv_field $vg/$lv vg_extent_size --units b --nosuffix)
-segsize=$(( $pe1 * $pesize / 1024 / 1024 ))m
+segsize=$(( pe1 * pesize / 1024 / 1024 ))m
 check lv_field $vg/$lv seg_count "1"
 check lv_field $vg/$lv seg_start "0"
 check lv_field $vg/$lv seg_start_pe "0"
 #check lv_field $vg/$lv seg_size $segsize
-lvextend -l +$(( $pe_count * 1 )) $vg/$lv
+lvextend -l +$(( pe_count * 1 )) $vg/$lv
 check lv_field $vg/$lv seg_count "2"
-lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
+lvreduce -f -l -$(( pe_count * 1 )) $vg/$lv
 check lv_field $vg/$lv seg_count "1"
 
 # do not reduce to 0 extents
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 46f844a..6165128 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -43,7 +43,7 @@ lvcreate -aey -L16M -n base $vg
 lvcreate -s -L4M -n snap $vg/base
 
 write_ 0 1000
-test 24 -eq $(percent_)
+test 24 -eq "$(percent_)"
 
 lvchange --monitor y $vg/snap
 
@@ -52,9 +52,9 @@ pre=$(percent_)
 # Normally the usage should be ~66% here, however on slower systems
 # dmeventd could be actually 'fast' enough to have COW already resized now
 # so mark test skipped if we are below 50% by now
-test $pre -gt 50 || skip
+test "$pre" -gt 50 || skip
 wait_for_change_ $pre
-test $pre -gt $(percent_)
+test "$pre" -gt "$(percent_)"
 
 # check that a second extension happens; we used to fail to extend when the
 # utilisation ended up between THRESH and (THRESH + 10)... see RHBZ 754198
@@ -63,8 +63,8 @@ test $pre -gt $(percent_)
 write_ 2700 2000
 pre=$(percent_)
 # Mark test as skipped if already resized...
-test $pre -gt 70 || skip
+test "$pre" -gt 70 || skip
 wait_for_change_ $pre
-test $pre -gt $(percent_)
+test "$pre" -gt "$(percent_)"
 
 vgremove -f $vg
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index ce8c46b..236c3f6 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -42,11 +42,11 @@ mkdir mnt
 write 1 4096
 pre=$(percent)
 extend 50
-test $pre -eq $(percent)
+test "$pre" -eq "$(percent)"
 
 write 2 4096
 pre=$(percent)
 extend 50
-test $pre -gt $(percent)
+test "$pre" -gt "$(percent)"
 
 vgremove -f $vg
diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
index d110bf0..4491e08 100644
--- a/test/shell/lvmetad-autoshutdown.sh
+++ b/test/shell/lvmetad-autoshutdown.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-kill -0 $(< LOCAL_LVMETAD) || die "lvmetad is already dead"
+kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad is already dead"
 
 lvmetad_timeout=3
 
@@ -23,14 +23,14 @@ aux prepare_pvs 1
 
 vgcreate $vg1 "$dev1"
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 aux prepare_lvmetad -t $lvmetad_timeout
 
 sleep $lvmetad_timeout
 
 # lvmetad should die after timeout, but give it some time to do so
 i=0
-while kill -0 $(< LOCAL_LVMETAD) 2>/dev/null; do
+while kill -0 "$(< LOCAL_LVMETAD)" 2>/dev/null; do
 	test $i -ge $((lvmetad_timeout*10)) && die "lvmetad didn't shutdown with optional timeout: $lvmetad_timeout seconds"
 	sleep .1
 	i=$((i+1))
@@ -39,9 +39,9 @@ done
 aux prepare_lvmetad -t 0
 sleep 1
 # lvmetad must not die with -t 0 option
-kill -0 $(< LOCAL_LVMETAD) || die "lvmetad died"
+kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad died"
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 aux prepare_lvmetad -t $lvmetad_timeout
 
 sleep 1
@@ -52,6 +52,6 @@ sleep 1
 vgs
 
 # check that connection to lvmetad resets the timeout
-kill -0 $(< LOCAL_LVMETAD) || die "lvmetad died too soon"
+kill -0 "$(< LOCAL_LVMETAD)" || die "lvmetad died too soon"
 
 vgremove -ff $vg1
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 41f1126..28ccdac 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 2
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
 test ! -e "$LVM_LVMETAD_PIDFILE"
 
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index e22f7ba..c71a0c6 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -26,7 +26,7 @@ check active $vg1 $lv1
 lvchange -an $vg1
 check inactive $vg1 $lv1
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 
 lvchange -ay $vg1 2>&1 | tee out
 grep "WARNING: Failed to connect" out
diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index 34139df..3f8e011 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -54,7 +54,7 @@ mkdir test_mnt
 
 setup_merge_ $vg1 $lv1
 mount "$(lvdev_ $vg1 $lv1)" test_mnt
-lvconvert --merge $vg1/$(snap_lv_name_ $lv1)
+lvconvert --merge "$vg1/$(snap_lv_name_ "$lv1")"
 umount test_mnt
 vgchange -an $vg1
 
@@ -63,7 +63,7 @@ pvscan --cache -aay "$dev1"
 
 check active $vg1 $lv1
 i=100
-while ! check lv_not_exists $vg1/$(snap_lv_name_ $lv1); do
+while ! check lv_not_exists "$vg1/$(snap_lv_name_ "$lv1")"; do
 	test $i -lt 0 && fail "Background polling failed to remove merged snapshot LV"
 	sleep .1
 	i=$((i-1))
diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
index 52c25ef..443f8b6 100644
--- a/test/shell/lvmetad-pvscan-nomda-bg.sh
+++ b/test/shell/lvmetad-pvscan-nomda-bg.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 rm LOCAL_LVMETAD
 
 aux prepare_devs 2
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 6cb2062..fe04b00 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 rm LOCAL_LVMETAD
 
 aux prepare_devs 2
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index e40ad23..e2f2666 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -20,7 +20,7 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 vgs | grep $vg1
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 aux prepare_lvmetad
 
 vgs | grep $vg1
diff --git a/test/shell/lvmetad-sysinit.sh b/test/shell/lvmetad-sysinit.sh
index 442f728..33f80fe 100644
--- a/test/shell/lvmetad-sysinit.sh
+++ b/test/shell/lvmetad-sysinit.sh
@@ -52,7 +52,7 @@ check inactive $vg1 $lv1
 # lvmetad is configured and not running
 #
 
-kill $(< LOCAL_LVMETAD)
+kill "$(< LOCAL_LVMETAD)"
 
 lvchange -ay $vg1 2>&1 | tee out
 grep "WARNING: Failed to connect" out
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 273e2d1..8ed5414 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -73,9 +73,9 @@ check pv_field "$dev3" pe_start $pv_align
 pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
 
 # create backup and then restore $dev3
-vgcfgbackup -f $TESTDIR/bak-%s $vg
-pvcreate -ff -y --restorefile $TESTDIR/bak-$vg --uuid $pv3_uuid "$dev3"
-vgcfgrestore -f $TESTDIR/bak-$vg $vg
+vgcfgbackup -f "$TESTDIR/bak-%s" "$vg"
+pvcreate -ff -y --restorefile "$TESTDIR/bak-$vg" --uuid "$pv3_uuid" "$dev3"
+vgcfgrestore -f "$TESTDIR/bak-$vg" "$vg"
 
 # verify pe_start of $dev3
 check pv_field "$dev3" pe_start $pv_align
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 789cbfc..1b9cece 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -45,19 +45,15 @@ lv_convert_lv_() {
 }
 
 enable_devs() {
-	aux enable_dev "$dev1"
-	aux enable_dev "$dev2"
-	aux enable_dev "$dev3"
-	aux enable_dev "$dev4"
-	aux enable_dev "$dev5"
+	for i in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" ; do
+		aux enable_dev "$i"
+	done
 }
 
 delay_devs() {
-	aux delay_dev "$dev1" 0 1000 $(get first_extent_sector "$dev1"):
-	aux delay_dev "$dev2" 0 1000 $(get first_extent_sector "$dev2"):
-	aux delay_dev "$dev3" 0 1000 $(get first_extent_sector "$dev3"):
-	aux delay_dev "$dev4" 0 1000 $(get first_extent_sector "$dev4"):
-	aux delay_dev "$dev5" 0 1000 $(get first_extent_sector "$dev5"):
+	for i in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" ; do
+		aux delay_dev "$i" 0 1000 "$(get first_extent_sector "$i"):"
+	done
 }
 
 # ---------------------------------------------------------------------
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 542ee53..fcd8da1 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -41,17 +41,17 @@ check pv_field "$dev1" pv_allocatable "allocatable"
 check pv_field "$dev2" pv_allocatable "allocatable"
 not grep WARNING out
 
-UUID1=$(pvs --noheadings -o uuid $dev1 | xargs)
-UUID2=$(pvs --noheadings -o uuid $dev2 | xargs)
+UUID1=$(get pv_field "$dev1" uuid)
+UUID2=$(get pv_field "$dev2" uuid)
 
-SIZE1=$(pvs --noheadings -o dev_size $dev1)
-SIZE2=$(pvs --noheadings -o dev_size $dev2)
+SIZE1=$(get pv_field "$dev1" dev_size)
+SIZE2=$(get pv_field "$dev2" dev_size)
 
-MINOR1=$(pvs --noheadings -o minor $dev1)
-MINOR2=$(pvs --noheadings -o minor $dev2)
+MINOR1=$(get pv_field "$dev1" minor)
+MINOR2=$(get pv_field "$dev2" minor)
 
-check pv_field "$dev1" dev_size $SIZE1
-check pv_field "$dev2" dev_size $SIZE2
+check pv_field "$dev1" dev_size "$SIZE1"
+check pv_field "$dev2" dev_size "$SIZE2"
 
 # Copy dev1 over dev2.
 dd if="$dev1" of="$dev2" bs=1M iflag=direct oflag=direct,sync
@@ -65,8 +65,8 @@ grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
 # Don't know yet if dev1 or dev2 is preferred, so count just one is.
-test $(grep $vg1 main | wc -l) -eq 1
-test $(grep $UUID1 main | wc -l) -eq 1
+test "$(grep -c "$vg1" main)" -eq 1
+test "$(grep -c "$UUID1" main)" -eq 1
 not grep duplicate main
 not grep $vg2 main
 not grep $UUID2 main
@@ -75,18 +75,18 @@ grep "was already found on" warn
 grep "prefers device" warn
 
 # Find which is the preferred dev and which is the duplicate.
-PV=$(pvs --noheadings -o name -S uuid=$UUID1)
+PV=$(pvs --noheadings -o name -S uuid="$UUID1" | xargs)
 if [ "$PV" = "$dev1" ]; then
 	DUP=$dev2
 else
 	DUP=$dev1
 fi
 
-echo PV is $PV
-echo DUP is $DUP
+echo "PV is $PV"
+echo "DUP is $DUP"
 
-grep $PV main
-not grep $DUP main
+grep "$PV" main
+not grep "$DUP" main
 
 # Repeat above checking preferred/dup in output
 pvs 2>&1 | tee out
@@ -95,8 +95,8 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-grep $PV main
-not grep $DUP main
+grep "$PV" main
+not grep "$DUP" main
 
 # The duplicate dev is included in 'pvs -a'
 pvs -a -o+uuid,duplicate 2>&1 | tee out
@@ -109,7 +109,7 @@ grep "$dev1" main
 grep "$dev2" main
 grep $PV main
 grep $DUP main
-test $(grep duplicate main | wc -l) -eq 1
+test "$(grep -c duplicate main)" -eq 1
 grep $DUP main | grep duplicate
 not grep $vg2 main
 not grep $UUID2 main
@@ -133,8 +133,8 @@ grep -v WARNING out > main || true
 
 grep "$dev1" main
 not grep "$dev2" main
-grep $UUID1 main
-grep $vg1 main
+grep "$UUID1" main
+grep "$vg1" main
 grep "was already found on" warn
 grep "prefers device" warn
 
@@ -146,8 +146,8 @@ grep -v WARNING out > main || true
 
 grep "$dev2" main
 not grep "$dev1" main
-grep $UUID1 main
-grep $vg1 main
+grep "$UUID1" main
+grep "$vg1" main
 grep "was already found on" warn
 grep "prefers device" warn
 
@@ -163,7 +163,7 @@ grep "$dev1" main | grep $vg1
 grep "$dev2" main | grep $vg1
 grep "$dev1" main | grep $UUID1
 grep "$dev2" main | grep $UUID1
-test $(grep duplicate main | wc -l) -eq 1
+test "$(grep -c duplicate main)" -eq 1
 grep $DUP main | grep duplicate
 
 #
@@ -181,11 +181,11 @@ rm out1 out2 main1 main2 || true
 check pv_field "$dev1" pv_in_use "used"
 check pv_field "$dev2" pv_in_use "used"
 
-check pv_field $PV  pv_allocatable "allocatable"
-check pv_field $DUP pv_allocatable ""
+check pv_field "$PV"  pv_allocatable "allocatable"
+check pv_field "$DUP" pv_allocatable ""
 
-check pv_field $PV  pv_duplicate ""
-check pv_field $DUP pv_duplicate "duplicate"
+check pv_field "$PV"  pv_duplicate ""
+check pv_field "$DUP" pv_duplicate "duplicate"
 
 pvs --noheadings -o name,pv_allocatable "$dev1" "$dev2" 2>&1 | tee out
 
@@ -193,11 +193,11 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-grep $PV main
-grep $DUP main
-grep $dev1 main
-grep $dev2 main
-test $(grep allocatable main | wc -l) -eq 1
+grep "$PV" main
+grep "$DUP" main
+grep "$dev1" main
+grep "$dev2" main
+test "$(grep -c allocatable main)" -eq 1
 
 pvs --noheadings -o name,pv_duplicate "$dev1" "$dev2" 2>&1 | tee out
 
@@ -205,11 +205,11 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-grep $PV main
-grep $DUP main
-grep $dev1 main
-grep $dev2 main
-test $(grep duplicate main | wc -l) -eq 1
+grep "$PV" main
+grep "$DUP" main
+grep "$dev1" main
+grep "$dev2" main
+test "$(grep -c duplicate main)" -eq 1
 
 #
 # A filter can be used to show only one.
@@ -221,8 +221,8 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-not grep $dev1 main
-grep $dev2 main
+not grep "$dev1" main
+grep "$dev2" main
 
 not grep "was already found on" warn
 not grep "prefers device" warn
@@ -234,19 +234,19 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-grep $dev1 main
-not grep $dev2 main
+grep "$dev1" main
+not grep "$dev2" main
 
 not grep "was already found on" warn
 not grep "prefers device" warn
 
 # PV size and minor is still reported correctly for each.
 
-check pv_field "$dev1" dev_size $SIZE1
-check pv_field "$dev2" dev_size $SIZE2
+check pv_field "$dev1" dev_size "$SIZE1"
+check pv_field "$dev2" dev_size "$SIZE2"
 
-check pv_field "$dev1" minor $MINOR1
-check pv_field "$dev2" minor $MINOR2
+check pv_field "$dev1" minor "$MINOR1"
+check pv_field "$dev2" minor "$MINOR2"
 
 # With allow_changes_with_duplicate_pvs=0, a VG with duplicate devs
 # cannot be modified or activated.
@@ -277,14 +277,14 @@ pvcreate "$dev3"
 pvcreate "$dev4"
 pvresize --setphysicalvolumesize 8m -y "$dev4"
 
-UUID3=$(pvs --noheadings -o uuid $dev3 | xargs)
-UUID4=$(pvs --noheadings -o uuid $dev4 | xargs)
+UUID3=$(get pv_field "$dev3" uuid)
+UUID4=$(get pv_field "$dev4" uuid)
 
-SIZE3=$(pvs --noheadings -o dev_size $dev3)
-SIZE4=$(pvs --noheadings -o dev_size $dev4)
+SIZE3=$(get pv_field "$dev3" dev_size)
+SIZE4=$(get pv_field "$dev4" dev_size)
 
-check pv_field "$dev3" dev_size $SIZE3
-check pv_field "$dev4" dev_size $SIZE4
+check pv_field "$dev3" dev_size "$SIZE3"
+check pv_field "$dev4" dev_size "$SIZE4"
 
 pvs 2>&1 | tee out
 
@@ -302,8 +302,8 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep $UUID3 main | wc -l) -eq 1
-not grep $UUID4 main
+test "$(grep -c "$UUID3" main)" -eq 1
+not grep "$UUID4" main
 
 grep "was already found on" warn
 grep "prefers device" warn
@@ -316,7 +316,7 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep $UUID3 main | wc -l) -eq 2
+test "$(grep -c "$UUID3" main)" -eq 2
 
 grep "$dev3" main
 grep "$dev4" main
@@ -367,8 +367,8 @@ grep "prefers device" warn
 
 # Same sizes shown.
 
-check pv_field "$dev3" dev_size $SIZE3
-check pv_field "$dev4" dev_size $SIZE4
+check pv_field "$dev3" dev_size "$SIZE3"
+check pv_field "$dev4" dev_size "$SIZE4"
 
 # Verify that devs being used by an active LV are
 # preferred over duplicates that are not used by an LV.
@@ -377,7 +377,7 @@ dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
 dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
 pvscan --cache
 
-vgcreate $vg2 $dev3 $dev4
+vgcreate "$vg2" "$dev3" "$dev4"
 lvcreate -l1 -n $lv1 $vg2 "$dev3"
 lvcreate -l1 -n $lv2 $vg2 "$dev4"
 
@@ -410,7 +410,7 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep duplicate main | wc -l) -eq 2
+test "$(grep -c duplicate main)" -eq 2
 grep "$dev3" main
 grep "$dev4" main
 grep "$dev5" main
@@ -427,7 +427,7 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep duplicate main | wc -l) -eq 2
+test "$(grep -c duplicate main)" -eq 2
 grep "$dev3" main
 grep "$dev4" main
 grep "$dev5" main
@@ -484,7 +484,7 @@ rm warn main || true
 grep    WARNING out > warn || true
 grep -v WARNING out > main || true
 
-test $(grep duplicate main | wc -l) -eq 2
+test "$(grep -c duplicate main)" -eq 2
 grep "$dev3" main
 grep "$dev4" main
 grep "$dev5" main
@@ -502,4 +502,3 @@ pvscan --cache
 lvremove -y $vg2/$lv1
 lvremove -y $vg2/$lv2
 vgremove $vg2
-
diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
index 76618ad..a3013c4 100644
--- a/test/shell/pv-check-dev-size.sh
+++ b/test/shell/pv-check-dev-size.sh
@@ -20,15 +20,15 @@ aux lvmconf 'metadata/check_pv_device_sizes = 1'
 
 CHECK_MSG="smaller than corresponding PV size"
 
-vgcreate $vg $dev1 2>err
+vgcreate "$vg" "$dev1" 2>err
 not grep "$CHECK_MSG" err
 pvs 2>err
 not grep "$CHECK_MSG" err
 vgremove -ff $vg
 
 # set PV size to 2x dev size
-pvcreate --yes --setphysicalvolumesize 16m $dev1
-vgcreate $vg $dev1 2>err
+pvcreate --yes --setphysicalvolumesize 16m "$dev1"
+vgcreate "$vg" "$dev1" 2>err
 grep "$CHECK_MSG" err
 pvs 2>err
 grep "$CHECK_MSG" err
@@ -36,8 +36,8 @@ vgremove -ff $vg
 
 # should be quiet if requested
 aux lvmconf 'metadata/check_pv_device_sizes = 0'
-pvcreate --yes --setphysicalvolumesize 16m $dev1
-vgcreate $vg $dev1 2>err
+pvcreate --yes --setphysicalvolumesize 16m "$dev1"
+vgcreate "$vg" "$dev1" 2>err
 not grep "$CHECK_MSG" err
 pvs 2>err
 not grep "$CHECK_MSG" err
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index d465497..3e0f3c3 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -78,7 +78,7 @@ aux enable_dev "$dev1"
 #        causing LVM tools to not see the VG inconsistency and once
 #        VG repair is always done, delete this line which removes
 #        persistent .cache as a workaround
-rm -f $TESTDIR/etc/.cache
+rm -f "$TESTDIR/etc/.cache"
 
 vgck $vg1
 # check $dev1 does not contain the PV_EXT_FLAG anymore - it
@@ -143,7 +143,7 @@ aux enable_dev "$dev1"
 #        causing LVM tools to not see the VG inconsistency and once
 #        VG repair is always done, delete this line which removes
 #        persistent .cache as a workaround
-rm -f $TESTDIR/etc/.cache
+rm -f "$TESTDIR/etc/.cache"
 
 vgck $vg1
 # check $dev1 does not contain the PV_EXT_FLAG anymore - it
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index a7647d9..e0f6d2f 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -45,16 +45,16 @@ grep "Bootloader area with data-aligned start must not exceed device size" err
 pvremove -ff "$dev1"
 pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
 vgcreate $vg "$dev1"
-vgcfgbackup -f $TESTDIR/vg_with_ba_backup $vg
+vgcfgbackup -f "$TESTDIR/vg_with_ba_backup" "$vg"
 pv_uuid=$(get pv_field "$dev1" pv_uuid)
 vgremove -ff $vg
 pvremove -ff "$dev1"
-pvcreate --dataalignment 256k --restorefile $TESTDIR/vg_with_ba_backup --uuid "$pv_uuid" "$dev1"
+pvcreate --dataalignment 256k --restorefile "$TESTDIR/vg_with_ba_backup" --uuid "$pv_uuid" "$dev1"
 check pv_field "$dev1" ba_start "262144"
 check pv_field "$dev1" ba_size "786432"
 check pv_field "$dev1" pe_start "1048576"
 
 # error out when restoring the PV and trying to use overlapping bootloader area
 pvremove -ff "$dev1"
-not pvcreate --restorefile $TESTDIR/vg_with_ba_backup --uuid "$pv_uuid" --bootloaderareasize 1m "$dev1" 2>err
+not pvcreate --restorefile "$TESTDIR/vg_with_ba_backup" --uuid "$pv_uuid" --bootloaderareasize 1m "$dev1" 2>err
 grep "Bootloader area would overlap data area" err
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index e8c05c4..c5c9f80 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -100,7 +100,7 @@ done
 # pvcreate (lvm2) fails writing LVM label at sector 4
 not pvcreate --labelsector 4 "$dev1"
 
-backupfile=$PREFIX.mybackupfile
+backupfile="$PREFIX.mybackupfile"
 uuid1=freddy-fred-fred-fred-fred-fred-freddy
 uuid2=freddy-fred-fred-fred-fred-fred-fredie
 bogusuuid=fred
@@ -116,47 +116,47 @@ pvcreate --norestorefile --uuid $uuid1 "$dev1"
 not pvcreate --norestorefile --uuid $uuid1 "$dev2"
 
 # pvcreate rejects non-existent file given with restorefile
-not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
+not pvcreate --uuid $uuid1 --restorefile "$backupfile" "$dev1"
 
 # pvcreate rejects restorefile with uuid not found in file
 pvcreate --norestorefile --uuid $uuid1 "$dev1"
-vgcfgbackup -f $backupfile
-not pvcreate --uuid $uuid2 --restorefile $backupfile "$dev2"
+vgcfgbackup -f "$backupfile"
+not pvcreate --uuid $uuid2 --restorefile "$backupfile" "$dev2"
 
 # vgcfgrestore of a VG containing a PV with zero PEs (bz #820116)
 # (use case: one PV in a VG used solely to keep metadata)
 size_mb=$(($(blockdev --getsz "$dev1") / 2048))
 pvcreate --metadatasize $size_mb "$dev1"
 vgcreate $vg1 "$dev1"
-vgcfgbackup -f $backupfile
-vgcfgrestore -f $backupfile $vg1
+vgcfgbackup -f "$backupfile"
+vgcfgrestore -f "$backupfile" "$vg1"
 vgremove -f $vg1
 pvremove -f "$dev1"
 
 # pvcreate --restorefile should handle --dataalignment and --dataalignmentoffset
 # and check it's compatible with pe_start value being restored
 # X * dataalignment + dataalignmentoffset == pe_start
-pvcreate --norestorefile --uuid $uuid1 --dataalignment 600k --dataalignmentoffset 32k "$dev1"
+pvcreate --norestorefile --uuid "$uuid1" --dataalignment 600k --dataalignmentoffset 32k "$dev1"
 vgcreate $vg1 "$dev1"
-vgcfgbackup -f $backupfile $vg1
+vgcfgbackup -f "$backupfile" "$vg1"
 vgremove -ff $vg1
 pvremove -ff "$dev1"
 # the dataalignment and dataalignmentoffset is ignored here since they're incompatible with pe_start
-pvcreate --restorefile $backupfile --uuid $uuid1 --dataalignment 500k --dataalignmentoffset 10k "$dev1" 2> err
+pvcreate --restorefile "$backupfile" --uuid "$uuid1" --dataalignment 500k --dataalignmentoffset 10k "$dev1" 2> err
 grep "incompatible with restored pe_start value" err
 # 300k is multiple of 600k so this should pass
-pvcreate --restorefile $backupfile --uui $uuid1 --dataalignment 300k --dataalignmentoffset 32k "$dev1" 2> err
+pvcreate --restorefile "$backupfile" --uui "$uuid1" --dataalignment 300k --dataalignmentoffset 32k "$dev1" 2> err
 not grep "incompatible with restored pe_start value" err
-rm -f $backupfile
+rm -f "$backupfile"
 
 # pvcreate rejects non-existent uuid given with restorefile
-not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
+not pvcreate --uuid "$uuid1" --restorefile "$backupfile" "$dev1"
 
 # pvcreate rejects restorefile without uuid
-not pvcreate --restorefile $backupfile "$dev1"
+not pvcreate --restorefile "$backupfile" "$dev1"
 
 # pvcreate rejects uuid restore with multiple volumes specified
-not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1" "$dev2"
+not pvcreate --uuid "$uuid1" --restorefile "$backupfile" "$dev1" "$dev2"
 
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of="$dev1" bs=1024 count=64
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index f18b863..77f8108 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -29,8 +29,8 @@ pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
 # Slowdown writes
-aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
-aux delay_dev "$dev6" 0 800 $(get first_extent_sector "$dev6"):
+aux delay_dev "$dev3" 0 800 "$(get first_extent_sector "$dev3"):"
+aux delay_dev "$dev6" 0 800 "$(get first_extent_sector "$dev6"):"
 
 for mode in "--atomic" "" ;
 do
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 09a6af2..1438ab6 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -22,7 +22,7 @@ pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
 # Slowdown read/writes
-aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev3" 0 800 "$(get first_extent_sector "$dev3"):"
 
 for mode in "--atomic" "" ;
 do
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e228b34..581597b 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -352,7 +352,7 @@ pvmove $mode "$dev1"
 dmsetup create $vg-pvmove0 --notable
 not pvmove $mode -i 1 "$dev2"
 dmsetup info --noheadings -c -o suspended $vg-$lv1
-test $(dmsetup info --noheadings -c -o suspended $vg-$lv1) = "Active"
+test "$(dmsetup info --noheadings -c -o suspended "$vg-$lv1")" = "Active"
 if dmsetup info $vg-pvmove0_mimage_0 > /dev/null; then
         dmsetup remove $vg-pvmove0 $vg-pvmove0_mimage_0 $vg-pvmove0_mimage_1
 else
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index e06ca7e..e7ed78b 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -23,7 +23,7 @@ vgextend $vg "$dev3"
 
 # Slowdown writes
 # (FIXME: generates interesting race when not used)
-aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev3" 0 800 "$(get first_extent_sector "$dev3"):"
 test -e HAVE_DM_DELAY || skip
 
 for mode in "--atomic" ""
@@ -73,7 +73,7 @@ if test -e LOCAL_CLVMD ; then
 	# as clvmd starts to abort on internal errors on various
 	# errors, based on the fact pvmove is killed -9
 	# Restart clvmd
-	kill $(< LOCAL_CLVMD)
+	kill "$(< LOCAL_CLVMD)"
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Shutdown of clvmd is too slow."
 		pgrep clvmd || break
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 5167da5..b13e00d 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -33,9 +33,9 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l30 -n $lv1 $vg
 	lvcreate -an -Zn -l30 -n $lv1 $vg1
 
-	aux delay_dev "$dev3" 0 1000 $(get first_extent_sector "$dev3"):
+	aux delay_dev "$dev3" 0 1000 "$(get first_extent_sector "$dev3"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg $vg1; return 0; }
-	aux delay_dev "$dev4" 0 1000 $(get first_extent_sector "$dev4"):
+	aux delay_dev "$dev4" 0 1000 "$(get first_extent_sector "$dev4"):"
 
 	pvmove -i5 "$dev1" &
 	PVMOVE=$!
@@ -69,7 +69,7 @@ test_pvmove_resume() {
 		# as clvmd starts to abort on internal errors on various
 		# errors, based on the fact pvmove is killed -9
 		# Restart clvmd
-		kill $(< LOCAL_CLVMD)
+		kill "$(< LOCAL_CLVMD)"
 		for i in $(seq 1 100) ; do
 			test $i -eq 100 && die "Shutdown of clvmd is too slow."
 			test -e "$CLVMD_PIDFILE" || break
@@ -116,7 +116,7 @@ lvchange_single() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq $1
 	fi
 }
 
@@ -128,7 +128,7 @@ lvchange_all() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq $1
 	fi
 }
 
@@ -141,7 +141,7 @@ vgchange_single() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq "$1"
 	fi
 }
 
@@ -153,7 +153,7 @@ vgchange_all()  {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq "$1"
 	fi
 }
 
@@ -167,7 +167,7 @@ pvmove_fg() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -192,7 +192,7 @@ pvmove_bg() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -212,7 +212,7 @@ pvmove_fg_single() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -238,7 +238,7 @@ pvmove_bg_single() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 29fd2a8..47f4f22 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -30,7 +30,7 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l15 -n $lv1 $vg "$dev1"
 	lvcreate -an -Zn -l15 -n $lv2 $vg "$dev1"
 
-	aux delay_dev "$dev2" 0 1000 $(get first_extent_sector "$dev2"):
+	aux delay_dev "$dev2" 0 1000 "$(get first_extent_sector "$dev2"):"
 
 	pvmove -i5 "$dev1" &
 	PVMOVE=$!
@@ -57,7 +57,7 @@ test_pvmove_resume() {
 		# as clvmd starts to abort on internal errors on various
 		# errors, based on the fact pvmove is killed -9
 		# Restart clvmd
-		kill $(< LOCAL_CLVMD)
+		kill "$(< LOCAL_CLVMD)"
 		for i in $(seq 1 100) ; do
 			test $i -eq 100 && die "Shutdown of clvmd is too slow."
 			test -e "$CLVMD_PIDFILE" || break
@@ -101,7 +101,7 @@ lvchange_all() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0" || should false
 	elif test -e HAVE_DM_DELAY; then
-		test $(aux count_processes_with_tag) -eq $1 || should false
+		test "$(aux count_processes_with_tag)" -eq "$1" || should false
 	fi
 }
 
@@ -112,7 +112,7 @@ vgchange_single() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 	elif test -e HAVE_DM_DELAY; then
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq "$1"
 	fi
 }
 
@@ -125,7 +125,7 @@ pvmove_fg() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -145,7 +145,7 @@ pvmove_bg() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -163,7 +163,7 @@ pvmove_fg_single() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -183,7 +183,7 @@ pvmove_bg_single() {
 		aux lvmpolld_dump | tee lvmpolld_dump.txt
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 0f4e78d..7783c83 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -33,9 +33,9 @@ test_pvmove_resume() {
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
 	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
 
-	aux delay_dev "$dev4" 0 250 $(get first_extent_sector "$dev4"):
+	aux delay_dev "$dev4" 0 250 "$(get first_extent_sector "$dev4"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
-	aux delay_dev "$dev5" 0 250 $(get first_extent_sector "$dev5"):
+	aux delay_dev "$dev5" 0 250 "$(get first_extent_sector "$dev5"):"
 
 	pvmove -i5 "$dev1" "$dev4" &
 	PVMOVE=$!
@@ -69,7 +69,7 @@ test_pvmove_resume() {
 		# as clvmd starts to abort on internal errors on various
 		# errors, based on the fact pvmove is killed -9
 		# Restart clvmd
-		kill $(< LOCAL_CLVMD)
+		kill "$(< LOCAL_CLVMD)"
 		for i in $(seq 1 100) ; do
 			test $i -eq 100 && die "Shutdown of clvmd is too slow."
 			test -e "$CLVMD_PIDFILE" || break
@@ -117,7 +117,7 @@ lvchange_all() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq $1
 	fi
 }
 
@@ -129,7 +129,7 @@ vgchange_single() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq $1
+		test "$(aux count_processes_with_tag)" -eq "$1"
 	fi
 }
 
@@ -143,7 +143,7 @@ pvmove_fg() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -168,7 +168,7 @@ pvmove_bg() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -188,7 +188,7 @@ pvmove_fg_single() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
@@ -214,7 +214,7 @@ pvmove_bg_single() {
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
 	else
-		test $(aux count_processes_with_tag) -eq 0
+		test "$(aux count_processes_with_tag)" -eq 0
 	fi
 
 	# ...thus finish polling
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 6e4bd35..a16cb40 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -35,7 +35,7 @@ lvremove -ff $vg
 blockdev --setra 768 "$dev1"
 vgscan
 lvcreate -n $lv -L4m $vg "$dev1"
-test $(blockdev --getra "$DM_DEV_DIR/$vg/$lv") -eq 768
+test "$(blockdev --getra "$DM_DEV_DIR/$vg/$lv")" -eq 768
 lvremove -ff $vg
 
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 5567d53..8019281 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -35,7 +35,7 @@ mkdir "$mntdir"
 # Use remount-ro  to avoid logging kernel WARNING
 mount -o errors=remount-ro "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 
-test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 1
+test "$(dmsetup info -c --noheadings -o open $vg-snap)" -eq 1
 
 cat /proc/mounts | grep "$mntdir"
 
@@ -48,7 +48,7 @@ not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=4 conv=fdatasync
 # removed from /proc/mounts, but still opened).
 for i in {1..100}; do
 	sleep .1
-	test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 0 && break
+	test "$(dmsetup info -c --noheadings -o open $vg-snap)" -eq 0 && break
 done
 
 cat /proc/mounts | not grep "$mntdir"
diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 2fdfaa4..0f733bd 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -39,7 +39,7 @@ snap_and_merge() {
 	get lv_field $vg/$lv2 lv_attr | grep "Swi-a-s---"
 	kill $SLEEP_PID
 
-	aux delay_dev "$dev1"  0 200 $(get first_extent_sector "$dev1"):
+	aux delay_dev "$dev1"  0 200 "$(get first_extent_sector "$dev1"):"
 	lvchange --poll n --refresh $vg/$lv1
 	dmsetup table
 	lvs -av -o+lv_merging,lv_merge_failed $vg
@@ -47,7 +47,7 @@ snap_and_merge() {
 	get lv_field $vg/$lv1 lv_attr | grep "Owi-a-"
 	sleep 1
 	check lv_attr_bit state $vg/$lv2 "a"
-	aux error_dev "$dev2" $(get first_extent_sector "$dev2"):
+	aux error_dev "$dev2" "$(get first_extent_sector "$dev2"):"
 	aux enable_dev "$dev1"
 	# delay to let snapshot merge 'discover' failing COW device
 	sleep 1
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index bdbbdba..07756d5 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -23,7 +23,7 @@ lvdev_() {
 }
 
 snap_lv_name_() {
-    echo ${1}_snap
+    echo "${1}_snap"
 }
 
 setup_merge_() {
@@ -53,24 +53,24 @@ setup_merge_ $vg $lv1
 
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
 lvremove -f $vg/$lv1
 
 setup_merge_ $vg $lv1
-lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
+lvconvert --mergesnapshot "$vg/$(snap_lv_name_ "$lv1")"
 lvremove -f $vg/$lv1
 
 # test that an actively merging snapshot may not be removed
 setup_merge_ $vg $lv1
-lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
-not lvremove -f $vg/$(snap_lv_name_ $lv1)
+lvconvert -i+100 --merge --background "$vg/$(snap_lv_name_ "$lv1")"
+not lvremove -f "$vg/$(snap_lv_name_ "$lv1")"
 lvremove -f $vg/$lv1
 
 
 # "onactivate merge" test
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -91,7 +91,7 @@ lvremove -f $vg/$lv1
 #    to make sure preload of origin's metadata is _not_ performed
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -102,19 +102,19 @@ lvremove -f $vg/$lv1
 
 # test multiple snapshot merge; tests copy out that is driven by merge
 setup_merge_ $vg $lv1 1
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
 lvremove -f $vg/$lv1
 
 
 # test merging multiple snapshots that share the same tag
 setup_merge_ $vg $lv1
 setup_merge_ $vg $lv2
-lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
-lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
+lvchange --addtag this_is_a_test "$vg/$(snap_lv_name_ "$lv1")"
+lvchange --addtag this_is_a_test "$vg/$(snap_lv_name_ "$lv2")"
 lvconvert --merge @this_is_a_test
 lvs $vg | tee out
-not grep $(snap_lv_name_ $lv1) out
-not grep $(snap_lv_name_ $lv2) out
+not grep "$(snap_lv_name_ "$lv1")" out
+not grep "$(snap_lv_name_ "$lv2")" out
 lvremove -f $vg/$lv1 $vg/$lv2
 
 # FIXME following tests would need to poll merge progress, via periodic lvs?
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 5e1c2be..b0bbda3 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -31,7 +31,7 @@ cleanup_mounted_and_teardown()
 
 is_lv_opened_()
 {
-	test $(get lv_field "$1" lv_device_open --binary) = "1"
+	test "$(get lv_field "$1" lv_device_open --binary)" = 1
 }
 
 #
@@ -49,12 +49,12 @@ cat <<- EOF >testcmd.sh
 echo "Data: \$DMEVENTD_THIN_POOL_DATA"
 echo "Metadata: \$DMEVENTD_THIN_POOL_METADATA"
 
-$TESTDIR/lib/lvextend --use-policies \$1 || {
+"$TESTDIR/lib/lvextend" --use-policies \$1 || {
 	umount "$mntdir"  || true
 	umount "$mntusedir" || true
 	return 0
 }
-test \$($TESTDIR/lib/lvs -o selected -S "data_percent>95||metadata_percent>95" --noheadings \$1) -eq 0 || {
+test "\$($TESTDIR/lib/lvs -o selected -S "data_percent>95||metadata_percent>95" --noheadings \$1)" -eq 0 || {
 	umount "$mntdir"  || true
 	umount "$mntusedir" || true
 	return 0
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index d22863b..cbab5df 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -47,19 +47,19 @@ lvcreate -L8 -V8 -T $vg/pool -n $lv1
 
 
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=26
-test $(percent_) -gt 80
+test "$(percent_)" -gt 80
 
 # Give it some time to dmeventd to log WARNING
 wait_warn_ 1
 
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
-test $(percent_) -gt 90
+test "$(percent_)" -gt 90
 
 # Give it some time to dmeventd to log WARNING
 wait_warn_ 2
 
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=8
-test $(percent_) -eq 100
+test "$(percent_)" -eq 100
 
 wait_warn_ 3
 
@@ -74,7 +74,7 @@ sleep 11
 
 
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
-test $(percent_) -gt 90
+test "$(percent_)" -gt 90
 
 lvs -a $vg
 dmsetup status ${vg}-pool-tpool
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index 4ba3205..f78fcf8 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -70,12 +70,12 @@ mkdir "$MOUNT_DIR"
 # This mkfs should fill 2MB pool over 95%
 # no autoresize is configured
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
-test $(percent_) -gt 95
+test "$(percent_)" -gt 95
 mount "$DM_DEV_DIR/mapper/$THIN" "$MOUNT_DIR"
 
 pvchange -x n "$dev1" "$dev2"
 
-test $(percent_) -gt 95
+test "$(percent_)" -gt 95
 # Configure autoresize
 aux lvmconf 'activation/thin_pool_autoextend_percent = 10' \
 	    'activation/thin_pool_autoextend_threshold = 75'
@@ -85,7 +85,7 @@ sleep 20
 
 # And check foreign thin device is still mounted
 mount | grep "$MOUNT_DIR" | grep "$THIN"
-test $(percent_) -gt 95
+test "$(percent_)" -gt 95
 
 pvchange -x y "$dev1" "$dev2"
 
@@ -96,11 +96,11 @@ lvchange --refresh $vg/pool
 
 # Give it some time and let dmeventd do some work
 for i in $(seq 1 15) ; do
-	test $(percent_) -ge 75 || break
+	test "$(percent_)" -ge 75 || break
 	sleep 1
 done
 
-test $(percent_) -lt 75
+test "$(percent_)" -lt 75
 
 # And check foreign thin device is still mounted
 mount | grep "$MOUNT_DIR" | grep "$THIN"
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index e8b1eae..90e3d0d 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -22,7 +22,7 @@ lvdev_() {
 
 test_snapshot_mount() {
     lvcreate -aey -L4M -n $lv1 $vg "$dev1"
-    mkfs.ext3 $(lvdev_ $vg $lv1)
+    mkfs.ext3 "$(lvdev_ $vg $lv1)"
     mkdir test_mnt
     mount "$(lvdev_ $vg $lv1)" test_mnt
     lvcreate -L4M -n $lv2 -s $vg/$lv1
@@ -53,11 +53,11 @@ LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
 # Test that kernel supports topology
-if [ ! -e /sys/block/$(basename $(< SCSI_DEBUG_DEV))/alignment_offset ] ; then
+if [ ! -e "/sys/block/$(basename "$(< SCSI_DEBUG_DEV)")/alignment_offset" ] ; then
 	aux cleanup_scsi_debug_dev
 	skip
 fi
-check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$LOGICAL_BLOCK_SIZE"
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs
 
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 26ba694..37f8f43 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -18,7 +18,7 @@ aux driver_at_least 4 15 || skip
 
 aux prepare_devs 3 8
 
-vgcreate $vg $dev1 $dev2
+vgcreate "$vg" "$dev1" "$dev2"
 lvcreate -l100%FREE -n $lv $vg
 dd if="$dev1" of="$dev3" bs=1M
 pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index b579e16..d7b7c96 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -63,7 +63,7 @@ vgimportclone --basevgname $vg2 "$dev2"
 # concerned, can only live on a single device. With the last pvscan, we told it
 # that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
 # since we wrote a different PV over $dev2.
-rm -f $TESTDIR/etc/.cache
+rm -f "$TESTDIR/etc/.cache"
 aux notify_lvmetad "$dev2"
 aux notify_lvmetad "$dev1"
 
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index f404a5b..0ca89d9 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -156,7 +156,7 @@ vgremove -f $vg2 $vg1
 # Restart clvm because using the same
 # devs as lvm1 and then lvm2 causes problems.
 if test -e LOCAL_CLVMD ; then
-	kill $(< LOCAL_CLVMD)
+	kill "$(< LOCAL_CLVMD)"
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Shutdown of clvmd is too slow."
 		pgrep clvmd || break


