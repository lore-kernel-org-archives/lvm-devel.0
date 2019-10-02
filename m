From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 2 Oct 2019 11:15:41 -0400
Subject: stable-2.02 - test: add checks for not 100% sync ratio after initiation of check/repair
Message-ID: <201910021515.x92FFfNA004036@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a087da2f51e2b455a056bcf0550cb02a65d40a53
Commit:        a087da2f51e2b455a056bcf0550cb02a65d40a53
Parent:        1f970f590f969d5a3d8b9d458ae257bf93c00432
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 2 14:48:53 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 2 17:03:49 2019 +0200

test: add checks for not 100% sync ratio after initiation of check/repair

Related: rhbz1640630
---
 test/shell/lvchange-raid.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 1972a68..3a9ed60 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -139,6 +139,7 @@ run_writemostly_check() {
 	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
 }
 
+
 # run_syncaction_check <VG> <LV>
 run_syncaction_check() {
 	local device
@@ -183,17 +184,20 @@ run_syncaction_check() {
 	# "check" should find discrepancies but not change them
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
+	not lv_field $vg/$lv sync_percent "100.00"
 	aux wait_for_sync $vg $lv
 	check lv_attr_bit health $vg/$lv "m"
 	not check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# "repair" will fix discrepancies
 	lvchange --syncaction repair $vg/$lv
+	not lv_field $vg/$lv sync_percent "100.00"
 	aux wait_for_sync $vg $lv
 
 	# Final "check" should show no mismatches
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
+	not lv_field $vg/$lv sync_percent "100.00"
 	aux wait_for_sync $vg $lv
 	check lv_attr_bit health $vg/$lv "-"
 	check lv_field $vg/$lv raid_mismatch_count "0"


