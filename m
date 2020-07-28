From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Jul 2020 15:39:31 +0000 (GMT)
Subject: master - tests: Adapt RAID test to changes
Message-ID: <20200728153931.221C638708AF@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e12bdd591a1e60f055baee6cf5e9a144ea245a33
Commit:        e12bdd591a1e60f055baee6cf5e9a144ea245a33
Parent:        7a507583d97c1f4b11d5f1a94958f65cf42b6f9f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 28 17:36:57 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 28 17:36:57 2020 +0200

tests: Adapt RAID test to changes

Change 3c9177fdc0b8 causes a conversion of raid1 volume to a raid1 with
the same number of legs succeed with a warning.
---
 test/shell/lvconvert-m-raid1-degraded.sh | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-m-raid1-degraded.sh b/test/shell/lvconvert-m-raid1-degraded.sh
index 05c3e893c..c3f70855e 100644
--- a/test/shell/lvconvert-m-raid1-degraded.sh
+++ b/test/shell/lvconvert-m-raid1-degraded.sh
@@ -33,8 +33,10 @@ aux disable_dev "$dev1"
 vgreduce --force --removemissing $vg
 check raid_leg_status $vg $lv "DA"
 
-# Conversion to 2 legs must fail on degraded 2-legged raid1 LV
-not lvconvert -y -m1 $vg/$lv
+# Conversion to 2 legs does nothing on degraded 2-legged raid1 LV
+lvconvert -y -m1 $vg/$lv 2>&1 | tee out
+grep "already has 2 images" out
+# Check it remains degraded after the successful "conversion"
 check raid_leg_status $vg $lv "DA"
 
 # Repair has to succeed


