From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 15:01:07 +0000 (UTC)
Subject: master - tests: slowdown pvmove devs more
Message-ID: <20150402150107.1F4CA60960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a701d337d4a8b2bbabc8e0930f79018b7f3d4305
Commit:        a701d337d4a8b2bbabc8e0930f79018b7f3d4305
Parent:        196602524515756b2ac504937ec6d61d22ba49ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 16:02:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 16:02:06 2015 +0200

tests: slowdown pvmove devs more

Once pvmove is running - slow it even more
since some test machines tend to be very very slow.
---
 test/shell/pvmove-abort-all.sh |    3 +++
 test/shell/pvmove-abort.sh     |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 85ee457..3b561eb 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -41,8 +41,11 @@ pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove1" 300
+aux delay_dev "$dev3" 0 1000
+
 pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
 aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
+aux delay_dev "$dev6" 0 1000
 
 # test removal of all pvmove LVs
 pvmove  --abort
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 6798b59..4ad3e62 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -36,6 +36,9 @@ aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove1" 300
 
+# Slow things even more for very slow machines....
+aux delay_dev "$dev3" 0 1000
+
 # remove specific device
 pvmove --abort "$dev1"
 


