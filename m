From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Apr 2015 11:19:14 +0000 (UTC)
Subject: master - tests: extend delay
Message-ID: <20150409111914.5A10E601DE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=249d4a921ca300c746588c7683484aa75442771b
Commit:        249d4a921ca300c746588c7683484aa75442771b
Parent:        1a7c9ce3bd6c80ec043af3dc8b88f63b31035e21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 9 13:16:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 9 13:16:53 2015 +0200

tests: extend delay

400 was appeared to be good value in pvmove-abort.sh
so use also in abort-all.
---
 test/shell/pvmove-abort-all.sh |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 235ebd8..b2ab2d4 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -23,8 +23,8 @@ pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
 # Slowdown writes
-aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
-aux delay_dev "$dev6" 100 100 $(get first_extent_sector "$dev6"):
+aux delay_dev "$dev3" 0 400 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev6" 0 400 $(get first_extent_sector "$dev6"):
 
 for mode in "--atomic" "" ;
 do
@@ -61,7 +61,6 @@ done
 done
 
 # Restore delayed device back
-aux enable_dev "$dev3"
-aux enable_dev "$dev6"
+aux enable_dev "$dev3" "$dev6"
 
 vgremove -ff $vg $vg1


