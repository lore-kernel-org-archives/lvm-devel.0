From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 28 Mar 2021 12:23:15 +0000 (GMT)
Subject: main - tests: sleep tunning
Message-ID: <20210328122315.C12AD3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a17a5ab80b1699ac086ad34852116e7728cc378
Commit:        1a17a5ab80b1699ac086ad34852116e7728cc378
Parent:        d9b97510324e7c16cf8ec61f511b6f5d71bff767
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 28 12:18:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 28 14:22:11 2021 +0200

tests: sleep tunning

Check different sleep properties for lvmpolld.
Use aux remove_dm_devs.
---
 test/shell/pvcreate-md-fake-hdr.sh   |  3 +--
 test/shell/pvmove-resume-1.sh        | 21 ++++-----------------
 test/shell/pvmove-resume-2.sh        | 22 ++++------------------
 test/shell/pvmove-resume-multiseg.sh | 22 +++++++---------------
 4 files changed, 16 insertions(+), 52 deletions(-)

diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 73846ed71..f610d6fb3 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -49,12 +49,11 @@ dd if="$dev3"  of="$dev2" bs=64k count=1 conv=fdatasync
 # remove VG on PV3 & PV4
 vgremove -f $vg
 
-sleep 3
 aux udev_wait
 # too bad  'dd' wakes up  md array reassembling
 mdadm --detail "$mddev" || true
 mdadm --stop "$mddev" || true
-sleep 3
+sleep 1
 
 # print what  blkid thinks about each PV
 for i in "$dev1" "$dev2" "$dev3" "$dev4"
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 7b9fc0f39..00a8f2dcd 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -20,7 +20,8 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-aux throttle_dm_mirror 50 || :
+test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
+
 aux prepare_pvs 4 30
 
 vgcreate -s 128k $vg "$dev1"
@@ -49,24 +50,10 @@ test_pvmove_resume() {
 	aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
 	kill -9 $PVMOVE
 
-	if test -e LOCAL_LVMPOLLD ; then
-		aux prepare_lvmpolld
-	fi
-
+	aux remove_dm_devs "$vg-$lv1" "$vg1-$lv1" "$vg-pvmove0" "$vg1-pvmove0"
+	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
 
-	local finished
-	for i in {1..100}; do
-		finished=1
-		for d in  "$vg-$lv1" "$vg1-$lv1" "$vg-pvmove0" "$vg1-pvmove0" ; do
-			dmsetup status "$d" 2>/dev/null && {
-				dmsetup remove "$d" || finished=0
-			}
-		done
-		test "$finished" -eq 0 || break
-	done
-	test "$finished" -eq 0 && die "Can't remove device"
-
 	check lv_attr_bit type $vg/pvmove0 "p"
 	check lv_attr_bit type $vg1/pvmove0 "p"
 
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 92b0070c0..233aec3c1 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -20,14 +20,14 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
+
 aux prepare_pvs 2 30
 
 vgcreate -s 128k $vg "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 vgextend $vg "$dev2"
 
-aux throttle_dm_mirror 50 || :
-
 test_pvmove_resume() {
 	# 2 LVs on same device
 	lvcreate -an -Zn -l15 -n $lv1 $vg "$dev1"
@@ -40,24 +40,10 @@ test_pvmove_resume() {
 	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 	kill -9 $PVMOVE
 
-	if test -e LOCAL_LVMPOLLD ; then
-		aux prepare_lvmpolld
-	fi
-
+	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" 
+	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
 
-	local finished
-	for i in {1..100}; do
-		finished=1
-		for d in  "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" ; do
-			dmsetup status "$d" 2>/dev/null && {
-				dmsetup remove "$d" || finished=0
-			}
-		done
-		test "$finished" -eq 0 || break
-	done
-	test "$finished" -eq 0 && die "Can't remove device"
-
 	check lv_attr_bit type $vg/pvmove0 "p"
 
 	if test -e LOCAL_CLVMD ; then
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index cdb426b66..73c7cf354 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -19,8 +19,9 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && aux throttle_dm_mirror 20 || :
+
 aux prepare_pvs 5 40
-aux throttle_dm_mirror 60 || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"
@@ -48,15 +49,8 @@ test_pvmove_resume() {
 	aux wait_pvmove_lv_ready "$vg-pvmove1" 300
 	kill -9 $PVMOVE
 
-	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
-	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
-	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
-	while dmsetup status "$vg-pvmove1"; do dmsetup remove "$vg-pvmove1" || true; done
-
-	if test -e LOCAL_LVMPOLLD ; then
-		aux prepare_lvmpolld
-	fi
-
+	aux remove_dm_devs "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" "$vg-pvmove1"
+	test -e LOCAL_LVMPOLLD && aux prepare_lvmpolld
 	wait
 
 	check lv_attr_bit type $vg/pvmove0 "p"
@@ -90,13 +84,11 @@ test_pvmove_resume() {
 	aux enable_dev "$dev4"
 	aux enable_dev "$dev5"
 
-	i=0
-	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
-		# wait for 30 secs at max
-		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+	for i in {0..300} ; do # wait for 30 secs at max
+		get lv_field $vg name -a | grep -E "^\[?pvmove" || break
 		sleep .1
-		i=$((i + 1))
 	done
+	test $i -ge 300 && die "Pvmove is too slow or does not progress."
 
 	aux kill_tagged_processes
 


