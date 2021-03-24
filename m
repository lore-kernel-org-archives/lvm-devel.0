From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 11:41:53 +0000 (GMT)
Subject: main - tests: ignore incosistent raid status
Message-ID: <20210324114153.5F7CD3857026@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9684e82cc44cfec66f30b807160c19c06df2a2d8
Commit:        9684e82cc44cfec66f30b807160c19c06df2a2d8
Parent:        afd43a75f20fbecb047924468c84212f7aefcf0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 12:08:40 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 12:40:17 2021 +0100

tests: ignore incosistent raid status

Just like lvm command ignores  0/xxxx report from judging the status.
Avoid using infinite loop and limit report checking to 100 checks.
If it would need more - something is not right.
---
 test/shell/lvconvert-raid-status-validation.sh | 51 ++++++++++++++++----------
 1 file changed, 31 insertions(+), 20 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index 2d3b5b982..d923bf543 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -36,25 +36,28 @@ vgcreate $SHARED -s 2m "$vg" "${DEVICES[@]}"
 ###########################################
 # Upconverted RAID1 should never have all 'a's in status output
 ###########################################
-aux delay_dev "$dev2" 0 50
+aux delay_dev "$dev2" 0 20
 lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
-while ! check in_sync $vg $lv1; do
-        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+for i in {100..0}; do
+	check in_sync $vg $lv1 && break
+	a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
 	b=( $(echo "${a[6]}" | sed s:/:' ':) )
 	if [ "${b[0]}" -ne "${b[1]}" ]; then
 		# First, 'check in_sync' should only need to check the ratio
 		#  If we are here, it is probably doing more than that.
 		# If not in-sync, then we should only ever see "Aa"
-		[ "${a[5]}" == "Aa" ]
+		# Ignore until raid starts to report consistent data
+		[ "${b[0]}" = "0" ] || [ "${a[5]}" == "Aa" ]
 	else
 		[ "${a[5]}" != "aa" ]
 		should [ "${a[5]}" == "AA" ] # RHBZ 1507719
 	fi
-        sleep .1
+	sleep .1
 done
 aux enable_dev "$dev2"
 lvremove -ff $vg
+test "$i" -gt 0 || die "Unable to get in sync $vg/$lv1"
 
 ###########################################
 # Upconverted RAID1 should not be at 100% right after upconvert
@@ -71,13 +74,15 @@ lvremove -ff $vg
 ###########################################
 # Catch anything suspicious with linear -> RAID1 upconvert
 ###########################################
-aux delay_dev "$dev2" 0 50
+aux delay_dev "$dev2" 0 20
 lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert --type raid1 -y -m 1 $vg/$lv1 "$dev2"
-while true; do
-        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+for i in {100..0}; do
+	a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
 	b=( $(echo "${a[6]}" | sed s:/:' ':) )
-	if [ "${b[0]}" -ne "${b[1]}" ]; then
+	if [ "${b[0]}" -eq "0" ]; then
+	      : # Ignore until raid starts to report consistent data
+	elif [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
 		[ "${a[5]}" = "Aa" ]
@@ -96,7 +101,7 @@ while true; do
 		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
-        sleep .1
+	sleep .1
 done
 aux enable_dev "$dev2"
 lvremove -ff $vg
@@ -104,14 +109,16 @@ lvremove -ff $vg
 ###########################################
 # Catch anything suspicious with RAID1 2-way -> 3-way upconvert
 ###########################################
-aux delay_dev "$dev3" 0 50
+aux delay_dev "$dev3" 0 20
 lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
 aux wait_for_sync $vg $lv1
 lvconvert -y -m +1 $vg/$lv1 "$dev3"
-while true; do
-        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+for i in {100..0}; do
+	a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
 	b=( $(echo "${a[6]}" | sed s:/:' ':) )
-	if [ "${b[0]}" -ne "${b[1]}" ]; then
+	if [ "${b[0]}" -eq "0" ]; then
+	      : # Ignore until raid starts to report consistent data
+	elif [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
 		[ "${a[5]}" = "AAa" ]
@@ -125,20 +132,23 @@ while true; do
 		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
-        sleep .1
+	sleep .1
 done
 aux enable_dev "$dev3"
 lvremove -ff $vg
+test "$i" -gt 0 || die "Unable to get in sync $vg/$lv1"
 
 ###########################################
 # Catch anything suspicious with RAID1 initial resync
 ###########################################
-aux delay_dev "$dev2" 0 50
+aux delay_dev "$dev2" 0 20
 lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2"
-while true; do
-        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+for i in {100..0}; do
+	a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
 	b=( $(echo "${a[6]}" | sed s:/:' ':) )
-	if [ "${b[0]}" -ne "${b[1]}" ]; then
+	if [ "${b[0]}" -eq "0" ]; then
+	      : # Ignore until raid starts to report consistent data
+	elif [ "${b[0]}" -ne "${b[1]}" ]; then
 		# If the sync operation ("resync" in this case) is not
 		# finished, then it better be as follows:
 		[ "${a[5]}" = "aa" ]
@@ -153,9 +163,10 @@ while true; do
 		should [ "${a[7]}" = "idle" ] # RHBZ 1507719
 		break
 	fi
-        sleep .1
+	sleep .1
 done
 aux enable_dev "$dev2"
 lvremove -ff $vg
+test "$i" -gt 0 || die "Unable to get in sync $vg/$lv1"
 
 vgremove -ff $vg


