From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 18:15:47 +0000 (UTC)
Subject: master - tests: change default to 30s.
Message-ID: <20150403181547.091D36103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87cb0a3e9ff3efb35d9383a9044f683e28f41776
Commit:        87cb0a3e9ff3efb35d9383a9044f683e28f41776
Parent:        32a0f625a555140adc95a6dc394e6723e5897ea3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 19:35:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 19:40:43 2015 +0200

tests: change default to 30s.

Keep rather the default lower and avoid to pass it with every call.
---
 test/lib/aux.sh                |    3 ++-
 test/shell/pvmove-abort-all.sh |    6 +++---
 test/shell/pvmove-abort.sh     |    7 ++-----
 test/shell/pvmove-restart.sh   |    4 ++--
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f4fc1b5..0dbb8b9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -470,6 +470,7 @@ common_dev_() {
 
 	init_udev_transaction
 	dmsetup load "$name" "$name.devtable"
+	# TODO: add support for resume without udev rescan
 	dmsetup resume "$name"
 	finish_udev_transaction
 }
@@ -903,7 +904,7 @@ dmsetup_wrapped() {
 
 wait_pvmove_lv_ready() {
 	# given sleep .1 this is about 60 secs of waiting
-	local retries=${2:-600}
+	local retries=${2:-300}
 	while : ; do
 		test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
 		dmsetup info -c -o tables_loaded $1 > out 2>/dev/null|| true;
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index dddf210..235ebd8 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -38,12 +38,12 @@ lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
 pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
-aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+aux wait_pvmove_lv_ready "$vg-pvmove0"
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
-aux wait_pvmove_lv_ready "$vg-pvmove1" 300
+aux wait_pvmove_lv_ready "$vg-pvmove1"
 
 pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
-aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
+aux wait_pvmove_lv_ready "$vg1-pvmove0"
 
 # test removal of all pvmove LVs
 pvmove  --abort
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 0efecea..37837ba 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -32,12 +32,9 @@ lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
 pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
-aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+aux wait_pvmove_lv_ready "$vg-pvmove0"
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
-aux wait_pvmove_lv_ready "$vg-pvmove1" 300
-
-# Slow things even more for very slow machines....
-aux delay_dev "$dev3" 0 1000
+aux wait_pvmove_lv_ready "$vg-pvmove1"
 
 # remove specific device
 pvmove --abort "$dev1"
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 92e46bf..88dfebe 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -35,7 +35,7 @@ lvextend -l+10 $vg/$lv1 "$dev2"
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
-aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+aux wait_pvmove_lv_ready "$vg-pvmove0"
 
 kill -9 $PVMOVE
 wait
@@ -80,7 +80,7 @@ dmsetup table
 # Restart pvmove
 # use exclusive activation to have usable pvmove without cmirrord
 vgchange -aey $vg
-aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+aux wait_pvmove_lv_ready "$vg-pvmove0"
 dmsetup table
 
 pvmove --abort


