From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:46 +0000 (GMT)
Subject: dev-next - tests: bash quotes
Message-ID: <20210331214946.7C5163858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ddbc4c5cdbef0cc57b79c164b22b34c0bc6a27a
Commit:        0ddbc4c5cdbef0cc57b79c164b22b34c0bc6a27a
Parent:        8a550fa3e8747fe01517c1c4c1d81e9406d000ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 28 01:09:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 28 11:39:58 2021 +0200

tests: bash quotes

---
 test/shell/devicesfile-basic.sh     | 637 ++++++++++++++++++------------------
 test/shell/devicesfile-devname.sh   | 570 ++++++++++++++++----------------
 test/shell/hints.sh                 |   4 +-
 test/shell/lvconvert-repair-raid.sh |   2 +-
 test/shell/lvdisplay-raid.sh        |  39 ++-
 test/shell/pvscan-autoactivate.sh   |   5 +-
 6 files changed, 627 insertions(+), 630 deletions(-)

diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 352f75575..8ad96e37d 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -43,8 +43,8 @@ wipe_all() {
 # The tests run with system dir of "/etc" but lvm when running
 # normally has cmd->system_dir set to "/etc/lvm".
 DFDIR="$LVM_SYSTEM_DIR/devices"
-mkdir -p $DFDIR || true
-DF=$DFDIR/system.devices
+mkdir -p "$DFDIR" || true
+DF="$DFDIR/system.devices"
 
 #
 # Test with use_devicesfile=0 (no devices file is being applied by default)
@@ -53,268 +53,268 @@ DF=$DFDIR/system.devices
 aux lvmconf 'devices/use_devicesfile = 0'
 
 wipe_all
-rm -f $DF
-pvcreate $dev1
-not ls $DF
+rm -f "$DF"
+pvcreate "$dev1"
+not ls "$DF"
 
 wipe_all
-rm -f $DF
-vgcreate $vg1 $dev1
-not ls $DF
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+not ls "$DF"
 
 wipe_all
-rm -f $DF
+rm -f "$DF"
 
 # create one VG in a non-system devices file
-vgcreate --devicesfile test.devices $vg1 $dev1
-vgextend --devicesfile test.devices $vg1 $dev2
-cat $DFDIR/test.devices
-grep $dev1 $DFDIR/test.devices
-grep $dev2 $DFDIR/test.devices
-not ls $DFDIR/system.devices
+vgcreate --devicesfile test.devices $vg1 "$dev1"
+vgextend --devicesfile test.devices $vg1 "$dev2"
+cat "$DFDIR/test.devices"
+grep "$dev1" "$DFDIR/test.devices"
+grep "$dev2" "$DFDIR/test.devices"
+not ls "$DFDIR/system.devices"
 
 # create two VGs outside the special devices file
-vgcreate $vg2 $dev3 $dev4
-vgcreate $vg3 $dev5 $dev6
-not grep $dev3 $DFDIR/test.devices
-not grep $dev5 $DFDIR/test.devices
-not ls $DFDIR/system.devices
-
-PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID4=`pvs $dev4 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID5=`pvs $dev5 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID6=`pvs $dev6 --noheading -o uuid | tr -d - | awk '{print $1}'`
+vgcreate $vg2 "$dev3" "$dev4"
+vgcreate $vg3 "$dev5" "$dev6"
+not grep "$dev3" "$DFDIR/test.devices"
+not grep "$dev5" "$DFDIR/test.devices"
+not ls "$DFDIR/system.devices"
+
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID5=`pvs "$dev5" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID6=`pvs "$dev6" --noheading -o uuid | tr -d - | awk '{print $1}'`
 
 lvcreate -l4 -an -i2 -n $lv1 $vg1
 lvcreate -l4 -an -i2 -n $lv2 $vg2
 lvcreate -l4 -an -i2 -n $lv3 $vg3
 
-cat $DFDIR/test.devices
-grep $PVID1 $DFDIR/test.devices
-grep $PVID2 $DFDIR/test.devices
-not grep $PVID3 $DFDIR/test.devices
-not grep $PVID4 $DFDIR/test.devices
-not grep $PVID5 $DFDIR/test.devices
-not grep $PVID6 $DFDIR/test.devices
-not ls $DFDIR/system.devices
+cat "$DFDIR/test.devices"
+grep "$PVID1" "$DFDIR/test.devices"
+grep "$PVID2" "$DFDIR/test.devices"
+not grep "$PVID3" "$DFDIR/test.devices"
+not grep "$PVID4" "$DFDIR/test.devices"
+not grep "$PVID5" "$DFDIR/test.devices"
+not grep "$PVID6" "$DFDIR/test.devices"
+not ls "$DFDIR/system.devices"
 
 # verify devices file is working
 vgs --devicesfile test.devices $vg1
 not vgs --devicesfile test.devices $vg2
 
 # devicesfile and devices cannot be used together
-not vgs --devicesfile test.devices --devices $dev1,$dev1 $vg1
+not vgs --devicesfile test.devices --devices "$dev1","$dev1" $vg1
 
 # verify correct vgs are seen / not seen when devices are specified
-vgs --devices $dev1,$dev2 $vg1
-vgs --devices $dev3,$dev4 $vg2
-vgs --devices $dev5,$dev6 $vg3
-not vgs --devices $dev1,$dev2 $vg2
-not vgs --devices $dev1,$dev2 $vg3
-not vgs --devices $dev1,$dev2 $vg2
-not vgs --devices $dev5,$dev6 $vg2
-not vgs --devices $dev1,$dev2 $vg3
-not vgs --devices $dev3,$dev4 $vg3
-
-vgs --devices $dev1,$dev2 |tee out
+vgs --devices "$dev1","$dev2" $vg1
+vgs --devices "$dev3","$dev4" $vg2
+vgs --devices "$dev5","$dev6" $vg3
+not vgs --devices "$dev1","$dev2" $vg2
+not vgs --devices "$dev1","$dev2" $vg3
+not vgs --devices "$dev1","$dev2" $vg2
+not vgs --devices "$dev5","$dev6" $vg2
+not vgs --devices "$dev1","$dev2" $vg3
+not vgs --devices "$dev3","$dev4" $vg3
+
+vgs --devices "$dev1","$dev2" |tee out
 grep $vg1 out
 not grep $vg2 out
 not grep $vg3 out
-vgs --devices $dev3,$dev4 |tee out
+vgs --devices "$dev3","$dev4" |tee out
 not grep $vg1 out
 grep $vg2 out
 not grep $vg3 out
 
 # verify correct pvs are seen / not seen when devices are specified
-pvs --devices $dev1,$dev2 $dev1 $dev2
-pvs --devices $dev3,$dev4 $dev3 $dev4
-pvs --devices $dev5,$dev6 $dev5 $dev6
-not pvs --devices $dev1,$dev2 $dev3 $dev4
-not pvs --devices $dev1,$dev2 $dev5 $dev6
-not pvs --devices $dev3,$dev4 $dev1 $dev2 $dev5 $dev6
-
-pvs --devices $dev1,$dev2 |tee out
-grep $dev1 out
-grep $dev2 out
-not grep $dev3 out
-not grep $dev4 out
-not grep $dev5 out
-not grep $dev6 out
-pvs --devices $dev3,$dev4 |tee out
-not grep $dev1 out
-not grep $dev2 out
-grep $dev3 out
-grep $dev4 out
-not grep $dev5 out
-not grep $dev6 out
+pvs --devices "$dev1","$dev2" "$dev1" "$dev2"
+pvs --devices "$dev3","$dev4" "$dev3" "$dev4"
+pvs --devices "$dev5","$dev6" "$dev5" "$dev6"
+not pvs --devices "$dev1","$dev2" "$dev3" "$dev4"
+not pvs --devices "$dev1","$dev2" "$dev5" "$dev6"
+not pvs --devices "$dev3","$dev4" "$dev1" "$dev2" "$dev5" "$dev6"
+
+pvs --devices "$dev1","$dev2" |tee out
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+not grep "$dev5" out
+not grep "$dev6" out
+pvs --devices "$dev3","$dev4" |tee out
+not grep "$dev1" out
+not grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+not grep "$dev5" out
+not grep "$dev6" out
 
 # verify correct lvs are activated / not activated when devices are specified
-vgchange --devices $dev1,$dev2 -ay
+vgchange --devices "$dev1","$dev2" -ay
 check lv_field $vg1/$lv1 lv_active "active"
 check lv_field $vg2/$lv2 lv_active ""
 check lv_field $vg3/$lv3 lv_active ""
-vgchange --devices $dev1,$dev2 -an
+vgchange --devices "$dev1","$dev2" -an
 check lv_field $vg1/$lv1 lv_active ""
 
-vgchange --devices $dev3,$dev4 -ay
+vgchange --devices "$dev3","$dev4" -ay
 check lv_field $vg1/$lv1 lv_active ""
 check lv_field $vg2/$lv2 lv_active "active"
 check lv_field $vg3/$lv3 lv_active ""
-vgchange --devices $dev3,$dev4 -an
+vgchange --devices "$dev3","$dev4" -an
 check lv_field $vg2/$lv2 lv_active ""
 
 # verify devices covering multiple vgs
-vgs --devices $dev1,$dev2,$dev3,$dev4 $vg1 $vg2 |tee out
+vgs --devices "$dev1","$dev2","$dev3","$dev4" $vg1 $vg2 |tee out
 grep $vg1 out
 grep $vg2 out
 not grep $vg3 out
-vgs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 $vg1 $vg2 $vg3 |tee out
+vgs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" $vg1 $vg2 $vg3 |tee out
 grep $vg1 out
 grep $vg2 out
 grep $vg3 out
 
 # verify vgs seen when incomplete devices are specified
-vgs --devices $dev1 $vg1
-vgs --devices $dev3 $vg2
-vgs --devices $dev5 $vg3
+vgs --devices "$dev1" $vg1
+vgs --devices "$dev3" $vg2
+vgs --devices "$dev5" $vg3
 
 # incomplete vg because of --devices is the same as vg incomplete because
 # of missing device
-not lvcreate --devices $dev1 -l1 $vg1
-not lvchange --devices $dev1 -ay $vg1/$lv1
-not lvextend --devices $dev1 -l+1 $vg1/$lv1
-not vgremove --devices $dev1 $vg1
-not lvcreate --devices $dev3 -l1 $vg2
-not lvchange --devices $dev3 -ay $vg2/$lv2
-not lvextend --devices $dev3 -l+1 $vg2/$lv2
-not vgremove --devices $dev3 $vg2
+not lvcreate --devices "$dev1" -l1 $vg1
+not lvchange --devices "$dev1" -ay $vg1/$lv1
+not lvextend --devices "$dev1" -l+1 $vg1/$lv1
+not vgremove --devices "$dev1" $vg1
+not lvcreate --devices "$dev3" -l1 $vg2
+not lvchange --devices "$dev3" -ay $vg2/$lv2
+not lvextend --devices "$dev3" -l+1 $vg2/$lv2
+not vgremove --devices "$dev3" $vg2
 
 # verify various commands with --devices for vg in a devicesfile
-not lvcreate --devices $dev1,$dev2 -l1 -n $lv2 -an $vg1 $dev7
-lvcreate --devices $dev1,$dev2 -l1 -n $lv2 -an $vg1
-lvs --devices $dev1,$dev2 $vg1/$lv2
-lvextend --devices $dev1,$dev2 -l2 $vg1/$lv2
-lvchange --devices $dev1,$dev2 -ay $vg1/$lv2
-lvchange --devices $dev1,$dev2 -an $vg1/$lv2
-lvremove --devices $dev1,$dev2 $vg1/$lv2
-vgchange --devices $dev1,$dev2 -ay $vg1
-vgchange --devices $dev1,$dev2 -an $vg1
-not vgextend --devices $dev1,$dev2 $vg1 $dev7
-vgextend --devices $dev1,$dev2,$dev7 $vg1 $dev7
-vgreduce --devices $dev1,$dev2,$dev7 $vg1 $dev7
-vgexport --devices $dev1,$dev2 $vg1
-vgimport --devices $dev1,$dev2 $vg1
-not pvremove --devices $dev1,$dev2 $dev7
-not pvcreate --devices $dev1,$dev2 $dev7
-not vgcreate --devices $dev1,$dev2 $vg7 $dev7
-pvremove --devices $dev7 $dev7
-pvcreate --devices $dev7 $dev7
-vgcreate --devices $dev7 $vg7 $dev7
-vgremove --devices $dev7 $vg7
-pvremove --devices $dev7 $dev7
+not lvcreate --devices "$dev1","$dev2" -l1 -n $lv2 -an $vg1 "$dev7"
+lvcreate --devices "$dev1","$dev2" -l1 -n $lv2 -an $vg1
+lvs --devices "$dev1","$dev2" $vg1/$lv2
+lvextend --devices "$dev1","$dev2" -l2 $vg1/$lv2
+lvchange --devices "$dev1","$dev2" -ay $vg1/$lv2
+lvchange --devices "$dev1","$dev2" -an $vg1/$lv2
+lvremove --devices "$dev1","$dev2" $vg1/$lv2
+vgchange --devices "$dev1","$dev2" -ay $vg1
+vgchange --devices "$dev1","$dev2" -an $vg1
+not vgextend --devices "$dev1","$dev2" $vg1 "$dev7"
+vgextend --devices "$dev1","$dev2","$dev7" $vg1 "$dev7"
+vgreduce --devices "$dev1","$dev2","$dev7" $vg1 "$dev7"
+vgexport --devices "$dev1","$dev2" $vg1
+vgimport --devices "$dev1","$dev2" $vg1
+not pvremove --devices "$dev1","$dev2" "$dev7"
+not pvcreate --devices "$dev1","$dev2" "$dev7"
+not vgcreate --devices "$dev1","$dev2" $vg7 "$dev7"
+pvremove --devices "$dev7" "$dev7"
+pvcreate --devices "$dev7" "$dev7"
+vgcreate --devices "$dev7" $vg7 "$dev7"
+vgremove --devices "$dev7" $vg7
+pvremove --devices "$dev7" "$dev7"
 
 # verify various commands with --devices for vg not in a devicesfile
-not lvcreate --devices $dev3,$dev4 -l1 -n $lv4 -an $vg2 $dev7
-lvcreate --devices $dev3,$dev4 -l1 -n $lv4 -an $vg2
-lvs --devices $dev3,$dev4 $vg2/$lv4
-lvextend --devices $dev3,$dev4 -l2 $vg2/$lv4
-lvchange --devices $dev3,$dev4 -ay $vg2/$lv4
-lvchange --devices $dev3,$dev4 -an $vg2/$lv4
-lvremove --devices $dev3,$dev4 $vg2/$lv4
-vgchange --devices $dev3,$dev4 -ay $vg2
-vgchange --devices $dev3,$dev4 -an $vg2
-not vgextend --devices $dev3,$dev4 $vg2 $dev7
-vgextend --devices $dev3,$dev4,$dev7 $vg2 $dev7
-vgreduce --devices $dev3,$dev4,$dev7 $vg2 $dev7
-vgexport --devices $dev3,$dev4 $vg2
-vgimport --devices $dev3,$dev4 $vg2
-not pvremove --devices $dev3,$dev4 $dev7
-not pvcreate --devices $dev3,$dev4 $dev7
-not vgcreate --devices $dev3,$dev4 $vg7 $dev7
-pvremove --devices $dev7 $dev7
-pvcreate --devices $dev7 $dev7
-vgcreate --devices $dev7 $vg7 $dev7
-vgremove --devices $dev7 $vg7
-pvremove --devices $dev7 $dev7
+not lvcreate --devices "$dev3","$dev4" -l1 -n $lv4 -an $vg2 "$dev7"
+lvcreate --devices "$dev3","$dev4" -l1 -n $lv4 -an $vg2
+lvs --devices "$dev3","$dev4" $vg2/$lv4
+lvextend --devices "$dev3","$dev4" -l2 $vg2/$lv4
+lvchange --devices "$dev3","$dev4" -ay $vg2/$lv4
+lvchange --devices "$dev3","$dev4" -an $vg2/$lv4
+lvremove --devices "$dev3","$dev4" $vg2/$lv4
+vgchange --devices "$dev3","$dev4" -ay $vg2
+vgchange --devices "$dev3","$dev4" -an $vg2
+not vgextend --devices "$dev3","$dev4" $vg2 "$dev7"
+vgextend --devices "$dev3","$dev4","$dev7" $vg2 "$dev7"
+vgreduce --devices "$dev3","$dev4","$dev7" $vg2 "$dev7"
+vgexport --devices "$dev3","$dev4" $vg2
+vgimport --devices "$dev3","$dev4" $vg2
+not pvremove --devices "$dev3","$dev4" "$dev7"
+not pvcreate --devices "$dev3","$dev4" "$dev7"
+not vgcreate --devices "$dev3","$dev4" $vg7 "$dev7"
+pvremove --devices "$dev7" "$dev7"
+pvcreate --devices "$dev7" "$dev7"
+vgcreate --devices "$dev7" $vg7 "$dev7"
+vgremove --devices "$dev7" $vg7
+pvremove --devices "$dev7" "$dev7"
 
 # verify pvscan with devices file and devices list
 
 # arg not in devices file
 _clear_online_files
-pvscan --devicesfile test.devices --cache -aay $dev3
+pvscan --devicesfile test.devices --cache -aay "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-pvscan --devicesfile test.devices --cache -aay $dev4
+pvscan --devicesfile test.devices --cache -aay "$dev4"
 not ls "$RUNDIR/lvm/pvs_online/$PVID4"
 check lv_field $vg1/$lv1 lv_active ""
 check lv_field $vg2/$lv2 lv_active ""
 
 # arg in devices file
 _clear_online_files
-pvscan --devicesfile test.devices --cache $dev1
-pvscan --devicesfile test.devices --cache $dev2
+pvscan --devicesfile test.devices --cache "$dev1"
+pvscan --devicesfile test.devices --cache "$dev2"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 
 # autoactivate with devices file
 _clear_online_files
-pvscan --devicesfile test.devices --cache -aay $dev1
-pvscan --devicesfile test.devices --cache -aay $dev2
+pvscan --devicesfile test.devices --cache -aay "$dev1"
+pvscan --devicesfile test.devices --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 vgchange -an $vg1
 
 # autoactivate with no devices file
 _clear_online_files
-pvscan --cache -aay $dev3
-pvscan --cache -aay $dev4
+pvscan --cache -aay "$dev3"
+pvscan --cache -aay "$dev4"
 check lv_field $vg2/$lv2 lv_active "active"
 vgchange -an $vg2
 
 # arg not in devices list
 _clear_online_files
-pvscan --devices $dev1,$dev2 --cache $dev3
+pvscan --devices "$dev1","$dev2" --cache "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-pvscan --devices $dev4 --cache $dev3
+pvscan --devices "$dev4" --cache "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-pvscan --devices $dev5 --cache $dev3
+pvscan --devices "$dev5" --cache "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 
 # arg in devices list
 _clear_online_files
-pvscan --devices $dev3 --cache -aay $dev3
-pvscan --devices $dev4 --cache -aay $dev4
+pvscan --devices "$dev3" --cache -aay "$dev3"
+pvscan --devices "$dev4" --cache -aay "$dev4"
 check lv_field $vg2/$lv2 lv_active "active"
 vgchange -an $vg2
 
 
 # verify --devicesfile and --devices are not affected by a filter
 # hide_dev excludes using existing filter
-aux hide_dev $dev2
-aux hide_dev $dev4
-pvs --devicesfile test.devices $dev1
-pvs --devicesfile test.devices $dev2
-not pvs --devicesfile test.devices $dev3
-not pvs --devicesfile test.devices $dev4
-pvs --devices $dev1 $dev1
-pvs --devices $dev2 $dev2
-pvs --devices $dev3 $dev3
-pvs --devices $dev4 $dev4
-pvs --devices $dev5 $dev5
-pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev1 $dev2 $dev3 $dev4 $dev5 | tee out
-grep $dev1 out
-grep $dev2 out
-grep $dev3 out
-grep $dev4 out
-grep $dev5 out
-vgchange --devices $dev1,$dev2 -ay $vg1
+aux hide_dev "$dev2"
+aux hide_dev "$dev4"
+pvs --devicesfile test.devices "$dev1"
+pvs --devicesfile test.devices "$dev2"
+not pvs --devicesfile test.devices "$dev3"
+not pvs --devicesfile test.devices "$dev4"
+pvs --devices "$dev1" "$dev1"
+pvs --devices "$dev2" "$dev2"
+pvs --devices "$dev3" "$dev3"
+pvs --devices "$dev4" "$dev4"
+pvs --devices "$dev5" "$dev5"
+pvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5" "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" | tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+grep "$dev5" out
+vgchange --devices "$dev1","$dev2" -ay $vg1
 check lv_field $vg1/$lv1 lv_active "active"
-lvchange --devices $dev1,$dev2 -an $vg1/$lv1
-vgchange --devices $dev3,$dev4 -ay $vg2
+lvchange --devices "$dev1","$dev2" -an $vg1/$lv1
+vgchange --devices "$dev3","$dev4" -ay $vg2
 check lv_field $vg2/$lv2 lv_active "active"
-lvchange --devices $dev3,$dev4 -an $vg2/$lv2
-aux unhide_dev $dev2
-aux unhide_dev $dev4
+lvchange --devices "$dev3","$dev4" -an $vg2/$lv2
+aux unhide_dev "$dev2"
+aux unhide_dev "$dev4"
 
 vgchange --devicesfile "" -an
 vgremove --devicesfile "" -y $vg1
@@ -328,16 +328,16 @@ vgremove --devicesfile "" -y $vg3
 aux lvmconf 'devices/use_devicesfile = 1'
 
 DF="$DFDIR/system.devices"
-touch $DF
+touch "$DF"
 
 # create one VG in a non-system devices file
-vgcreate --devicesfile test.devices $vg1 $dev1 $dev2
+vgcreate --devicesfile test.devices $vg1 "$dev1" "$dev2"
 
 # create one VG in the default system devices file
-vgcreate $vg2 $dev3 $dev4
+vgcreate $vg2 "$dev3" "$dev4"
 
 # create one VG in neither devices file
-vgcreate --devicesfile "" $vg3 $dev5 $dev6
+vgcreate --devicesfile "" $vg3 "$dev5" "$dev6"
 
 lvcreate --devicesfile test.devices -l4 -an -i2 -n $lv1 $vg1
 lvcreate -l4 -an -i2 -n $lv2 $vg2
@@ -352,12 +352,12 @@ not vgs $vg1
 vgs $vg2
 not vgs $vg3
 pvs |tee out
-not grep $dev1 out
-not grep $dev2 out
-grep $dev3 out
-grep $dev4 out
-not grep $dev5 out
-not grep $dev6 out
+not grep "$dev1" out
+not grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+not grep "$dev5" out
+not grep "$dev6" out
 
 # test.devices only sees vg1
 vgs --devicesfile test.devices |tee out
@@ -365,12 +365,12 @@ grep $vg1 out
 not grep $vg2 out
 not grep $vg3 out
 pvs --devicesfile test.devices |tee out
-grep $dev1 out
-grep $dev2 out
-not grep $dev3 out
-not grep $dev4 out
-not grep $dev5 out
-not grep $dev6 out
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+not grep "$dev5" out
+not grep "$dev6" out
 
 # no devices file sees all
 vgs --devicesfile "" |tee out
@@ -381,12 +381,12 @@ vgs --devicesfile "" $vg1
 vgs --devicesfile "" $vg2
 vgs --devicesfile "" $vg3
 pvs --devicesfile "" |tee out
-grep $dev1 out
-grep $dev2 out
-grep $dev3 out
-grep $dev4 out
-grep $dev5 out
-grep $dev6 out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+grep "$dev5" out
+grep "$dev6" out
 
 vgchange -ay
 lvs --devicesfile test.devices -o active $vg1/$lv1 |tee out
@@ -414,145 +414,145 @@ not grep active out
 # always gives access to the specified devices
 # always denies access to unspecified devices
 
-vgs --devices $dev1,$dev2 $vg1
-vgs --devices $dev3,$dev4 $vg2
-vgs --devices $dev5,$dev6 $vg3
-
-pvs --devices $dev1 $dev1
-pvs --devices $dev3 $dev3
-pvs --devices $dev5 $dev5
-
-not pvs --devices $dev1 $dev1 $dev2 |tee out
-grep $dev1 out
-not grep $dev2 out
-
-not pvs --devices $dev3 $dev3 $dev4 |tee out
-grep $dev3 out
-not grep $dev4 out
-
-not pvs --devices $dev5 $dev1 $dev2 $dev3 $dev4 $dev5 |tee out
-grep $dev5 out
-not grep $dev1 out
-not grep $dev2 out
-not grep $dev3 out
-not grep $dev4 out
-not grep $dev6 out
-
-pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev5 |tee out
-grep $dev5 out
-not grep $dev1 out
-not grep $dev2 out
-not grep $dev3 out
-not grep $dev4 out
-not grep $dev6 out
-
-pvs --devices $dev1,$dev2,$dev3,$dev4,$dev5 $dev1 $dev2 $dev3 $dev4 $dev5 |tee out
-grep $dev1 out
-grep $dev2 out
-grep $dev3 out
-grep $dev4 out
-grep $dev5 out
-
-vgchange --devices $dev1,$dev2 -ay
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+vgs --devices "$dev1","$dev2" $vg1
+vgs --devices "$dev3","$dev4" $vg2
+vgs --devices "$dev5","$dev6" $vg3
+
+pvs --devices "$dev1" "$dev1"
+pvs --devices "$dev3" "$dev3"
+pvs --devices "$dev5" "$dev5"
+
+not pvs --devices "$dev1" "$dev1" "$dev2" |tee out
+grep "$dev1" out
+not grep "$dev2" out
+
+not pvs --devices "$dev3" "$dev3" "$dev4" |tee out
+grep "$dev3" out
+not grep "$dev4" out
+
+not pvs --devices "$dev5" "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" |tee out
+grep "$dev5" out
+not grep "$dev1" out
+not grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+not grep "$dev6" out
+
+pvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5" "$dev5" |tee out
+grep "$dev5" out
+not grep "$dev1" out
+not grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+not grep "$dev6" out
+
+pvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5" "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" |tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+grep "$dev4" out
+grep "$dev5" out
+
+vgchange --devices "$dev1","$dev2" -ay
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 not grep $lv2 out
 not grep $lv3 out
-vgchange --devices $dev1,$dev2 -an
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | tee out
+vgchange --devices "$dev1","$dev2" -an
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | tee out
 not grep active out
 
-vgchange --devices $dev3,$dev4 -ay
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+vgchange --devices "$dev3","$dev4" -ay
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 not grep $lv1 out
 grep $lv2 out
 not grep $lv3 out
-vgchange --devices $dev3,$dev4 -an
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+vgchange --devices "$dev3","$dev4" -an
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active |tee out
 not grep active out
 
-vgchange --devices $dev5,$dev6 -ay
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+vgchange --devices "$dev5","$dev6" -ay
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 not grep $lv1 out
 not grep $lv2 out
 grep $lv3 out
-vgchange --devices $dev5,$dev6 -an
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+vgchange --devices "$dev5","$dev6" -an
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active |tee out
 not grep active out
 
-lvcreate --devices $dev1,$dev2 -l1 -an -n $lv4 $vg1
-lvremove --devices $dev1,$dev2 $vg1/$lv4
-lvcreate --devices $dev3,$dev4 -l1 -an -n $lv4 $vg2
-lvremove --devices $dev3,$dev4 $vg2/$lv4
-lvcreate --devices $dev5,$dev6 -l1 -an -n $lv4 $vg3
-lvremove --devices $dev5,$dev6 $vg3/$lv4
-
-not vgchange --devices $dev1,$dev2 -ay $vg2
-not vgchange --devices $dev1,$dev2 -ay $vg3
-not vgchange --devices $dev3,$dev4 -ay $vg1
-not vgchange --devices $dev3,$dev4 -ay $vg3
-not vgchange --devices $dev5,$dev6 -ay $vg1
-not vgchange --devices $dev5,$dev6 -ay $vg2
-
-not lvcreate --devices $dev1,$dev2 -an -l1 $vg2
-not lvcreate --devices $dev1,$dev2 -an -l1 $vg3
-not lvcreate --devices $dev3,$dev4 -an -l1 $vg1
-not lvcreate --devices $dev3,$dev4 -an -l1 $vg3
-not lvcreate --devices $dev5,$dev6 -an -l1 $vg1
-not lvcreate --devices $dev5,$dev6 -an -l1 $vg2
+lvcreate --devices "$dev1","$dev2" -l1 -an -n $lv4 $vg1
+lvremove --devices "$dev1","$dev2" $vg1/$lv4
+lvcreate --devices "$dev3","$dev4" -l1 -an -n $lv4 $vg2
+lvremove --devices "$dev3","$dev4" $vg2/$lv4
+lvcreate --devices "$dev5","$dev6" -l1 -an -n $lv4 $vg3
+lvremove --devices "$dev5","$dev6" $vg3/$lv4
+
+not vgchange --devices "$dev1","$dev2" -ay $vg2
+not vgchange --devices "$dev1","$dev2" -ay $vg3
+not vgchange --devices "$dev3","$dev4" -ay $vg1
+not vgchange --devices "$dev3","$dev4" -ay $vg3
+not vgchange --devices "$dev5","$dev6" -ay $vg1
+not vgchange --devices "$dev5","$dev6" -ay $vg2
+
+not lvcreate --devices "$dev1","$dev2" -an -l1 $vg2
+not lvcreate --devices "$dev1","$dev2" -an -l1 $vg3
+not lvcreate --devices "$dev3","$dev4" -an -l1 $vg1
+not lvcreate --devices "$dev3","$dev4" -an -l1 $vg3
+not lvcreate --devices "$dev5","$dev6" -an -l1 $vg1
+not lvcreate --devices "$dev5","$dev6" -an -l1 $vg2
 
 # autoactivate devs in default devices file
 _clear_online_files
-pvscan --cache -aay $dev3
-pvscan --cache -aay $dev4
+pvscan --cache -aay "$dev3"
+pvscan --cache -aay "$dev4"
 check lv_field $vg2/$lv2 lv_active "active"
 vgchange -an $vg2
-pvscan --cache -aay $dev1
+pvscan --cache -aay "$dev1"
 not ls "$RUNDIR/lvm/pvs_online/$PVID1"
-pvscan --cache -aay $dev2
+pvscan --cache -aay "$dev2"
 not ls "$RUNDIR/lvm/pvs_online/$PVID2"
-pvscan --cache -aay $dev5
+pvscan --cache -aay "$dev5"
 not ls "$RUNDIR/lvm/pvs_online/$PVID5"
 _clear_online_files
-pvscan --devices $dev3 --cache -aay $dev3
-pvscan --devices $dev3,$dev4 --cache -aay $dev4
-lvs --devices $dev3,$dev4 -o active $vg2/$lv2 | grep active
-vgchange --devices $dev3,$dev4 -an $vg2
+pvscan --devices "$dev3" --cache -aay "$dev3"
+pvscan --devices "$dev3","$dev4" --cache -aay "$dev4"
+lvs --devices "$dev3","$dev4" -o active $vg2/$lv2 | grep active
+vgchange --devices "$dev3","$dev4" -an $vg2
 
 not vgchange -ay $vg1
 vgchange --devicesfile test.devices -ay $vg1
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 not grep $lv2 out
 not grep $lv3 out
 
 vgchange -ay $vg2
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 grep $lv2 out
 not grep $lv3 out
 
 not vgchange -ay $vg3
 vgchange --devicesfile "" -ay $vg3
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 grep $lv2 out
 grep $lv3 out
 
 vgchange -an
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 not grep $lv2 out
 grep $lv3 out
 
 vgchange -ay
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active | grep active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active | grep active |tee out
 grep $lv1 out
 grep $lv2 out
 grep $lv3 out
 
 vgchange --devicesfile "" -an
-lvs --devices $dev1,$dev2,$dev3,$dev4,$dev5,$dev6 -o name,active |tee out
+lvs --devices "$dev1","$dev2","$dev3","$dev4","$dev5","$dev6" -o name,active |tee out
 not grep active out
 
 not vgremove $vg1
@@ -568,72 +568,71 @@ vgremove --devicesfile "" -y $vg3
 # no pvs exist, pvcreate creates DF, e.g. system installation
 
 wipe_all
-rm -f $DF
-pvcreate $dev1
-ls $DF
-grep $dev1 $DF
+rm -f "$DF"
+pvcreate "$dev1"
+ls "$DF"
+grep "$dev1" "$DF"
 
 # no pvs exist, vgcreate creates DF, e.g. system installation
 
 wipe_all
-rm -f $DF
-vgcreate $vg1 $dev1
-ls $DF
-grep $dev1 $DF
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+ls "$DF"
+grep "$dev1" "$DF"
 
 # no pvs exist, touch DF, pvcreate uses it
 
 wipe_all
-rm -f $DF
-touch $DF
-pvcreate $dev1
-grep $dev1 $DF
+rm -f "$DF"
+touch "$DF"
+pvcreate "$dev1"
+grep "$dev1" "$DF"
 
 # no vgs exist, touch DF, vgcreate uses it
 
 wipe_all
-rm -f $DF
-touch $DF
-vgcreate $vg1 $dev1
-grep $dev1 $DF
+rm -f "$DF"
+touch "$DF"
+vgcreate $vg1 "$dev1"
+grep "$dev1" "$DF"
 
 # vgs exist, pvcreate/vgcreate do not create DF
 
 wipe_all
-rm -f $DF
-vgcreate $vg1 $dev1
-ls $DF
-rm $DF
-pvcreate $dev2
-not ls $DF
-vgcreate $vg3 $dev3
-not ls $DF
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+ls "$DF"
+rm "$DF"
+pvcreate "$dev2"
+not ls "$DF"
+vgcreate $vg3 "$dev3"
+not ls "$DF"
 
 # vgs exist, pvcreate/vgcreate --devicesfile system.devices creates DF
 
 wipe_all
-rm -f $DF
-vgcreate $vg1 $dev1
-ls $DF
-rm $DF
-pvcreate --devicesfile system.devices $dev2
-ls $DF
-grep $dev2 $DF
-rm $DF
-vgcreate --devicesfile system.devices $vg3 $dev3
-ls $DF
-grep $dev3 $DF
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+ls "$DF"
+rm "$DF"
+pvcreate --devicesfile system.devices "$dev2"
+ls "$DF"
+grep "$dev2" "$DF"
+rm "$DF"
+vgcreate --devicesfile system.devices $vg3 "$dev3"
+ls "$DF"
+grep "$dev3" "$DF"
 
 # pvcreate/vgcreate always create non-system DF if it doesn't exist
 
 wipe_all
-rm -f $DF
-vgcreate $vg1 $dev1
-rm $DF
-rm $DFDIR/test.devices
-pvcreate --devicesfile test.devices $dev2
-grep $dev2 $DFDIR/test.devices
-rm $DFDIR/test.devices
-vgcreate --devicesfile test.devices $vg3 $dev3
-grep $dev3 $DFDIR/test.devices
-
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+rm "$DF"
+rm "$DFDIR/test.devices"
+pvcreate --devicesfile test.devices "$dev2"
+grep "$dev2" "$DFDIR/test.devices"
+rm "$DFDIR/test.devices"
+vgcreate --devicesfile test.devices $vg3 "$dev3"
+grep "$dev3" "$DFDIR/test.devices"
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 2ef0be13a..c3add303b 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -31,41 +31,41 @@ _clear_online_files() {
 }
 
 DFDIR="$LVM_SYSTEM_DIR/devices"
-mkdir $DFDIR || true
+mkdir "$DFDIR" || true
 DF="$DFDIR/system.devices"
 ORIG="$DFDIR/orig.devices"
 
 aux lvmconf 'devices/use_devicesfile = 1'
 
-pvcreate $dev1
-ls $DF
-grep $dev1 $DF
+pvcreate "$dev1"
+ls "$DF"
+grep "$dev1" "$DF"
 
-pvcreate $dev2
-grep $dev2 $DF
+pvcreate "$dev2"
+grep "$dev2" "$DF"
 
-pvcreate $dev3
-grep $dev3 $DF
+pvcreate "$dev3"
+grep "$dev3" "$DF"
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 
 # PVID with dashes for matching pvs -o+uuid output
-OPVID1=`pvs $dev1 --noheading -o uuid | awk '{print $1}'`
-OPVID2=`pvs $dev2 --noheading -o uuid | awk '{print $1}'`
-OPVID3=`pvs $dev3 --noheading -o uuid | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
 
 # PVID without dashes for matching devices file fields
-PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
-PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
 
-lvmdevices --deldev $dev3
+lvmdevices --deldev "$dev3"
 
-not grep $dev3 $DF
-not grep $PVID3 $DF
-not pvs $dev3
+not grep "$dev3" "$DF"
+not grep "$PVID3" "$DF"
+not pvs "$dev3"
 
-cp $DF $ORIG
+cp "$DF" "$ORIG"
 
 lvcreate -l4 -an -i2 -n $lv1 $vg1
 
@@ -98,150 +98,150 @@ lvcreate -l4 -an -i2 -n $lv1 $vg1
 
 # edit DF idname, s/dev1/dev3/, where new dev is not in DF
 
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
-cat $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
+cat "$DF"
 # pvs reports correct info 
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-not grep $OPVID3 out
-not grep $dev3 out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
+not grep "$OPVID3" out
+not grep "$dev3" out
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
 # pvs fixed the DF
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-cat $DF
-
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+cat "$DF"
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
+cat "$DF"
 # lvcreate uses correct dev
-lvcreate -l1 -n $lv2 -an $vg1 $dev1
+lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
 # pvs reports correct dev
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-not grep $OPVID3 out
-not grep $dev3 out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
+not grep "$OPVID3" out
+not grep "$dev3" out
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
 lvremove $vg1/$lv2
-cat $DF
+cat "$DF"
 
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" $ORIG > $DF
-cat $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" "$ORIG" > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+cat "$DF"
 
 # edit DF idname, s/dev1/dev2/, creating two entries with same idname
 
-sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
-cat $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
-
-sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
+
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
+cat "$DF"
 # lvcreate uses correct dev
-lvcreate -l1 -n $lv2 -an $vg1 $dev1
+lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 lvremove $vg1/$lv2
-cat $DF
+cat "$DF"
 
-sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" $ORIG > $DF
-cat $DF
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" "$ORIG" > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 # edit DF idname, swap dev1 and dev2
 
-sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
-sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
+cat "$DF"
 # lvcreate uses correct dev
-lvcreate -l1 -n $lv2 -an $vg1 $dev1
+lvcreate -l1 -n $lv2 -an $vg1 "$dev1"
 # lvcreate fixed the DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 lvremove $vg1/$lv2
-cat $DF
+cat "$DF"
 
-sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp1.devices > tmp2.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp2.devices > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 
 #
@@ -253,91 +253,91 @@ cat $DF
 
 # edit DF devname, s/dev1/dev3/, where new dev is not in DF
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > $DF
-cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-not grep $OPVID3 out
-not grep $dev3 out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
+not grep "$OPVID3" out
+not grep "$dev3" out
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
 # pvs fixed the DF
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-cat $DF
-
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > $DF
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+cat "$DF"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+cat "$DF"
 
 # edit DF devname, s/dev1/dev2/, creating two entries with same devname
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" $ORIG > $DF
-cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-cat $DF
-
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" $ORIG > $DF
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+cat "$DF"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" "$ORIG" > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 # edit DF devname, swap dev1 and dev2
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
-sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > $DF
-cat $DF
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+cat "$DF"
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
-sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > $DF
-cat $DF
+sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 
 #
@@ -349,111 +349,111 @@ cat $DF
 
 # edit DF idname&devname, s/dev1/dev3/, where new dev is not in DF
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
-cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-not grep $OPVID3 out
-not grep $dev3 out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
+not grep "$OPVID3" out
+not grep "$dev3" out
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
 # pvs fixed the DF
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-cat $DF
-
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+cat "$DF"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-not grep $PVID3 $DF
-not grep $dev3 $DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-cat $DF
+not grep "$PVID3" "$DF"
+not grep "$dev3" "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+cat "$DF"
 
 # edit DF idname&devname, s/dev1/dev2/, creating two entries with same devname
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > $DF
-sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > $DF
-cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-grep IDNAME=$dev2 out
-cat $DF
-
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > $DF
-sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > $DF
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+grep "IDNAME=$dev2" out
+cat "$DF"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" tmp1.devices > "$DF"
+sed -e "s|IDNAME=$dev1|IDNAME=$dev2|" tmp1.devices > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 # edit DF devname, swap dev1 and dev2
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
 sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
+cat "$DF"
 # pvs reports correct info
 pvs -o+uuid | tee pvs.out
 grep $vg1 pvs.out > out
-grep $OPVID1 out |tee out2
-grep $dev1 out2
-grep $OPVID2 out |tee out2
-grep $dev2 out2
+grep "$OPVID1" out |tee out2
+grep "$dev1" out2
+grep "$OPVID2" out |tee out2
+grep "$dev2" out2
 # pvs fixed the DF
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-grep IDNAME=$dev2 out
-cat $DF
-
-sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+grep "IDNAME=$dev2" out
+cat "$DF"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
 sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
+cat "$DF"
 # lvmdevices fixes the DF
 lvmdevices --update
-grep $PVID1 $DF |tee out
-grep DEVNAME=$dev1 out
-grep IDNAME=$dev1 out
-grep $PVID2 $DF |tee out
-grep DEVNAME=$dev2 out
-grep IDNAME=$dev2 out
-cat $DF
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "DEVNAME=$dev2" out
+grep "IDNAME=$dev2" out
+cat "$DF"
 
 #
 # check that pvscan --cache -aay does the right thing:
@@ -465,52 +465,52 @@ cat $DF
 
 # edit DF idname&devname, s/dev1/dev3/, where new dev is not in DF
 
-sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" $ORIG > tmp1.devices
-sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > $DF
-cat $DF
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
+cat "$DF"
 _clear_online_files
-pvscan --cache -aay $dev1
-pvscan --cache -aay $dev2
-pvscan --cache -aay $dev3
-cat $DF
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
+pvscan --cache -aay "$dev3"
+cat "$DF"
 # pvscan does not fix DF
-grep $dev3 $DF
-not grep $dev1 $DF
-ls "$RUNDIR/lvm/pvs_online/$PVID1"
+grep "$dev3" "$DF"
+not grep "$dev1" "$DF"
+ls "$RUNDIR/lvm/pvs_online/"$PVID1""
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
-not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+not ls "$RUNDIR/lvm/pvs_online/"$PVID3""
 check lv_field $vg1/$lv1 lv_active "active"
 # pvs updates the DF
 pvs |tee out
-grep $dev1 out
-grep $dev2 out
-not grep $dev3 out
-grep $dev1 $DF
-grep $dev2 $DF
-not grep $dev3 $DF
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
 vgchange -an $vg1
 
 # edit DF idname&devname, swap dev1 and dev2
 
 vgremove -y $vg1
-vgcreate $vg1 $dev1
+vgcreate $vg1 "$dev1"
 lvcreate -n $lv1 -l1 -an $vg1
-vgcreate $vg2 $dev2
+vgcreate $vg2 "$dev2"
 lvcreate -n $lv2 -l1 -an $vg2
 
-cat $DF
-sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" $ORIG > tmp1.devices
+cat "$DF"
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpname|" "$ORIG" > tmp1.devices
 sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1.devices > tmp2.devices
 sed -e "s|DEVNAME=tmpname|DEVNAME=$dev2|" tmp2.devices > tmp3.devices
 sed -e "s|IDNAME=$dev1|IDNAME=tmpname|" tmp3.devices > tmp4.devices
 sed -e "s|IDNAME=$dev2|IDNAME=$dev1|" tmp4.devices > tmp5.devices
-sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > $DF
-cat $DF
+sed -e "s|IDNAME=tmpname|IDNAME=$dev2|" tmp5.devices > "$DF"
+cat "$DF"
 
 _clear_online_files
 
 # pvscan creates the correct online files and activates correct vg
-pvscan --cache -aay $dev1
+pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/vgs_online/$vg1"
 not ls "$RUNDIR/lvm/pvs_online/$PVID2"
@@ -519,30 +519,30 @@ not ls "$RUNDIR/lvm/vgs_online/$vg2"
 dmsetup status $vg1-$lv1
 not dmsetup status $vg2-$lv2
 
-pvscan --cache -aay $dev2
+pvscan --cache -aay "$dev2"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 ls "$RUNDIR/lvm/vgs_online/$vg2"
 dmsetup status $vg2-$lv2
 
-pvscan --cache -aay $dev3
+pvscan --cache -aay "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 
 # pvscan did not correct DF
-cat $DF
-grep $PVID1 $DF |tee out
-grep $dev2 out
-not grep $dev1 out
-grep $PVID2 $DF |tee out
-grep $dev1 out
-not grep $dev2 out
+cat "$DF"
+grep "$PVID1" "$DF" |tee out
+grep "$dev2" out
+not grep "$dev1" out
+grep "$PVID2" "$DF" |tee out
+grep "$dev1" out
+not grep "$dev2" out
 
 # pvs corrects DF
 pvs
-grep $PVID1 $DF |tee out
-grep $dev1 out
-not grep $dev2 out
-grep $PVID2 $DF |tee out
-grep $dev2 out
-not grep $dev1 out
+grep "$PVID1" "$DF" |tee out
+grep "$dev1" out
+not grep "$dev2" out
+grep "$PVID2" "$DF" |tee out
+grep "$dev2" out
+not grep "$dev1" out
 
 vgremove -ff $vg1
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index a11aeec23..3df875418 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -146,7 +146,7 @@ not pvs "$dev5"
 
 # create a new temp device that will cause hint hash to change
 DEVNAME=${PREFIX}pv99
-echo "0 `blockdev --getsize $dev5` linear $dev5 0" | dmsetup create $DEVNAME
+echo "0 $(blockdev --getsize "$dev5") linear $dev5 0" | dmsetup create $DEVNAME
 dmsetup status $DEVNAME
 
 cp $HINTS $PREV
@@ -391,7 +391,7 @@ rm tmp-old tmp-new tmp-newuuid
 #
 
 # this vgcreate invalidates current hints
-vgcreate $vg3 $dev4
+vgcreate $vg3 "$dev4"
 # this pvs creates new hints
 pvs
 cp $HINTS tmp-old
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 711f386fd..de0c9ba8e 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -25,7 +25,7 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 aux prepare_vg 8 80
 get_devs
 
-offset=$(get first_extent_sector $dev1)
+offset=$(get first_extent_sector "$dev1")
 
 function delay
 {
diff --git a/test/shell/lvdisplay-raid.sh b/test/shell/lvdisplay-raid.sh
index 95205ba81..32c3f3478 100644
--- a/test/shell/lvdisplay-raid.sh
+++ b/test/shell/lvdisplay-raid.sh
@@ -21,61 +21,60 @@ SKIP_WITH_LVMPOLLD=1
 aux have_raid 1 7 0 || skip
 
 aux prepare_vg 6
-get_devs
 
 # raid0 loosing a leg
 lvcreate -aey --type raid0 -i5 -l5 -n $lv $vg
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 lvremove -y $vg/$lv
 
 # raid1 loosing a leg/all legs
-lvcreate -aey --type raid1 -m1 -l5 -n $lv $vg $dev1 $dev2
+lvcreate -aey --type raid1 -m1 -l5 -n $lv $vg "$dev1" "$dev2"
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 lvremove -y $vg/$lv
 
 # raid5 loosing a leg/2 legs
 lvcreate -aey --type raid5 -i3 -l5 -n $lv $vg
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 lvremove -y $vg/$lv
 
 # raid6 loosing a leg/2 legs/3 legs
 lvcreate -aey --type raid6 -i3 -l5 -n $lv $vg
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev3
+aux disable_dev "$dev3"
 lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
-aux enable_dev $dev1 $dev2 $dev3
+aux enable_dev "$dev1" "$dev2" "$dev3"
 lvremove -y $vg/$lv
 
 # raid10 loosing a leg per mirror group / a complete mirror group
 lvcreate -aey --type raid10 -i3 -l3 -n $lv $vg
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev3
+aux disable_dev "$dev3"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux disable_dev $dev6
+aux disable_dev "$dev6"
 lvdisplay $vg/$lv|grep "LV Status *available (partial)"
-aux enable_dev $dev1 $dev3 $dev6
+aux enable_dev "$dev1" "$dev3" "$dev6"
 lvdisplay $vg/$lv|grep "LV Status *available"
-aux disable_dev $dev1 $dev2
+aux disable_dev "$dev1" "$dev2"
 lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 
 vgremove -y -f $vg
diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 153939d34..297ceb96d 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -125,7 +125,7 @@ vgremove -f $vg1
 
 pvcreate "$dev3"
 
-PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=$(pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}')
 echo $PVID3
 
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
@@ -220,7 +220,7 @@ vgremove -ff $vg3
 pvremove "$dev8"
 pvcreate -y --setphysicalvolumesize 8M "$dev8"
 
-PVID8=`pvs $dev8 --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID8=$(pvs "$dev8" --noheading -o uuid | tr -d - | awk '{print $1}')
 echo $PVID8
 
 vgcreate $vg3 "$dev8"
@@ -238,4 +238,3 @@ ls "$RUNDIR/lvm/vgs_online/$vg3"
 vgchange -an $vg3
 
 vgremove -ff $vg3
-


