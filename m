From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:13 +0000 (UTC)
Subject: master - tests: add quotes around device paths
Message-ID: <20140321213213.7E61B60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de5683d8d96613f37a21ed37695a5399c03a9257
Commit:        de5683d8d96613f37a21ed37695a5399c03a9257
Parent:        01efb20bdb78a2f49c72951cedca6ffa11a6ba09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 23:32:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:27 2014 +0100

tests: add quotes around device paths

---
 test/shell/covercmd.sh                       |    8 +++---
 test/shell/listings.sh                       |    8 +++---
 test/shell/lvchange-raid.sh                  |    4 +-
 test/shell/lvconvert-raid.sh                 |    4 +-
 test/shell/lvcreate-raid.sh                  |   24 +++++++++---------
 test/shell/lvcreate-raid10.sh                |    4 +-
 test/shell/lvmetad-ambiguous.sh              |    8 +++---
 test/shell/lvmetad-lvm1.sh                   |    8 +++---
 test/shell/lvmetad-pvscan-filter.sh          |   10 ++++----
 test/shell/lvmetad-pvscan-nomda.sh           |   18 +++++++-------
 test/shell/lvmetad-restart.sh                |    2 +-
 test/shell/lvmetad-test.sh                   |    4 +-
 test/shell/lvmetad-warning.sh                |    2 +-
 test/shell/lvresize-raid.sh                  |    2 +-
 test/shell/mda-rollback.sh                   |    6 ++--
 test/shell/mirror-names.sh                   |    2 +-
 test/shell/mirror-vgreduce-removemissing.sh  |    8 +++---
 test/shell/nomda-restoremissing.sh           |    2 +-
 test/shell/orphan-ondisk.sh                  |    2 +-
 test/shell/process-each-duplicate-vgnames.sh |   32 +++++++++++++-------------
 test/shell/pvcreate-ff.sh                    |    8 +++---
 test/shell/pvcreate-operation.sh             |   12 +++++-----
 test/shell/stray-device-node.sh              |    4 +-
 test/shell/vg-name-from-env.sh               |    8 +++---
 test/shell/vgimportclone.sh                  |    8 +++---
 25 files changed, 99 insertions(+), 99 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index ca45c2f..ffa48f0 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -104,19 +104,19 @@ not lvrename $vg  $vg/$lv-rename $vg/$lv
 
 #test vgdisplay -A to select only active VGs
 # all LVs active - VG considered active
-pvcreate -f $dev1 $dev2 $dev3
+pvcreate -f "$dev1" "$dev2" "$dev3"
 
-vgcreate $vg1 $dev1
+vgcreate $vg1 "$dev1"
 lvcreate -l1 $vg1
 lvcreate -l1 $vg1
 
 # at least one LV active - VG considered active
-vgcreate $vg2 $dev2
+vgcreate $vg2 "$dev2"
 lvcreate -l1 $vg2
 lvcreate -l1 -an -Zn $vg2
 
 # no LVs active - VG considered inactive
-vgcreate $vg3 $dev3
+vgcreate $vg3 "$dev3"
 lvcreate -l1 -an -Zn $vg3
 lvcreate -l1 -an -Zn $vg3
 
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index bb72055..42c6ba5 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -31,7 +31,7 @@ test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l)
 
 vgcreate $vg $(cat DEVICES)
 
-check pv_field $dev1 pv_uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
+check pv_field "$dev1" pv_uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
 pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
@@ -52,14 +52,14 @@ lvcreate -l4 -s -n $lv2 $vg/$lv1
 test $(lvs --noheadings $vg | wc -l) -eq 2
 # should lvs -a display cow && real devices? (it doesn't)
 test $(lvs -a --noheadings $vg | wc -l)  -eq 2
-dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
 lvcreate -aey -l4 --type mirror -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
-dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+dmsetup ls|grep "$PREFIX"|grep -v "LVMTEST.*pv."
 
 #COMM vgs with options from pvs still treats arguments as VGs (bz193543)
 vgs -o pv_name,vg_name $vg
@@ -70,7 +70,7 @@ pvdisplay $(cat DEVICES) >out
 pvdisplay --maps $(cat DEVICES) >out2
 not diff out out2
 
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 pvs -o +pv_uuid | grep BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
 
 vgremove -ff $vg
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 0807fff..afa2431 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -144,7 +144,7 @@ run_syncaction_check() {
 	size=$(get lv_field $vg/${lv}_rimage_1 size -a --units 1k)
 	size=$((${size%\.00k} / 2))
 
-	tmp=$(get pv_field $device mda_size --units 1k)
+	tmp=$(get pv_field "$device" mda_size --units 1k)
 	seek=${tmp%\.00k} # Jump over MDA
 
 	tmp=$(get lv_field $vg/${lv}_rmeta_1 size -a --units 1k)
@@ -156,7 +156,7 @@ run_syncaction_check() {
 	check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# Overwrite the last half of one of the PVs with crap
-	dd if=/dev/urandom of=$device bs=1k count=$size seek=$seek
+	dd if=/dev/urandom of="$device" bs=1k count=$size seek=$seek
 
 	if [ -n "$THIN_POSTFIX" ]; then
 		#
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 2c6a41a..01118cb 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -89,9 +89,9 @@ lvconvert -m +1 $vg/$lv1
 lvremove -ff $vg
 
 # 3-way to 2-way convert while specifying devices
-lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
-lvconvert -m1 $vg/$lv1 $dev2
+lvconvert -m1 $vg/$lv1 "$dev2"
 lvremove -ff $vg
 
 #
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 2791669..77b2347 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -109,11 +109,11 @@ should check lv_field $vg/raid6 size "72.00m"
 lvremove -ff $vg
 
 # Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg $dev1
+lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1 and equal from dev2
 # 1 meta takes 1 extent
 # 1 image = 18 extents = 9.00m = lv_size
-lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg $dev1 $dev2
+lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg "$dev1" "$dev2"
 check lv_field $vg/raid1 size "9.00m"
 # Ensure image size is the same as the RAID1 size
 check lv_field $vg/raid1 size `lvs --noheadings -o size $vg/raid1_rimage_0`
@@ -122,7 +122,7 @@ check pv_field "$dev2" pv_free `lvs --noheadings -o size $vg/lv`
 lvremove -ff $vg
 
 # Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg $dev1
+lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1 and equal amount from the rest
 # 1 meta takes 1 extent
 # 1 image = 18 extents = 9.00m
@@ -134,7 +134,7 @@ check pv_field "$dev6" pv_free `lvs --noheadings -o size $vg/lv`
 lvremove -ff $vg
 
 # Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg $dev1
+lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1, an equal amount
 # from 2 more devs, and all extents from 3 additional devs
 # 1 meta takes 1 extent
@@ -146,7 +146,7 @@ lvremove -ff $vg
 
 # Let's do some stripe tests too
 # Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg $dev1
+lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1 and an equal amount from rest
 # 1 image = 19 extents
 # 6 images = 114 extents = 57.00m = lv_size
@@ -155,7 +155,7 @@ check lv_field $vg/stripe size "57.00m"
 lvremove -ff $vg
 
 # Eat 18 of 37 extents from dev1, leaving 19
-lvcreate -l 18 -n lv $vg $dev1
+lvcreate -l 18 -n lv $vg "$dev1"
 # Using 100% free should take the rest of dev1, an equal amount from
 #  one more dev, and all of the remaining 4
 # 1 image = 19+37+37 extents
@@ -168,16 +168,16 @@ lvremove -ff $vg
 #######################################################
 
 # Not enough drives
-not lvcreate --type raid1 -l1 $vg $dev1
-not lvcreate --type raid5 -l2 $vg $dev1 $dev2
-not lvcreate --type raid6 -l3 $vg $dev1 $dev2 $dev3 $dev4
+not lvcreate --type raid1 -l1 $vg "$dev1"
+not lvcreate --type raid5 -l2 $vg "$dev1" "$dev2"
+not lvcreate --type raid6 -l3 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 # Implicit count comes from #PVs given (always 2 for mirror though)
-lvcreate --type raid1 -l1 -n raid1 $vg $dev1 $dev2
+lvcreate --type raid1 -l1 -n raid1 $vg "$dev1" "$dev2"
 lv_devices $vg raid1 2
-lvcreate --type raid5 -l2 -n raid5 $vg $dev1 $dev2 $dev3
+lvcreate --type raid5 -l2 -n raid5 $vg "$dev1" "$dev2" "$dev3"
 lv_devices $vg raid5 3
-lvcreate --type raid6 -l3 -n raid6 $vg $dev1 $dev2 $dev3 $dev4 $dev5
+lvcreate --type raid6 -l3 -n raid6 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lv_devices $vg raid6 5
 lvremove -ff $vg
 
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 68a61f7..7ce8100 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -65,10 +65,10 @@ lvremove -ff $vg
 #######################################################
 
 # Not enough drives
-not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
+not lvcreate --type raid10 -l2 $vg "$dev1" "$dev2" "$dev3"
 
 # Implicit count comes from #PVs given (always 2-way mirror)
-lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
+lvcreate --type raid10 -l2 -n raid10 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lv_devices $vg raid10 4
 lvremove -ff $vg
 
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 455aa5d..6ff055a 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -24,11 +24,11 @@ dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv1 ${PREFIX}pv1.table
 aux finish_udev_transaction
 
 # re-scan them
-pvscan --cache $dev1
-pvscan --cache $dev2
+pvscan --cache "$dev1"
+pvscan --cache "$dev2"
 
 # expect both to be there
 pvs | tee pvs.txt
-grep $dev1 pvs.txt
-grep $dev2 pvs.txt
+grep "$dev1" pvs.txt
+grep "$dev2" pvs.txt
 
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 043750e..814134c 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -13,10 +13,10 @@
 
 test -e LOCAL_LVMETAD || skip
 aux prepare_devs 2
-pvcreate --metadatatype 1 $dev1
+pvcreate --metadatatype 1 "$dev1"
 should vgscan --cache
-pvs | should grep $dev1
-vgcreate --metadatatype 1 $vg1 $dev1
+pvs | should grep "$dev1"
+vgcreate --metadatatype 1 $vg1 "$dev1"
 should vgscan --cache
 vgs | should grep $vg1
-pvs | should grep $dev1
+pvs | should grep "$dev1"
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 6ece577..73690a0 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -18,8 +18,8 @@ aux prepare_pvs 2
 maj=$(($(stat -L --printf=0x%t "$dev2")))
 min=$(($(stat -L --printf=0x%T "$dev2")))
 
-aux hide_dev $dev2
-not pvscan --cache $dev2 2>&1 | grep "not found"
+aux hide_dev "$dev2"
+not pvscan --cache "$dev2" 2>&1 | grep "not found"
 # pvscan with --major/--minor does not fail: lvmetad needs to
 # be notified about device removal on REMOVE uevent, hence
 # this should not fail so udev does not grab a "failed" state
@@ -27,8 +27,8 @@ not pvscan --cache $dev2 2>&1 | grep "not found"
 # exactly the same command "pvscan --cache" - in case of removal,
 # this is detected by nonexistence of the device itself.
 pvscan --cache --major $maj --minor $min 2>&1 | grep "not found"
-aux unhide_dev $dev2
+aux unhide_dev "$dev2"
 
-pvscan --cache $dev2 2>&1 | not grep "not found"
+pvscan --cache "$dev2" 2>&1 | not grep "not found"
 pvscan --cache --major $maj --minor $min 2>&1 | not grep "not found"
-pvs | grep $dev2
+pvs | grep "$dev2"
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 195b8d2..04c9c6b 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -17,32 +17,32 @@ rm LOCAL_LVMETAD
 
 aux prepare_devs 2
 
-pvcreate --metadatacopies 0 $dev1
-pvcreate --metadatacopies 1 $dev2
-vgcreate $vg1 $dev1 $dev2
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n foo -l 1 -an --zero n $vg1
 
 # start lvmetad but make sure it doesn't know about $dev1 or $dev2
-aux disable_dev $dev1
-aux disable_dev $dev2
+aux disable_dev "$dev1"
+aux disable_dev "$dev2"
 aux prepare_lvmetad
 lvs
 mv LOCAL_LVMETAD XXX
-aux enable_dev $dev2
-aux enable_dev $dev1
+aux enable_dev "$dev2"
+aux enable_dev "$dev1"
 mv XXX LOCAL_LVMETAD
 
 aux lvmconf 'global/use_lvmetad = 0'
 check inactive $vg1 foo
 aux lvmconf 'global/use_lvmetad = 1'
 
-pvscan --cache $dev2 -aay
+pvscan --cache "$dev2" -aay
 
 aux lvmconf 'global/use_lvmetad = 0'
 check inactive $vg1 foo
 aux lvmconf 'global/use_lvmetad = 1'
 
-pvscan --cache $dev1 -aay
+pvscan --cache "$dev1" -aay
 
 aux lvmconf 'global/use_lvmetad = 0'
 check active $vg1 foo
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index 585d63b..6e25f8a 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -14,7 +14,7 @@
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 vgs | grep $vg1
 
 kill $(cat LOCAL_LVMETAD)
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 7e801f1..934e985 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -13,9 +13,9 @@
 
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2 --test
+vgcreate $vg1 "$dev1" "$dev2" --test
 vgs | not grep $vg1
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 vgs | grep $vg1
 
 lvcreate -n bar -l 1 $vg1 --test
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 3fc4cf5..8bb01d1 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -14,7 +14,7 @@
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 kill $(cat LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 9b9218d..bc8b36f 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -50,7 +50,7 @@ done
 
 # Bug 1005434
 # Ensure extend is contiguous
-lvcreate --type raid4 -l 2 -i 2 -n $lv1 $vg $dev4 $dev5 $dev6
+lvcreate --type raid4 -l 2 -i 2 -n $lv1 $vg "$dev4" "$dev5" "$dev6"
 lvextend -l +2 --alloc contiguous $vg/$lv1
 check lv_tree_on $vg $lv1 "$dev4" "$dev5" "$dev6"
 
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index d47eb8a..aebbfb6 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -15,12 +15,12 @@ aux prepare_devs 3
 
 vgcreate --metadatasize 128k $vg1 "$dev1" "$dev2" "$dev3"
 
-vgreduce $vg1 $dev1
+vgreduce $vg1 "$dev1"
 dd if="$dev1" of=badmda bs=256K count=1
-vgextend $vg1 $dev1
+vgextend $vg1 "$dev1"
 
 dd if=badmda of="$dev1" bs=256K count=1
 
 # dev1 is part of vg1 (as witnessed by metadata on dev2 and dev3), but its mda
 # was corrupt (written over by a backup from time dev1 was an orphan)
-check pv_field $dev1 vg_name $vg1
+check pv_field "$dev1" vg_name $vg1
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index de70f43..f5d1322 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -25,7 +25,7 @@ lv_devices_() {
 	local devs=$(get lv_field $lv devices -a | sed 's/([0-9]*)//g; s/ //g; s/,/ /g')
 
 	for d in $devs; do
-		(echo $devices | grep $d) || return 1
+		(echo "$devices" | grep $d) || return 1
 		devices=$(echo $devices | sed "s/$d//")
 	done
 
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 05a8acd..340a333 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -126,8 +126,8 @@ check_and_cleanup_lvs_
 #COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
 lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":$BLOCKS
-mimages_are_on_ $lv1 $dev1 $dev2
-mirrorlog_is_on_ $lv1 $dev3
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mirrorlog_is_on_ $lv1 "$dev3"
 aux disable_dev "$dev2"
 vgreduce --removemissing --force $vg
 lv_is_linear_ $lv1
@@ -234,7 +234,7 @@ test_3way_mirror_plus_1_fail_3_()
 	lvs -a -o+devices $vg
 	eval local dev=\$dev$n
 	check linear $vg $lv1
-        check lv_on $vg $lv1 $dev
+        check lv_on $vg $lv1 "$dev"
 }
 
 for n in $(seq 1 4); do
@@ -287,7 +287,7 @@ test_2way_mirror_plus_2_fail_3_()
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	eval local dev=\$dev$n
-	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
+	mimages_are_on_ $lv1 "$dev" || lv_is_on_ $lv1 "$dev"
 	not mirrorlog_is_on_ $lv1 "$dev5"
 }
 
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index eb2e624..3dcd41e 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 3
 
-pvchange --metadataignore y $dev1
+pvchange --metadataignore y "$dev1"
 
 lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 2a820d6..266d74b 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -12,4 +12,4 @@
 . lib/test
 
 aux prepare_vg 2
-vgreduce $vg $dev1 2>&1 | not grep -i 'parse error'
+vgreduce $vg "$dev1" 2>&1 | not grep -i 'parse error'
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 6eeaa6f..5138d22 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -11,29 +11,29 @@ test_description='Test vgs with duplicate vg names'
 
 aux prepare_devs 2
 
-pvcreate $dev1
-pvcreate $dev2
+pvcreate "$dev1"
+pvcreate "$dev2"
 
-aux disable_dev $dev1
-aux disable_dev $dev2
+aux disable_dev "$dev1"
+aux disable_dev "$dev2"
 
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 vgscan
-vgcreate $vg1 $dev1
+vgcreate $vg1 "$dev1"
 UUID1=$(vgs --noheading -o vg_uuid $vg1)
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 
-aux enable_dev $dev2
+aux enable_dev "$dev2"
 vgscan
-vgcreate $vg1 $dev2
+vgcreate $vg1 "$dev2"
 UUID2=$(vgs --noheading -o vg_uuid $vg1)
 
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 # need vgscan after enabling/disabling devs
 # so that the next commands properly see them
 vgscan
-pvs $dev1
-pvs $dev2
+pvs "$dev1"
+pvs "$dev2"
 
 vgs -o+vg_uuid >err
 cat err
@@ -44,19 +44,19 @@ grep $UUID2 err
 # vgs --noheading -o vg_uuid $vg1 >err
 # grep $UUID1 err
 
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 vgs -o+vg_uuid >err
 cat err
 grep $UUID1 err
 not grep $UUID2 err
-aux enable_dev $dev2
+aux enable_dev "$dev2"
 vgscan
 
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 vgs -o+vg_uuid >err
 cat err
 grep $UUID2 err
 not grep $UUID1 err
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 vgscan
 
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index 38284af..72caf63 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -12,8 +12,8 @@
 . lib/test
 
 aux prepare_devs 2
-pvcreate $dev1
-vgcreate foo $dev1
-pvcreate -ff -y $dev1
+pvcreate "$dev1"
+vgcreate foo "$dev1"
+pvcreate -ff -y "$dev1"
 vgs
-vgcreate foo $dev1
+vgcreate foo "$dev1"
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index b885ed2..4a5c42a 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -21,11 +21,11 @@ do
 	if mke2fs "$dev1"; then
 		mount "$dev1" mnt
 		not pvcreate -M$mdatype "$dev1" 2>err
-		grep "Can't open "$dev1" exclusively.  Mounted filesystem?" err
+		grep "Can't open $dev1 exclusively.  Mounted filesystem?" err
 		umount "$dev1"
 		# wipe the filesystem signature for next
 		# pvcreate to not issue any prompts
-		dd if=/dev/zero of=$dev1 bs=1K count=2
+		dd if=/dev/zero of="$dev1" bs=1K count=2
 	fi
 
 # pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)
@@ -116,13 +116,13 @@ not pvcreate --uuid $uuid2 --restorefile $backupfile "$dev2"
 
 # vgcfgrestore of a VG containing a PV with zero PEs (bz #820116)
 # (use case: one PV in a VG used solely to keep metadata)
-size_mb=$(($(blockdev --getsz $dev1) / 2048))
-pvcreate --metadatasize $size_mb $dev1
-vgcreate $vg1 $dev1
+size_mb=$(($(blockdev --getsz "$dev1") / 2048))
+pvcreate --metadatasize $size_mb "$dev1"
+vgcreate $vg1 "$dev1"
 vgcfgbackup -f $backupfile
 vgcfgrestore -f $backupfile $vg1
 vgremove -f $vg1
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 # pvcreate rejects non-existent uuid given with restorefile
 not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 70677a7..8e67caa 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -12,9 +12,9 @@
 . lib/test
 
 aux prepare_devs 3
-cp -r $dev1 $DM_DEV_DIR/stray
+cp -r "$dev1" "$DM_DEV_DIR/stray"
 
-vgcreate $vg $dev1 $dev2 $dev3
+vgcreate $vg $(cat DEVICES)
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 aux disable_dev "$dev1"
 vgreduce --removemissing --force $vg
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index dedbfd6..c399bb6 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -11,11 +11,11 @@ test_description='Test the vg name for an lv from env var'
 
 aux prepare_devs 2
 
-pvcreate $dev1
-pvcreate $dev2
+pvcreate "$dev1"
+pvcreate "$dev2"
 
-vgcreate $vg1 $dev1
-vgcreate $vg2 $dev2
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
 
 export LVM_VG_NAME=$vg1
 
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index cf85518..f2977c9 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -21,13 +21,13 @@ dd if="$dev1" of="$dev2" bs=256K count=1
 aux notify_lvmetad "$dev2"
 
 # Verify pvs works on each device to give us vgname
-aux hide_dev $dev2
+aux hide_dev "$dev2"
 check pv_field "$dev1" vg_name $vg1
-aux unhide_dev $dev2
+aux unhide_dev "$dev2"
 
-aux hide_dev $dev1
+aux hide_dev "$dev1"
 check pv_field "$dev2" vg_name $vg1
-aux unhide_dev $dev1
+aux unhide_dev "$dev1"
 
 # Import the cloned PV to a new VG
 vgimportclone --basevgname $vg2 "$dev2"


