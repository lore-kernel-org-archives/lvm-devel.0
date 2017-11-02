From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Thu, 2 Nov 2017 11:27:39 -0400
Subject: master - testsuite: Forgot to pull 'should's after fixing RAID4/5/6 mismatch test
Message-ID: <201711021527.vA2FRd2a022505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4129cf5090cd329dceee03df127d6d3644bbaa66
Commit:        4129cf5090cd329dceee03df127d6d3644bbaa66
Parent:        9e8dec2f387d8eaf48195ef38ab7699d4a8385ed
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Nov 2 10:25:46 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Nov 2 10:25:46 2017 -0500

testsuite:  Forgot to pull 'should's after fixing RAID4/5/6 mismatch test

Test will now fail rather than warn if conditions are not met.
---
 test/shell/lvchange-raid.sh |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 604b7f7..e6626d1 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -184,15 +184,8 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-        # FIXME: this needs kernel fix in md-raid
-        # currently let just this test to cause 'warning'
-	if ! get lv_field $vg/$lv lv_attr -a | grep '.*m.$'; then
-		dmsetup status | grep $vg
-		# false
-	fi
-        # FIXME: with fixed kernel this should not fail
-        # add 'wrapper' detecting kernel for this
-	should not check lv_field $vg/$lv raid_mismatch_count "0"
+	check lv_attr_bit health $vg/$lv "m"
+	not check lv_field $vg/$lv raid_mismatch_count "0"
 
 	# "repair" will fix discrepancies
 	lvchange --syncaction repair $vg/$lv
@@ -202,7 +195,7 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-	check lv_attr_bit health $vg/$lv "-" || check lv_attr_bit health $vg/$lv "m"
+	check lv_attr_bit health $vg/$lv "-"
 	check lv_field $vg/$lv raid_mismatch_count "0"
 }
 


