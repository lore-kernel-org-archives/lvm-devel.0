From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 20 Jun 2013 16:51:50 +0000 (UTC)
Subject: master - TEST: Test RAID syncaction, writemostly, & refresh under snapshots
Message-ID: <20130620165150.0E30760794@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdcfe8c6de26472562a8f907081e0eb94e038488
Commit:        bdcfe8c6de26472562a8f907081e0eb94e038488
Parent:        8215846aa52b727c3c639d9b354d611319be26c6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 20 11:48:15 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 20 11:48:15 2013 -0500

TEST: Test RAID syncaction, writemostly, & refresh under snapshots

Test the different RAID lvchange scenarios under snapshot as well.

This patch also updates calculations for where to write to an
underlying PV when testing various syncactions.
---
 test/lib/check.sh           |    8 +++--
 test/shell/lvchange-raid.sh |   68 ++++++++++++++++++++++++++++++++++---------
 2 files changed, 59 insertions(+), 17 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 6cb33ac..8db0c65 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -158,6 +158,7 @@ in_sync() {
 	local b
 	local idx
 	local type
+	local snap=""
 	local lvm_name="$1/$2"
 	local dm_name=$(echo $lvm_name | sed s:-:--: | sed s:/:-:)
 
@@ -167,6 +168,7 @@ in_sync() {
 		if ! a=(`dmsetup status ${dm_name}-real`); then
 			die "Unable to get sync status of $1"
 		fi
+		snap=": under snapshot"
 	fi
 
 	if [ ${a[2]} = "raid" ]; then
@@ -184,15 +186,15 @@ in_sync() {
 	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
 
 	if [ ${b[0]} != ${b[1]} ]; then
-		echo "$lvm_name ($type) is not in-sync"
+		echo "$lvm_name ($type$snap) is not in-sync"
 		return 1
 	fi
 
 	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
-		die "$lvm_name in-sync, but 'a' characters in health status"
+		die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
 	fi
 
-	echo "$lvm_name ($type) is in-sync"
+	echo "$lvm_name ($type$snap) is in-sync"
 	return 0
 }
 
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index da9c76e..1dbd42a 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -9,18 +9,20 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-# This test ensures that 'lvchange --refresh vg/raid_lv' properly restores
-# a transiently failed device in RAID LVs.
-
 . lib/test
 
 # dm-raid v1.4.1+ contains RAID10 support
 aux target_at_least dm-raid 1 4 1 || skip
 
-aux prepare_vg 5
+aux prepare_vg 6
 
 # run_writemostly_check <VG> <LV>
 run_writemostly_check() {
+	local d0
+	local d1
+
+	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
+		$1 $2 `lvs --noheadings -o segtype $1/$2`
 	d0=`lvs -a --noheadings -o devices $1/${2}_rimage_0 | sed s/\(.\)//`
 	d0=$(sed s/^[[:space:]]*// <<< "$d0")
 	d1=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
@@ -115,26 +117,40 @@ run_syncaction_check() {
 	local device
 	local seek
 	local size
+	local tmp
 
+	printf "#\n#\n#\n# %s/%s (%s): run_syncaction_check\n#\n#\n#\n" \
+		$1 $2 `lvs --noheadings -o segtype $1/$2`
 	aux wait_for_sync $1 $2
 
 	device=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
 	device=$(sed s/^[[:space:]]*// <<< "$device")
-	size=`lvs -a --noheadings -o size --units 1k $1/$2 | sed s/\.00k//`
+
+	size=`lvs -a --noheadings -o size --units 1k $1/${2}_rimage_1 | sed s/\.00k//`
 	size=$(sed s/^[[:space:]]*// <<< "$size")
 	size=$(($size / 2))
-	seek=`pvs --noheadings -o mda_size --units 1k $device | sed s/\.00k//`
-	seek=$(sed s/^[[:space:]]*// <<< "$seek")
-	seek=$(($size + $seek))
+
+	tmp=`pvs --noheadings -o mda_size --units 1k $device | sed s/\.00k//`
+	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
+	seek=$tmp  # Jump over MDA
+
+	tmp=`lvs -a --noheadings -o size --units 1k $1/${2}_rmeta_1 | sed s/\.00k//`
+	tmp=$(sed s/^[[:space:]]*// <<< "$tmp")
+	seek=$(($seek + $tmp))  # Jump over RAID metadata image
+
+	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
 	# Check all is normal
 	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-$' ||
 		[ `lvs --noheadings -o mismatches $1/$2` != 0 ]; then
-		#
+
 		# I think this is a kernel bug.  It happens randomly after
 		# a RAID device creation.  I think the mismatch count
 		# should not be set unless a check or repair is run.
 		#
+		# Neil Brown disagrees that it is a bug.  Says mismatch
+		# count can be anything until a 'check' or 'repair' is
+		# run.
 		echo "Strange... RAID has mismatch count after creation."
 
 		# Run "check" should turn up clean
@@ -179,6 +195,9 @@ run_syncaction_check() {
 run_refresh_check() {
 	local size
 
+	printf "#\n#\n#\n# %s/%s (%s): run_refresh_check\n#\n#\n#\n" \
+		$1 $2 `lvs --noheadings -o segtype $1/$2`
+
 	aux wait_for_sync $1 $2
 
 	size=`lvs -a --noheadings -o size --units 1k $1/$2 | sed s/\.00k//`
@@ -197,6 +216,8 @@ run_refresh_check() {
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*r$'
 
 	lvchange --refresh $1/$2
+	aux wait_for_sync $1 $2
+	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
 
 	# Writing random data above should mean that the devices
 	# were out-of-sync.  The refresh should have taken care
@@ -207,7 +228,9 @@ run_refresh_check() {
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-$'
 }
 
+# run_checks <VG> <LV> [snapshot_dev]
 run_checks() {
+	# Without snapshots
 	if aux target_at_least dm-raid 1 1 0; then
 		run_writemostly_check $1 $2
 	fi
@@ -219,6 +242,23 @@ run_checks() {
 	if aux target_at_least dm-raid 1 5 1; then
 		run_refresh_check $1 $2
 	fi
+
+	# With snapshots
+	if [ ! -z $3 ]; then
+		lvcreate -s $1/$2 -l 4 -n snap $3
+		if aux target_at_least dm-raid 1 1 0; then
+			run_writemostly_check $1 $2
+		fi
+
+		if aux target_at_least dm-raid 1 5 0; then
+			run_syncaction_check $1 $2
+		fi
+
+		if aux target_at_least dm-raid 1 5 1; then
+			run_refresh_check $1 $2
+		fi
+		lvremove -ff $1/snap
+	fi
 }
 
 ########################################################
@@ -226,23 +266,23 @@ run_checks() {
 ########################################################
 
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg "$dev1" "$dev2"
-run_checks $vg $lv1
+run_checks $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 lvcreate --type raid4 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1
+run_checks $vg $lv1 "$dev5"
 lvremove -ff $vg
 
 lvcreate --type raid5 -i 2 -l 4 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1
+run_checks $vg $lv1 "$dev5"
 lvremove -ff $vg
 
 lvcreate --type raid6 -i 3 -l 6 -n $lv1 $vg \
 		"$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-run_checks $vg $lv1
+run_checks $vg $lv1 "$dev6"
 lvremove -ff $vg
 
 lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg \
 		"$dev1" "$dev2" "$dev3" "$dev4"
-run_checks $vg $lv1
+run_checks $vg $lv1 "$dev5"
 lvremove -ff $vg


