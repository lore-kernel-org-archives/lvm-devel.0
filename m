From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Feb 2017 14:41:12 +0000 (UTC)
Subject: master - tests: not slowing work with metadata
Message-ID: <20170222144112.3735D60E67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f44e69f9fc2dc56d1fec02f6303b2a1101cdf47e
Commit:        f44e69f9fc2dc56d1fec02f6303b2a1101cdf47e
Parent:        9712995edd60220cd525c51b6bab9f7bd3b38b5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 21 13:06:00 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 22 15:40:28 2017 +0100

tests: not slowing work with metadata

Slows only data extents on a PV.
---
 test/shell/pvmove-resume-multiseg.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index a2fbf35..0f4e78d 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -33,9 +33,9 @@ test_pvmove_resume() {
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
 	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
 
-	aux delay_dev "$dev4" 0 250
+	aux delay_dev "$dev4" 0 250 $(get first_extent_sector "$dev4"):
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
-	aux delay_dev "$dev5" 0 250
+	aux delay_dev "$dev5" 0 250 $(get first_extent_sector "$dev5"):
 
 	pvmove -i5 "$dev1" "$dev4" &
 	PVMOVE=$!


