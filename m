From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 18:10:31 +0000 (UTC)
Subject: master - tests: handle missing delay_dev
Message-ID: <20151109181031.18985615D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0cb92cbb109eb21ef7570058d7b18d5c8ad2e98
Commit:        a0cb92cbb109eb21ef7570058d7b18d5c8ad2e98
Parent:        6762eec88c0b9ee85ab77423b41bb0e8b9b0d67d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 19:06:55 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 19:07:53 2015 +0100

tests: handle missing delay_dev

Try to run as much of test which could run without delay_dev.
---
 test/shell/pvmove-abort-all.sh       |    4 ++++
 test/shell/pvmove-abort.sh           |    4 ++++
 test/shell/pvmove-restart.sh         |    1 +
 test/shell/pvmove-resume-1.sh        |    1 +
 test/shell/pvmove-resume-multiseg.sh |    1 +
 5 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 2867163..f09f58e 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -45,6 +45,8 @@ cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 cmd3=(pvmove -i1 $backgroundarg $mode -n $vg1/$lv1 "$dev4" "$dev6")
 
+if test -e HAVE_DM_DELAY; then
+
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
@@ -59,6 +61,8 @@ else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd3[@]}"
 fi
 
+fi
+
 # test removal of all pvmove LVs
 pvmove --abort
 
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 6b807ac..336e92a 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -34,6 +34,8 @@ lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 
+if test -e HAVE_DM_DELAY; then
+
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
@@ -52,6 +54,8 @@ get lv_field $vg name -a | tee out
 not grep "^\[pvmove0\]" out
 grep "^\[pvmove1\]" out
 
+fi
+
 # remove any remaining pvmoves in progress
 pvmove --abort
 
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 4f93983..3f2b029 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -22,6 +22,7 @@ vgextend $vg "$dev3"
 # Slowdown writes
 # (FIXME: generates interesting race when not used)
 aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
+test -e HAVE_DM_DELAY || skip
 
 for mode in "--atomic" ""
 do
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 5bd0e45..f4ba5fa 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -33,6 +33,7 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l30 -n $lv1 $vg1
 
 	aux delay_dev "$dev3" 0 1000 $(get first_extent_sector "$dev3"):
+	test -e HAVE_DM_DELAY || { lvremove -f $vg $vg1; return 0; }
 	aux delay_dev "$dev4" 0 1000 $(get first_extent_sector "$dev4"):
 
 	pvmove -i5 "$dev1" &
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index c113252..6982fef 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -33,6 +33,7 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
 
 	aux delay_dev "$dev4" 0 250
+	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
 	aux delay_dev "$dev5" 0 250
 
 	pvmove -i5 "$dev1" "$dev4" &


