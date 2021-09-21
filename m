From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:50:58 +0000 (GMT)
Subject: main - shellcheck: warning enhancements
Message-ID: <20210921195058.4A8B73858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb6fd1a15f32d79ddaa351704dea47ad9e5ab9be
Commit:        bb6fd1a15f32d79ddaa351704dea47ad9e5ab9be
Parent:        5bd99d55b023f1e105bea6033aa57db3987f2ba5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:02:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

shellcheck: warning enhancements

---
 scripts/lvm_import_vdo.sh                   |  2 +-
 test/lib/aux.sh                             |  4 ++--
 test/shell/devicesfile-devname.sh           |  4 ++--
 test/shell/devicesfile-realdevs.sh          |  6 +++---
 test/shell/idm_fabric_failure.sh            | 14 +++++++-------
 test/shell/idm_fabric_failure_half_brain.sh |  8 ++++----
 test/shell/idm_fabric_failure_timeout.sh    | 10 +++++-----
 test/shell/idm_ilm_failure.sh               |  4 ++--
 test/shell/lvcreate-large-raid10.sh         |  4 ++--
 test/shell/thin-zero-meta.sh                |  4 ++--
 test/shell/vdo-convert.sh                   |  2 +-
 11 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index af7917b0c..61a82e41e 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -262,7 +262,7 @@ convert2lvm_() {
 			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
 				VGNAME=${DEFAULT_NAME%/*}
 				# Find largest matching VG name to our 'default' vgname
-				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "$VGNAME[0-9]? ?" | head -1 || true)
+				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "${VGNAME}[0-9]? ?" | head -1 || true)
 				if test -n "$LASTVGNAME" ; then
 					LASTVGNAME=${LASTVGNAME#*${VGNAME}}
 					# If the number is becoming too high, try some random number
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 25e8c2ca5..ca9406383 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -607,7 +607,7 @@ teardown() {
 
 	# Remove any dangling symlink in /dev/disk (our tests can confuse udev)
 	test -d /dev/disk && {
-		find /dev/disk -type l ! -exec /usr/bin/test -e {} \; -print | xargs rm -f || true
+		find /dev/disk -type l ! -exec /usr/bin/test -e {} \; -print0 | xargs -0 rm -f || true
 	}
 
 	# Remove any metadata archives and backups from this test on system
@@ -1200,7 +1200,7 @@ remove_dm_devs() {
 		}
 		remove=( "${held[@]}" )
 	done
-	die "Can't remove device(s) ${held[@]}"
+	die "Can't remove device(s) ${held[*]}"
 }
 
 # Throttle down performance of kcopyd when mirroring i.e. disk image
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index c3add303b..f95be52b1 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -476,9 +476,9 @@ cat "$DF"
 # pvscan does not fix DF
 grep "$dev3" "$DF"
 not grep "$dev1" "$DF"
-ls "$RUNDIR/lvm/pvs_online/"$PVID1""
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
-not ls "$RUNDIR/lvm/pvs_online/"$PVID3""
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 check lv_field $vg1/$lv1 lv_active "active"
 # pvs updates the DF
 pvs |tee out
diff --git a/test/shell/devicesfile-realdevs.sh b/test/shell/devicesfile-realdevs.sh
index edcaed0c4..8d4aa3e67 100644
--- a/test/shell/devicesfile-realdevs.sh
+++ b/test/shell/devicesfile-realdevs.sh
@@ -122,7 +122,7 @@ cp $DF df2
 
 # vgcreate from existing pvs, already in df
 
-vgcreate $vg ${REAL_DEVICES[@]}
+vgcreate $vg "${REAL_DEVICES[@]}"
 
 vgremove $vg
 rm $DF
@@ -130,7 +130,7 @@ rm $DF
 # vgcreate from existing pvs, adding to df
 
 touch $DF
-vgcreate $vg ${REAL_DEVICES[@]}
+vgcreate $vg "${REAL_DEVICES[@]}"
 
 grep IDNAME $DF > df.ids
 grep IDNAME df2 > df2.ids
@@ -242,7 +242,7 @@ grep $dev2 $DF
 rm $DF
 wipe_all
 
-vgcreate $vg ${REAL_DEVICES[@]}
+vgcreate $vg "${REAL_DEVICES[@]}"
 rm $DF
 touch $DF
 
diff --git a/test/shell/idm_fabric_failure.sh b/test/shell/idm_fabric_failure.sh
index e68d6ad07..633dd9d73 100644
--- a/test/shell/idm_fabric_failure.sh
+++ b/test/shell/idm_fabric_failure.sh
@@ -14,7 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-[ -z "$LVM_TEST_FAILURE" ] && skip;
+[ -z "$LVM_TEST_FAILURE" ] && skip
 
 aux prepare_devs 3
 aux extend_filter_LVMTEST
@@ -33,17 +33,17 @@ HOST2=`readlink /sys/block/$DRIVE2 | awk -F'/' '{print $6}'`
 HOST3=`readlink /sys/block/$DRIVE3 | awk -F'/' '{print $6}'`
 
 # Emulate fabric failure
-echo 1 > /sys/block/$DRIVE1/device/delete
-[ -f /sys/block/$DRIVE2/device/delete ] && echo 1 > /sys/block/$DRIVE2/device/delete
-[ -f /sys/block/$DRIVE3/device/delete ] && echo 1 > /sys/block/$DRIVE3/device/delete
+echo 1 > "/sys/block/$DRIVE1/device/delete"
+[ -f "/sys/block/$DRIVE2/device/delete" ] && echo 1 > "/sys/block/$DRIVE2/device/delete"
+[ -f "/sys/block/$DRIVE3/device/delete" ] && echo 1 > "/sys/block/$DRIVE3/device/delete"
 
 # Wait for 10s and will not lead to timeout
 sleep 10
 
 # Rescan drives so can probe the deleted drives and join back them
-echo "- - -" > /sys/class/scsi_host/${HOST1}/scan
-echo "- - -" > /sys/class/scsi_host/${HOST2}/scan
-echo "- - -" > /sys/class/scsi_host/${HOST3}/scan
+echo "- - -" > "/sys/class/scsi_host/${HOST1}/scan"
+echo "- - -" > "/sys/class/scsi_host/${HOST2}/scan"
+echo "- - -" > "/sys/class/scsi_host/${HOST3}/scan"
 
 not check grep_lvmlockd_dump "S lvm_$vg kill_vg"
 
diff --git a/test/shell/idm_fabric_failure_half_brain.sh b/test/shell/idm_fabric_failure_half_brain.sh
index c692a12ad..784b26896 100644
--- a/test/shell/idm_fabric_failure_half_brain.sh
+++ b/test/shell/idm_fabric_failure_half_brain.sh
@@ -15,8 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
-[ -z "$LVM_TEST_FAILURE" ] && skip;
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip
+[ -z "$LVM_TEST_FAILURE" ] && skip
 
 aux prepare_devs 2
 aux extend_filter_LVMTEST
@@ -55,7 +55,7 @@ for dev in /dev/*; do
 done
 
 for d in "${drive_list[@]}"; do
-	[ -f /sys/block/$d/device/delete ] && echo 1 > /sys/block/$d/device/delete
+	[ -f "/sys/block/$d/device/delete" ] && echo 1 > "/sys/block/$d/device/delete"
 done
 
 # Fail to create new logic volume
@@ -68,7 +68,7 @@ not check grep_lvmlockd_dump "S lvm_$vg kill_vg"
 
 # Rescan drives so can probe the deleted drives and join back them
 for h in "${host_list[@]}"; do
-	[ -f /sys/class/scsi_host/${h}/scan ] && echo "- - -" > /sys/class/scsi_host/${h}/scan
+	[ -f "/sys/class/scsi_host/${h}/scan" ] && echo "- - -" > "/sys/class/scsi_host/${h}/scan"
 done
 
 # After the drive is reconnected, $vg should be visible again.
diff --git a/test/shell/idm_fabric_failure_timeout.sh b/test/shell/idm_fabric_failure_timeout.sh
index cf71f7609..2466f94f0 100644
--- a/test/shell/idm_fabric_failure_timeout.sh
+++ b/test/shell/idm_fabric_failure_timeout.sh
@@ -15,8 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
-[ -z "$LVM_TEST_FAILURE" ] && skip;
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip
+[ -z "$LVM_TEST_FAILURE" ] && skip
 
 aux prepare_devs 1
 aux extend_filter_LVMTEST
@@ -34,7 +34,7 @@ vgcreate $SHARED $vg "$dev1"
 # Create new logic volume
 lvcreate -a ey --zero n -l 1 -n $lv1 $vg
 
-drive_list=($DRIVE1)
+drive_list=( "$DRIVE1" )
 
 # Find all drives with the same WWN and delete them from system,
 # so that we can emulate the same drive with multiple paths are
@@ -52,7 +52,7 @@ for dev in /dev/*; do
 done
 
 for d in "${drive_list[@]}"; do
-	[ -f /sys/block/$d/device/delete ] && echo 1 > /sys/block/$d/device/delete
+	[ -f "/sys/block/$d/device/delete" ] && echo 1 > "/sys/block/$d/device/delete"
 done
 
 # Fail to create new logic volume
@@ -66,7 +66,7 @@ lvmlockctl --drop $vg
 
 # Rescan drives so can probe the deleted drives and join back them
 for h in "${host_list[@]}"; do
-	[ -f /sys/class/scsi_host/${h}/scan ] && echo "- - -" > /sys/class/scsi_host/${h}/scan
+	[ -f "/sys/class/scsi_host/${h}/scan" ] && echo "- - -" > "/sys/class/scsi_host/${h}/scan"
 done
 
 # After the drive is reconnected, $vg should be visible again.
diff --git a/test/shell/idm_ilm_failure.sh b/test/shell/idm_ilm_failure.sh
index 58bed270e..4b48476fe 100644
--- a/test/shell/idm_ilm_failure.sh
+++ b/test/shell/idm_ilm_failure.sh
@@ -15,8 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
-[ -z "$LVM_TEST_FAILURE" ] && skip;
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip
+[ -z "$LVM_TEST_FAILURE" ] && skip
 
 aux prepare_devs 3
 aux extend_filter_LVMTEST
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index a46be374f..89eb0a664 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -31,8 +31,8 @@ done
 
 aux extend_filter_LVMTEST
 
-pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
-vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
+pvcreate "$DM_DEV_DIR"/$vg/${lv}[12345]
+vgcreate $vg1 "$DM_DEV_DIR"/$vg/${lv}[12345]
 
 
 #
diff --git a/test/shell/thin-zero-meta.sh b/test/shell/thin-zero-meta.sh
index 6a15a7388..a46672900 100644
--- a/test/shell/thin-zero-meta.sh
+++ b/test/shell/thin-zero-meta.sh
@@ -53,8 +53,8 @@ do
 
 	# When fully zeroed, it should be zero - so almost no output from hexdump
 	case "$i" in
-	0) test $(wc -l < out) -ge 10 ;; # should not be zeroed
-	1) test $(wc -l < out) -le 10 ;; # should be zeroed
+	0) test "$(wc -l < out)" -ge 10 ;; # should not be zeroed
+	1) test "$(wc -l < out)" -le 10 ;; # should be zeroed
 	esac
 
 	lvremove -f $vg/pool
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 632f86a36..f82529a2d 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -168,7 +168,7 @@ vdo create $VDOCONF --name "$VDONAME" --device="$LOOP" --vdoLogicalSize=23G \
 # Get VDO table line
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
-DM_DEV_DIR= lvm_import_vdo -y --name $vg/$lv "$LOOP"
+DM_DEV_DIR="" lvm_import_vdo -y --name $vg/$lv "$LOOP"
 lvs -a $vg
 
 dmsetup table "$vg-${lv}_vpool-vpool" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee new-vdo-lv


