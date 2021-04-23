From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:13 +0000 (GMT)
Subject: main - tests: use should for expected state
Message-ID: <20210423210613.63AD03B08C33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64a8505b96548631ed8fb251dce794077402ad77
Commit:        64a8505b96548631ed8fb251dce794077402ad77
Parent:        05eb90db68dcaa89fbfcce52cf122f25488ee69f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 18:28:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

tests: use should for expected state

While we heavily try to spot arrays that are not yet in-sync,
some kernels tends to block our lvm2 command in kernel,
while we resume these smaller raid arrays even for 5 seconds.

But since the result is not really wrong - report these
check failures only as TEST WARNING.
---
 test/shell/lvcreate-raid-nosync.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index c7c2d1535..2818e9450 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -60,7 +60,7 @@ done
 
 # raid1 supports resynchronization
 lvcreate --type raid1 -m 2 -Zn -l 4 -n $lv1 $vg
-check raid_leg_status $vg $lv1 "aaa"
+should check raid_leg_status $vg $lv1 "aaa"
 _sync "AAA"
 
 # raid1 supports --nosync
@@ -72,7 +72,7 @@ for r in $segtypes
 do
 	# raid4/5 support resynchronization
 	lvcreate --type $r -Zn -i 3 -L10 -n $lv1 $vg
-	check raid_leg_status $vg $lv1 "aaaa"
+	should check raid_leg_status $vg $lv1 "aaaa"
 	_sync "AAAA"
 
 	# raid4/5 support --nosync
@@ -83,7 +83,7 @@ done
 
 # raid6 supports resynchronization
 lvcreate --type raid6 -Zn -i 3 -l 4 -n $lv1 $vg
-check raid_leg_status $vg $lv1 "aaaaa"
+should check raid_leg_status $vg $lv1 "aaaaa"
 _sync "AAAAA"
 
 # raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
@@ -91,7 +91,7 @@ not lvcreate --type raid6 --nosync -Zn -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
 lvcreate --type raid10 -m 1 -Zn -i 3 -L10 -n $lv1 $vg
-check raid_leg_status $vg $lv1 "aaaaaa"
+should check raid_leg_status $vg $lv1 "aaaaaa"
 _sync "AAAAAA"
 
 # raid10 supports --nosync


