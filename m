From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:28 +0000 (UTC)
Subject: master - tests: slowdown mirroring more
Message-ID: <20150413143928.2D6B660F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=391500643cdf7b43783212c87b6b46291e701afa
Commit:        391500643cdf7b43783212c87b6b46291e701afa
Parent:        29467abe59a2027be838aca65368c03d43741b60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 11:01:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:31 2015 +0200

tests: slowdown mirroring more

Since some of test machines are very slow, slowdown mirroring
even more.
---
 test/shell/pvmove-abort-all.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index b2ab2d4..afdd3c8 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -23,8 +23,8 @@ pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
 # Slowdown writes
-aux delay_dev "$dev3" 0 400 $(get first_extent_sector "$dev3"):
-aux delay_dev "$dev6" 0 400 $(get first_extent_sector "$dev6"):
+aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev6" 0 800 $(get first_extent_sector "$dev6"):
 
 for mode in "--atomic" "" ;
 do


