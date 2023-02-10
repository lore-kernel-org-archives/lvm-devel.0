From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:35 +0000 (GMT)
Subject: main - tests: reduce shellcheck warns
Message-ID: <20230210165335.2F0E33858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d419b374a0bd2ebcc56e77d2578684aee998cbd
Commit:        7d419b374a0bd2ebcc56e77d2578684aee998cbd
Parent:        773bc013778df631f9ee14e7a79d5f02211b1e67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 16:05:40 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

tests: reduce shellcheck warns

Reduce warnings in tests.
---
 test/shell/fsadm-crypt-fsresize.sh            |  2 +-
 test/shell/fsadm-crypt.sh                     |  2 +-
 test/shell/hints.sh                           |  4 ++--
 test/shell/idm_fabric_failure.sh              | 12 ++++++------
 test/shell/idm_fabric_failure_half_brain.sh   | 10 +++++-----
 test/shell/idm_fabric_failure_timeout.sh      |  8 ++++----
 test/shell/idm_ilm_failure.sh                 |  6 +++---
 test/shell/large-physical-sector-size.sh      |  2 +-
 test/shell/lvconvert-mirror-updown.sh         |  4 ++--
 test/shell/lvconvert-mirror.sh                |  4 ++--
 test/shell/lvconvert-repair-cache.sh          |  4 ++--
 test/shell/lvconvert-snapshot-thin.sh         |  2 +-
 test/shell/lvextend-raid.sh                   | 18 +++++++++---------
 test/shell/lvmlockd-lv-types.sh               |  2 +-
 test/shell/metadata-bad-text.sh               |  6 +++---
 test/shell/metadata-zero-space.sh             | 10 +++-------
 test/shell/mirror-names.sh                    |  4 ++--
 test/shell/multi_hosts_lv_ex_timeout_hosta.sh | 14 +++++++-------
 test/shell/multi_hosts_lv_hosta.sh            |  8 ++++----
 test/shell/multi_hosts_lv_sh_timeout_hosta.sh | 18 +++++++++---------
 test/shell/open-file-limit.sh                 |  6 +++---
 test/shell/pvck-repair.sh                     |  4 ++--
 test/shell/report-format.sh                   |  6 +++---
 test/shell/udev-pvscan-vgchange.sh            |  6 +++---
 test/shell/vgchange-pvs-online.sh             |  6 +++---
 25 files changed, 82 insertions(+), 86 deletions(-)

diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
index 65f555b29..56cd5c508 100644
--- a/test/shell/fsadm-crypt-fsresize.sh
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -89,7 +89,7 @@ test ! -d "$mount_dir" && mkdir "$mount_dir"
 crypt_close() {
 	aux udev_wait
 	cryptsetup remove "$1"
-	if [ "$?" -eq 0 -a -n "$DROP_SYMLINK" ]; then
+	if [ "$?" -eq 0 ] && [ -n "$DROP_SYMLINK" ]; then
 		rm -f "$DM_DEV_DIR/mapper/$1"
 	fi
 }
diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 4d6efbc63..4415cea8f 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -82,7 +82,7 @@ test ! -d "$mount_dir" && mkdir "$mount_dir"
 crypt_close() {
 	aux udev_wait
 	cryptsetup remove "$1"
-	if [ "$?" -eq 0 -a -n "$DROP_SYMLINK" ]; then
+	if [ "$?" -eq 0 ] && [ -n "$DROP_SYMLINK" ]; then
 		rm -f "$DM_DEV_DIR/mapper/$1"
 	fi
 }
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 68e61153d..7fe0e33f5 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -110,12 +110,12 @@ not grep scan: tmptest
 
 if which strace; then
 strace -e io_submit pvs 2>&1|tee tmptest
-test "$(grep io_submit tmptest | wc -l)" -eq 3
+test "$(grep -c io_submit tmptest)" -eq 3
 
 # test that 'pvs -a' submits seven reads, one for each device,
 # and one more in vg_read rescan check
 strace -e io_submit pvs -a 2>&1|tee tmptest
-test "$(grep io_submit tmptest | wc -l)" -eq 7
+test "$(grep -c io_submit tmptest)" -eq 7
 fi
 
 #
diff --git a/test/shell/idm_fabric_failure.sh b/test/shell/idm_fabric_failure.sh
index 633dd9d73..edca86b9c 100644
--- a/test/shell/idm_fabric_failure.sh
+++ b/test/shell/idm_fabric_failure.sh
@@ -24,13 +24,13 @@ vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 # Create new logic volume
 lvcreate -a ey --zero n -l 50%FREE -n $lv1 $vg
 
-DRIVE1=`dmsetup deps -o devname $dev1 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
-DRIVE2=`dmsetup deps -o devname $dev2 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
-DRIVE3=`dmsetup deps -o devname $dev3 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE1=$(dmsetup deps -o devname "$dev1" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
+DRIVE2=$(dmsetup deps -o devname "$dev2" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
+DRIVE3=$(dmsetup deps -o devname "$dev3" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
 
-HOST1=`readlink /sys/block/$DRIVE1 | awk -F'/' '{print $6}'`
-HOST2=`readlink /sys/block/$DRIVE2 | awk -F'/' '{print $6}'`
-HOST3=`readlink /sys/block/$DRIVE3 | awk -F'/' '{print $6}'`
+HOST1=$(readlink "/sys/block/$DRIVE1" | awk -F'/' '{print $6}')
+HOST2=$(readlink "/sys/block/$DRIVE2" | awk -F'/' '{print $6}')
+HOST3=$(readlink "/sys/block/$DRIVE3" | awk -F'/' '{print $6}')
 
 # Emulate fabric failure
 echo 1 > "/sys/block/$DRIVE1/device/delete"
diff --git a/test/shell/idm_fabric_failure_half_brain.sh b/test/shell/idm_fabric_failure_half_brain.sh
index 784b26896..e6496461c 100644
--- a/test/shell/idm_fabric_failure_half_brain.sh
+++ b/test/shell/idm_fabric_failure_half_brain.sh
@@ -21,8 +21,8 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 2
 aux extend_filter_LVMTEST
 
-DRIVE1=`dmsetup deps -o devname $dev1 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
-DRIVE2=`dmsetup deps -o devname $dev2 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE1=$(dmsetup deps -o devname "$dev1" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
+DRIVE2=$(dmsetup deps -o devname "$dev2" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
 
 [ "$(basename -- $DRIVE1)" = "$(basename -- $DRIVE2)" ] && die "Need to pass two different drives!?"
 
@@ -42,14 +42,14 @@ drive_list=($DRIVE1)
 # Find all drives with the same WWN and delete them from system,
 # so that we can emulate the same drive with multiple paths are
 # disconnected with system.
-drive_wwn=`udevadm info /dev/${DRIVE1} | awk -F= '/E: ID_WWN=/ {print $2}'`
+drive_wwn=$(udevadm info /dev/${DRIVE1} | awk -F= '/E: ID_WWN=/ {print $2}')
 for dev in /dev/*; do
 	if [ -b "$dev" ] && [[ ! "$dev" =~ [0-9] ]]; then
-		wwn=`udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}'`
+		wwn=$(udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}')
 		if [ "$wwn" = "$drive_wwn" ]; then
 			base_name="$(basename -- ${dev})"
 			drive_list+=("$base_name")
-			host_list+=(`readlink /sys/block/$base_name | awk -F'/' '{print $6}'`)
+			host_list+=( $(readlink "/sys/block/$base_name" | awk -F'/' '{print $6}') )
 		fi
 	fi
 done
diff --git a/test/shell/idm_fabric_failure_timeout.sh b/test/shell/idm_fabric_failure_timeout.sh
index 2466f94f0..2924d81a6 100644
--- a/test/shell/idm_fabric_failure_timeout.sh
+++ b/test/shell/idm_fabric_failure_timeout.sh
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 1
 aux extend_filter_LVMTEST
 
-DRIVE1=`dmsetup deps -o devname $dev1 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE1=$(dmsetup deps -o devname "$dev1" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
 
 # The previous device-mapper are removed, but LVM still can directly
 # access VGs from the specified physical drives.  So enable drives
@@ -39,14 +39,14 @@ drive_list=( "$DRIVE1" )
 # Find all drives with the same WWN and delete them from system,
 # so that we can emulate the same drive with multiple paths are
 # disconnected with system.
-drive_wwn=`udevadm info /dev/${DRIVE1} | awk -F= '/E: ID_WWN=/ {print $2}'`
+drive_wwn=$(udevadm info /dev/${DRIVE1} | awk -F= '/E: ID_WWN=/ {print $2}')
 for dev in /dev/*; do
 	if [ -b "$dev" ] && [[ ! "$dev" =~ [0-9] ]]; then
-		wwn=`udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}'`
+		wwn=$(udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}')
 		if [ "$wwn" = "$drive_wwn" ]; then
 			base_name="$(basename -- ${dev})"
 			drive_list+=("$base_name")
-			host_list+=(`readlink /sys/block/$base_name | awk -F'/' '{print $6}'`)
+			host_list+=( $(readlink "/sys/block/$base_name" | awk -F'/' '{print $6}') )
 		fi
 	fi
 done
diff --git a/test/shell/idm_ilm_failure.sh b/test/shell/idm_ilm_failure.sh
index 4b48476fe..6b8e591c1 100644
--- a/test/shell/idm_ilm_failure.sh
+++ b/test/shell/idm_ilm_failure.sh
@@ -21,9 +21,9 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 3
 aux extend_filter_LVMTEST
 
-DRIVE1=`dmsetup deps -o devname $dev1 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
-DRIVE2=`dmsetup deps -o devname $dev2 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
-DRIVE3=`dmsetup deps -o devname $dev3 | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//'`
+DRIVE1=$(dmsetup deps -o devname "$dev1" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
+DRIVE2=$(dmsetup deps -o devname "$dev2" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
+DRIVE3=$(dmsetup deps -o devname "$dev3" | awk '{gsub(/[()]/,""); print $4;}' | sed 's/[0-9]*$//')
 
 if [ "$DRIVE1" = "$DRIVE2" ] || [ "$DRIVE1" = "$DRIVE3" ] || [ "$DRIVE2" = "$DRIVE3" ]; then
 	die "Need to pass three different drives!?"
diff --git a/test/shell/large-physical-sector-size.sh b/test/shell/large-physical-sector-size.sh
index d076d862c..b60341889 100644
--- a/test/shell/large-physical-sector-size.sh
+++ b/test/shell/large-physical-sector-size.sh
@@ -32,7 +32,7 @@ get_devs
 
 vgcreate $SHARED $vg "$dev1"
 
-for i in `seq 1 40`; do lvcreate -an -l1 $vg; done;
+for i in $(seq 1 40); do lvcreate -an -l1 $vg; done;
 
 lvs $vg
 
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index fd7a45ecd..4aea4967f 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -22,8 +22,8 @@ get_devs
 vgcreate $SHARED -s 64k "$vg" "${DEVICES[@]}"
 
 # Use zero devices for big mirror legs
-aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
-aux zero_dev "$dev3" $(get first_extent_sector "$dev3"):
+aux zero_dev "$dev2" "$(get first_extent_sector "$dev2"):"
+aux zero_dev "$dev3" "$(get first_extent_sector "$dev3"):"
 
 lvcreate -aey -L90 --type mirror --corelog --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2"
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 160b086f6..17ed033b2 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -316,8 +316,8 @@ fi
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 #
-aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
-aux zero_dev "$dev4" $(get first_extent_sector "$dev4"):
+aux zero_dev "$dev2" "$(get first_extent_sector "$dev2"):"
+aux zero_dev "$dev4" "$(get first_extent_sector "$dev4"):"
 
 SHOULD=
 aux throttle_dm_mirror || SHOULD=should
diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 49cfbb1f9..851a6117e 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -69,7 +69,7 @@ lvconvert --repair $vg/$lv1
 lvs -a $vg
 check lv_exists $vg ${lv1}_meta0
 
-eval $(lvs -S 'name=~_pmspare' -a --config 'report/mark_hidden_devices=0' -o name --noheading --nameprefixes $vg)
+eval "$(lvs -S 'name=~_pmspare' -a --config 'report/mark_hidden_devices=0' -o name --noheading --nameprefixes $vg)"
 lvremove -f --yes "$vg/$LVM2_LV_NAME"
 
 # check --repair without creation of _pmspare device
@@ -77,7 +77,7 @@ lvconvert --repair --poolmetadataspare n $vg/$lv1
 check lv_exists $vg ${lv1}_meta1
 
 # check no _pmspare has been created in previous --repair
-test "0" = $(lvs -S 'name=~_pmspare' -a -o name --noheading --nameprefixes $vg | wc -l)
+test "0" = "$(lvs -S 'name=~_pmspare' -a -o name --noheading --nameprefixes $vg | wc -l)"
 
 
 aux disable_dev "$dev2"
diff --git a/test/shell/lvconvert-snapshot-thin.sh b/test/shell/lvconvert-snapshot-thin.sh
index f5da459b3..cc4dade42 100644
--- a/test/shell/lvconvert-snapshot-thin.sh
+++ b/test/shell/lvconvert-snapshot-thin.sh
@@ -29,7 +29,7 @@ lvcreate -L1 -n cow $vg
 
 # Thin and snapshot conversion
 lvcreate -T -L1 -V10 -n th $vg/pool
-eval $(lvs -S 'name=~_pmspare' -a -o name --config 'report/mark_hidden_devices=0' --noheading --nameprefixes $vg)
+eval "$(lvs -S 'name=~_pmspare' -a -o name --config 'report/mark_hidden_devices=0' --noheading --nameprefixes $vg)"
 
 # Cannot create snapshot of pool's meta
 not lvcreate -s -L1 $vg/pool_tmeta 2>&1 | tee err
diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 87ad802c3..5a341c807 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -21,16 +21,16 @@ aux have_raid 1 15 0 && PROGRESS=1
 
 # Use smallest regionsize to save VG space
 regionsize=$(getconf PAGESIZE) # in bytes
-let pageregions=regionsize*8  # number of regions per MD bitmap page
+pageregions=$(( regionsize * 8 )) # number of regions per MD bitmap page
 
 # in KiB
-let regionsize=regionsize/1024
+regionsize=$(( regionsize / 1024 ))
 
 # in MiB
-let lvsz=pageregions*regionsize/1024
-let lvext=lvsz/8
+lvsz=$(( pageregions * regionsize / 1024 ))
+lvext=$(( lvsz / 8 ))
 
-aux prepare_pvs 2 $(($lvsz + 3 * $lvext))
+aux prepare_pvs 2 $(( lvsz + 3 *  lvext ))
 get_devs
 vgcreate -s 4k $vg ${DEVICES[@]}
 
@@ -45,12 +45,12 @@ aux zero_dev "$dev1" "${sector}:"
 aux delayzero_dev "$dev2"  0 10 "${sector}:"
 
 # Create raid1 LV consuming 1 MD bitmap page
-lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
+lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(( lvsz - lvext ))M -n $lv1 $vg
 
 lvs -a $vg
 
 not check lv_field $vg/$lv1 sync_percent "100.00"
-check lv_field $vg/$lv1 size "$(($lvsz-$lvext)).00m" $vg/$lv1
+check lv_field $vg/$lv1 size "$(( lvsz - lvext )).00m" $vg/$lv1
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 region_size "4.00k"
@@ -65,7 +65,7 @@ if [ $PROGRESS -eq 1 ]
 then
 # Even with delayed devices wre are catching races here.
 should not check lv_field $vg/$lv1 sync_percent "100.00"
-check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
+check lv_field $vg/$lv1 size "$lvsz.00m" $vg/$lv1
 fi
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
@@ -85,6 +85,6 @@ aux enable_dev "$dev2"
 
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
-check lv_field $vg/$lv1 size "$(($lvsz+$lvext)).00m" $vg/$lv1
+check lv_field $vg/$lv1 size "$(( lvsz + lvext )).00m" $vg/$lv1
 
 vgremove -ff $vg
diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index ee350b1c6..398c96420 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -52,7 +52,7 @@ vgcreate --shared $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 
-PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
 pvscan --cache -aay "$dev1"
 not ls "$RUNDIR/lvm/pvs_online/$PVID1"
 pvscan --cache -aay
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 038a88485..17f79eb59 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -264,11 +264,11 @@ dd if=/dev/zero of="$dev3" || true
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
-PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
 echo $PVID1
-PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=$(pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}')
 echo $PVID2
-PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
 echo $PVID3
 
 pvs
diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index a7efdead0..54fbd8f98 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -28,7 +28,7 @@ pvcreate --pvmetadatacopies 2 "$dev1"
 
 vgcreate $SHARED "$vg" "$dev1"
 
-for i in `seq 1 50`; do lvcreate -l1 -an $vg; done
+for i in $(seq 1 50); do lvcreate -l1 -an $vg; done
 
 # Check metadata copies are separated by zeroes in the first mda
 
@@ -53,8 +53,6 @@ cat meta.zeros
 
 grep '0000 0000 0000 0000 0000 0000 0000 0000' meta.zeros > meta.count
 
-cat meta.count | wc -l
-
 # wc will often equal 51, but some natural variability in
 # metadata locations/content mean that some lines do not
 # require a full line of zero padding, and will not match
@@ -63,7 +61,7 @@ cat meta.count | wc -l
 # random choice, and this isn't a perfect way to test for
 # zero padding.)
 
-test "$(cat meta.count | wc -l)" -gt 20
+test "$(wc -l < meta.count)" -gt 20
 
 rm meta.raw meta.txt meta.vg meta.zeros meta.count
 
@@ -85,8 +83,6 @@ cat meta.zeros
 
 grep '0000 0000 0000 0000 0000 0000 0000 0000' meta.zeros > meta.count
 
-cat meta.count | wc -l
-
-test "$(cat meta.count | wc -l)" -gt 20
+test "$(wc -l < meta.count)" -gt 20
 
 vgremove -ff $vg
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 1019bd3f3..8d525ca51 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -44,11 +44,11 @@ lv_devices_() {
 }
 
 lv_mirror_log_() {
-	get lv_field "$1" mirror_log | tr -d []
+	get lv_field "$1" mirror_log | tr -d '[]'
 }
 
 lv_convert_lv_() {
-	get lv_field "$1" convert_lv | tr -d []
+	get lv_field "$1" convert_lv | tr -d '[]'
 }
 
 # ---------------------------------------------------------------------
diff --git a/test/shell/multi_hosts_lv_ex_timeout_hosta.sh b/test/shell/multi_hosts_lv_ex_timeout_hosta.sh
index c8be91ee3..d78b6d9c1 100644
--- a/test/shell/multi_hosts_lv_ex_timeout_hosta.sh
+++ b/test/shell/multi_hosts_lv_ex_timeout_hosta.sh
@@ -39,14 +39,14 @@ for d in "${BLKDEVS[@]}"; do
 	dd if=/dev/zero of="$d" bs=32k count=1
 	wipefs -a "$d" 2>/dev/null || true
 
-	sg_dev=`sg_map26 ${d}`
+	sg_dev=$(sg_map26 "$d")
 	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
 		echo "Cleanup IDM context for drive ${d} ($sg_dev)"
-		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -r 512 -o idm_tmp_data.bin "$sg_dev" \
 			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
-		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -s 512 -i idm_tmp_data.bin "$sg_dev" \
 			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
-		rm /tmp/idm_tmp_data.bin
+		rm idm_tmp_data.bin
 	fi
 done
 
@@ -57,14 +57,14 @@ for i in $(seq 1 ${#BLKDEVS[@]}); do
 done
 
 for d in "${BLKDEVS[@]}"; do
-	drive_wwn=`udevadm info $d | awk -F= '/E: ID_WWN=/ {print $2}'`
+	drive_wwn=$(udevadm info "$d" | awk -F= '/E: ID_WWN=/ {print $2}')
 	for dev in /dev/*; do
 		if [ -b "$dev" ] && [[ ! "$dev" =~ [0-9] ]]; then
-			wwn=`udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}'`
+			wwn=$(udevadm info "$dev" | awk -F= '/E: ID_WWN=/ {print $2}')
 			if [ "$wwn" = "$drive_wwn" ]; then
 				base_name="$(basename -- ${dev})"
 				drive_list+=("$base_name")
-				host_list+=(`readlink /sys/block/$base_name | awk -F'/' '{print $6}'`)
+				host_list+=( $(readlink "/sys/block/$base_name" | awk -F'/' '{print $6}') )
 			fi
 		fi
 	done
diff --git a/test/shell/multi_hosts_lv_hosta.sh b/test/shell/multi_hosts_lv_hosta.sh
index 68404d251..2ae2989d0 100644
--- a/test/shell/multi_hosts_lv_hosta.sh
+++ b/test/shell/multi_hosts_lv_hosta.sh
@@ -42,14 +42,14 @@ for d in "${BLKDEVS[@]}"; do
 	dd if=/dev/zero of="$d" bs=32k count=1
 	wipefs -a "$d" 2>/dev/null || true
 
-	sg_dev=`sg_map26 ${d}`
+	sg_dev=$(sg_map26 "$d")
 	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
 		echo "Cleanup IDM context for drive ${d} ($sg_dev)"
-		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -r 512 -o idm_tmp_data.bin "$sg_dev" \
 			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
-		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -s 512 -i idm_tmp_data.bin "$sg_dev" \
 			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
-		rm /tmp/idm_tmp_data.bin
+		rm idm_tmp_data.bin
 	fi
 done
 
diff --git a/test/shell/multi_hosts_lv_sh_timeout_hosta.sh b/test/shell/multi_hosts_lv_sh_timeout_hosta.sh
index 6b24f9290..798f051e3 100644
--- a/test/shell/multi_hosts_lv_sh_timeout_hosta.sh
+++ b/test/shell/multi_hosts_lv_sh_timeout_hosta.sh
@@ -39,14 +39,14 @@ for d in "${BLKDEVS[@]}"; do
 	dd if=/dev/zero of="$d" bs=32k count=1
 	wipefs -a "$d" 2>/dev/null || true
 
-	sg_dev=`sg_map26 ${d}`
+	sg_dev=$(sg_map26 "$d")
 	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
 		echo "Cleanup IDM context for drive ${d} ($sg_dev)"
-		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -r 512 -o idm_tmp_data.bin "$sg_dev" \
 			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
-		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+		sg_raw -v -s 512 -i idm_tmp_data.bin "$sg_dev" \
 			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
-		rm /tmp/idm_tmp_data.bin
+		rm idm_tmp_data.bin
 	fi
 done
 
@@ -57,21 +57,21 @@ for i in $(seq 1 ${#BLKDEVS[@]}); do
 done
 
 for d in "${BLKDEVS[@]}"; do
-	drive_wwn=`udevadm info $d | awk -F= '/E: ID_WWN=/ {print $2}'`
+	drive_wwn=$(udevadm info "$d" | awk -F= '/E: ID_WWN=/ {print $2}')
 	for dev in /dev/*; do
 		if [ -b "$dev" ] && [[ ! "$dev" =~ [0-9] ]]; then
-			wwn=`udevadm info "${dev}" | awk -F= '/E: ID_WWN=/ {print $2}'`
+			wwn=$(udevadm info "$dev" | awk -F= '/E: ID_WWN=/ {print $2}')
 			if [ "$wwn" = "$drive_wwn" ]; then
 				base_name="$(basename -- ${dev})"
 				drive_list+=("$base_name")
-				host_list+=(`readlink /sys/block/$base_name | awk -F'/' '{print $6}'`)
+				host_list+=( $(readlink "/sys/block/$base_name" | awk -F'/' '{print $6}') )
 			fi
 		fi
 	done
 done
 
 for d in "${drive_list[@]}"; do
-	[ -f /sys/block/$d/device/delete ] && echo 1 > /sys/block/$d/device/delete
+	[ -f "/sys/block/$d/device/delete" ] && echo 1 > "/sys/block/$d/device/delete"
 done
 
 sleep 100
@@ -83,5 +83,5 @@ done
 
 # Rescan drives so can probe the deleted drives and join back them
 for h in "${host_list[@]}"; do
-	[ -f /sys/class/scsi_host/${h}/scan ] && echo "- - -" > /sys/class/scsi_host/${h}/scan
+	[ -f "/sys/class/scsi_host/$h/scan" ] && echo "- - -" > "/sys/class/scsi_host/$h/scan"
 done
diff --git a/test/shell/open-file-limit.sh b/test/shell/open-file-limit.sh
index 6bd632de2..8e047057e 100644
--- a/test/shell/open-file-limit.sh
+++ b/test/shell/open-file-limit.sh
@@ -27,7 +27,7 @@ for i in $(seq 1 200); do
 done
 
 pvs > out
-test "$(grep pv out | wc -l)" -eq 200
+test "$(grep -c pv out)" -eq 200
 
 # Set the soft limit to 100 fd's when 200 PVs need to be open.
 # This requires lvm to increase its soft limit in order to
@@ -38,11 +38,11 @@ aux lvmconf 'devices/obtain_device_list_from_udev = 0'
 
 prlimit --nofile=100: pvs > out
 
-test "$(grep pv out | wc -l)" -eq 200
+test "$(grep -c pv out)" -eq 200
 
 aux lvmconf 'devices/obtain_device_list_from_udev = 1'
 
 prlimit --nofile=100: pvs > out
 
-test "$(grep pv out | wc -l)" -eq 200
+test "$(grep -c pv out)" -eq 200
 
diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
index 0a794da68..ac26285e2 100644
--- a/test/shell/pvck-repair.sh
+++ b/test/shell/pvck-repair.sh
@@ -404,8 +404,8 @@ lvcreate -l1 -an $vg
 _clear_devs "$dev1" "$dev2"
 vgcreate $vg "$dev1"
 pvck --dump headers "$dev1" || true
-UUID1=`pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}'`
-echo $UUID1
+UUID1=$(pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}')
+echo "$UUID1"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 pvck --dump headers "$dev1" || true
 pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
diff --git a/test/shell/report-format.sh b/test/shell/report-format.sh
index 399ed0337..14b53edfb 100644
--- a/test/shell/report-format.sh
+++ b/test/shell/report-format.sh
@@ -34,9 +34,9 @@ lvs -o name,kernel_major,data_percent,tags | tee "$OUT_LOG_FILE"
 #  lvol2   -1        lv_tag1
 #  lvol3  253        lv_tag1,lv_tag2,lv_tag3
 #
-grep -E "^[[:space:]]*$lv1[[:space:]]*[[:digit:]]+[[:space:]]*[[:digit:]]+.[[:digit:]]+[[:space:]]*\$" out
-grep -E "^[[:space:]]*$lv2[[:space:]]*-1[[:space:]]*lv_tag1[[:space:]]*\$" out
-grep -E "^[[:space:]]*$lv3[[:space:]]*[[:digit:]]+[[:space:]]*lv_tag1,lv_tag2,lv_tag3\$" out
+grep -E "^[[:space:]]*${lv1}[[:space:]]*[[:digit:]]+[[:space:]]*[[:digit:]]+.[[:digit:]]+[[:space:]]*\$" out
+grep -E "^[[:space:]]*${lv2}[[:space:]]*-1[[:space:]]*lv_tag1[[:space:]]*\$" out
+grep -E "^[[:space:]]*${lv3}[[:space:]]*[[:digit:]]+[[:space:]]*lv_tag1,lv_tag2,lv_tag3\$" out
 
 
 aux lvmconf "report/output_format = json"
diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index eb6984078..e9fda5797 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -336,7 +336,7 @@ ls "$RUNDIR/lvm/vgs_online/$vg8"
 journalctl -u lvm-activate-$vg8 | tee out || true
 grep "now active" out
 
-num_active=$(lvs $vg8 --noheading -o active | grep active | wc -l)
+num_active=$(lvs $vg8 --noheading -o active | grep -c active)
 
 test $num_active -eq $TEST_DEVS
 
@@ -375,7 +375,7 @@ wait_md_create "$mddev"
 vgcreate $vg9 "$mddev"
 lvmdevices --adddev "$mddev" || true
 
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVIDMD=$(pvs "$mddev" --noheading -o uuid | tr -d - | awk '{print $1}')
 BDEVMD=$(basename "$mddev")
 
 lvcreate -l1 -an -n $lv1 $vg9
@@ -419,7 +419,7 @@ lvcreate -l1 -an -n $lv1 $vg10 "$dev1"
 
 PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
 # PVID with dashes
-OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID1=$(pvs "$dev1" --noheading -o uuid | awk '{print $1}')
 
 udevadm trigger --settle -c add /sys/block/$BDEV1
 
diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index a1fc3a427..dab7f5ad7 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -86,15 +86,15 @@ _clear_online_files
 pvscan --cache "$bd1"
 pvscan --cache "$bd2"
 strace -e io_submit vgchange -aay --autoactivation event $vg1 2>&1|tee trace.out
-test "$(grep io_submit trace.out | wc -l)" -eq 3
+test "$(grep -c io_submit trace.out)" -eq 3
 rm trace.out
 
 strace -e io_submit pvscan --cache "$bd3" 2>&1|tee trace.out
-test "$(grep io_submit trace.out | wc -l)" -eq 1
+test "$(grep -c io_submit trace.out)" -eq 1
 rm trace.out
 
 strace -e io_submit vgchange -aay --autoactivation event $vg2 2>&1|tee trace.out
-test "$(grep io_submit trace.out | wc -l)" -eq 2
+test "$(grep -c io_submit trace.out)" -eq 2
 rm trace.out
 fi
 

