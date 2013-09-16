From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 09:23:16 +0000 (UTC)
Subject: master - tests: use check for raid test
Message-ID: <20130916092316.4BB0C6101B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47b7cc6850091aac9d32070ad3c3a727bae5f188
Commit:        47b7cc6850091aac9d32070ad3c3a727bae5f188
Parent:        9df27c42794652cc663e04c5c751daa549e73194
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 11:15:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 11:22:04 2013 +0200

tests: use check for raid test

Use test-suite built-in check command for this test
(creates better logs, and reduces amount of valgrind-ed commands)
---
 test/shell/lvcreate-raid.sh   |    8 ++++----
 test/shell/lvcreate-raid10.sh |    5 ++---
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index ee56b9c..214b162 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -42,8 +42,8 @@ lvremove -ff $vg
 lvcreate --type raid1 -m 2 -l 2 \
 	--minrecoveryrate 50 --maxrecoveryrate 100 \
 	-n $lv1 $vg
-[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
-[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+check lv_field $vg/$lv1 raid_min_recovery_rate 50
+check lv_field $vg/$lv1 raid_max_recovery_rate 100
 aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
@@ -65,8 +65,8 @@ for i in raid4 \
 	lvcreate --type $i -l 3 -i 3 \
 		--minrecoveryrate 50 --maxrecoveryrate 100 \
 		-n $lv1 $vg
-	[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
-	[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+	check lv_field $vg/$lv1 raid_min_recovery_rate 50
+	check lv_field $vg/$lv1 raid_max_recovery_rate 100
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 933097a..143e869 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -36,15 +36,14 @@ lvremove -ff $vg/$lv1
 lvcreate --type raid10 -m 1 -i 2 -l 2 \
 	--minrecoveryrate 50 --maxrecoveryrate 100 \
 	-n $lv1 $vg
-[ `lvs --noheadings -o raid_min_recovery_rate $vg/$lv1` -eq 50 ]
-[ `lvs --noheadings -o raid_max_recovery_rate $vg/$lv1` -eq 100 ]
+check lv_field $vg/$lv1 raid_min_recovery_rate 50
+check lv_field $vg/$lv1 raid_max_recovery_rate 100
 aux wait_for_sync $vg $lv1
 
 # 2-way mirror, 3-stripes
 lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv2 $vg
 aux wait_for_sync $vg $lv2
 
-
 lvremove -ff $vg
 
 #


