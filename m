From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 19 Jul 2013 20:25:22 +0000 (UTC)
Subject: master - TEST: Update syncaction test to match latest kernel updates
Message-ID: <20130719202522.B8C0E602D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6aeb54c77cf333952d6459823709cd9cd6df681d
Commit:        6aeb54c77cf333952d6459823709cd9cd6df681d
Parent:        ccc29f17b61b60aa4c5b2286ed8b530234435d8a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Jul 19 15:24:34 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Jul 19 15:24:34 2013 -0500

TEST: Update syncaction test to match latest kernel updates

The mismatch count reported by a dm-raid kernel target used
to be effectively random, unless it was checked after a
"check" scrubbing action had been performed.  Updates to the
kernel now mean that the mismatch count will be 0 unless a
check has been performed and discrepancies had been found.
This has been the intended behaviour all along.

This patch updates the test suite to handle the change.
---
 test/shell/lvchange-raid.sh |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 291928a..1e20934 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -141,17 +141,16 @@ run_syncaction_check() {
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
 	# Check all is normal
-	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$' ||
-		[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]; then
-
-		# I think this is a kernel bug.  It happens randomly after
-		# a RAID device creation.  I think the mismatch count
-		# should not be set unless a check or repair is run.
+	if ! aux target_at_least dm-raid 1 5 2; then
+		# As of version 1.5.2, the mismatch_cnt is non-zero only
+		# after a 'check' sync action has been performed and only
+		# if discrepancies have been found.
 		#
-		# Neil Brown disagrees that it is a bug.  Says mismatch
-		# count can be anything until a 'check' or 'repair' is
-		# run.
-		echo "Strange... RAID has mismatch count after creation."
+		# Previous to this version, mismatch_cnt was basically
+		# undefined unless it was queried after a 'check' was
+		# performed.  This meant that unless a 'check' was done,
+		# the 'm' character in the 'lvs' output could show up
+		# randomly.
 
 		# Run "check" should turn up clean
 		lvchange --syncaction check $1/$2
@@ -176,11 +175,9 @@ run_syncaction_check() {
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
 	[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]
 
-	# "repair" will fix discrepancies and record number fixed
+	# "repair" will fix discrepancies
 	lvchange --syncaction repair $1/$2
 	aux wait_for_sync $1 $2
-	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
-	[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]
 
 	# Final "check" should show no mismatches
 	# 'lvs' should show results


