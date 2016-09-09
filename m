From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:25 +0000 (UTC)
Subject: master - tests: increate delay for raid rebuild
Message-ID: <20160909190025.B17C86066E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6166cea5bf211501715a314dd891f27096e3bfe7
Commit:        6166cea5bf211501715a314dd891f27096e3bfe7
Parent:        06e36fb43436c9e0659fbb630536a2b370163759
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 20:24:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:59:21 2016 +0200

tests: increate delay for raid rebuild

Delay writes just to usable extents on a PV
(so lvm2 metadata update remains fast).
Raise delay to 10ms for write.
---
 test/shell/lvchange-rebuild-raid.sh |    4 ++--
 test/shell/lvcreate-raid-nosync.sh  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 2c04549..e1eb6b4 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -19,9 +19,9 @@ aux have_raid 1 3 2 || skip
 aux prepare_vg 8
 
 # Delay 1st leg so that rebuilding status characters can be read
-for d in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8"
+for d in $(< DEVICES)
 do
-	aux delay_dev $d 0 3
+	aux delay_dev "$d" 0 10 $(get first_extent_sector "$d")
 done
 
 # rhbz 1064592
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 4c6da46..71eeefc 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -21,7 +21,7 @@ aux prepare_vg 6
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 1
+aux delay_dev "$dev1" 0 10 $(get first_extent_sector "$dev1")
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta


