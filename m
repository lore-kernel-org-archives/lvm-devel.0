From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 13 Oct 2020 11:17:10 +0000 (GMT)
Subject: master - Revert "tests: Adapt RAID test to changes"
Message-ID: <20201013111710.4D2173877036@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53db14171c6b516058486b2a80eaa17af32a246b
Commit:        53db14171c6b516058486b2a80eaa17af32a246b
Parent:        ee43ec5782c3fe23b99e84da86fa3f43d3eb1c56
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Oct 13 13:15:16 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 13 13:15:16 2020 +0200

Revert "tests: Adapt RAID test to changes"

The cpnversion of degraded RAID should still report a failure.

This reverts commit e12bdd591a1e60f055baee6cf5e9a144ea245a33.
---
 test/shell/lvconvert-m-raid1-degraded.sh | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-m-raid1-degraded.sh b/test/shell/lvconvert-m-raid1-degraded.sh
index c3f70855e..05c3e893c 100644
--- a/test/shell/lvconvert-m-raid1-degraded.sh
+++ b/test/shell/lvconvert-m-raid1-degraded.sh
@@ -33,10 +33,8 @@ aux disable_dev "$dev1"
 vgreduce --force --removemissing $vg
 check raid_leg_status $vg $lv "DA"
 
-# Conversion to 2 legs does nothing on degraded 2-legged raid1 LV
-lvconvert -y -m1 $vg/$lv 2>&1 | tee out
-grep "already has 2 images" out
-# Check it remains degraded after the successful "conversion"
+# Conversion to 2 legs must fail on degraded 2-legged raid1 LV
+not lvconvert -y -m1 $vg/$lv
 check raid_leg_status $vg $lv "DA"
 
 # Repair has to succeed


