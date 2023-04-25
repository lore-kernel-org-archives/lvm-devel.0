From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Apr 2023 17:55:40 +0000 (GMT)
Subject: main - tests: adapt waiting for pvmove start
Message-ID: <20230425175540.2F5E83858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ffead4f333d4d2a80a6913842a50fd265d5c4018
Commit:        ffead4f333d4d2a80a6913842a50fd265d5c4018
Parent:        7f2939d328cf273f7f086a2ddf6cfaab86cf07c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 25 19:51:52 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 19:51:52 2023 +0200

tests: adapt waiting for pvmove start

Previous commit cause the pvmove could actually be started in unexpected
order - so make sure, we are not starting new pvmove in same VG until
the previous one is started.
---
 test/lib/aux.sh                | 5 -----
 test/shell/pvmove-abort-all.sh | 4 ++--
 test/shell/pvmove-abort.sh     | 4 ++--
 3 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c773485f5..241bbd595 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -2025,11 +2025,6 @@ wait_pvmove_lv_ready() {
 
 	test -e LOCAL_LVMPOLLD && die "Waiting for lvmpolld timed out"
 	die "Waiting for pvmove LV to get activated has timed out"
-
-	# TODO: remove, uneedeed ??
-	# Adding settle here, to avoid remove, before processing of 'add' is finished
-	# (masking systemd-udevd issue)
-	#udev_wait 2 || true
 }
 
 # Holds device open with sleep which automatically expires after given timeout
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index c18467c87..872db041e 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -53,10 +53,10 @@ cmd3=(pvmove -i1 $backgroundarg $mode -n $vg1/$lv1 "$dev4" "$dev6")
 
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
 	"${cmd2[@]}" &
 	"${cmd3[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove0" "$vg-pvmove1" "$vg1-pvmove0"
-        lvs -a $vg $vg1
+	aux wait_pvmove_lv_ready "$vg-pvmove1" "$vg1-pvmove0"
 else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd2[@]}"
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 2917318f4..86f24176e 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -42,13 +42,13 @@ cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
+	aux wait_pvmove_lv_ready "$vg-pvmove0"
 	"${cmd2[@]}" &
-	aux wait_pvmove_lv_ready "$vg-pvmove0" "$vg-pvmove1"
+	aux wait_pvmove_lv_ready "$vg-pvmove1"
 else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd1[@]}"
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd2[@]}"
 fi
-
 # remove specific device
 pvmove --abort "$dev1"
 

