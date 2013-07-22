From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 22 Jul 2013 13:50:48 +0000 (UTC)
Subject: master - TEST: Support testing new RAID features in RHEL6 kernels
Message-ID: <20130722135048.8CF8C611E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=081308af30b32b86b690c727125f0615e5a7a7fb
Commit:        081308af30b32b86b690c727125f0615e5a7a7fb
Parent:        3fdb45d0402ac9b404f4277d7954043ea257f019
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jul 22 08:50:27 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jul 22 08:50:27 2013 -0500

TEST: Support testing new RAID features in RHEL6 kernels

We check the version number of dm-raid before testing certain
features to make sure they are present.  However, this has
become somewhat complicated by the fact that the version #'s
in the upstream kernel and the REHL6 kernel have been diverging.
This has been a necessity because the upstream kernel has
undergone ABI changes that have necessitated a bump in the
'Y' component of the version #, while the RHEL6 kernel has not.
Thus, we need to know that the ABI has not changed but the
features have been added.  So, the current version #'ing stands
as follows:

RHEL6   Upstream   Comment
======|==========|========
** Same until version 1.3.1 **
------|----------|--------
 N/A  |   1.4.0  | Non-functional change.
      |          | Removes arg from mapping function.
------|----------|--------
1.3.2 |   1.4.1  | RAID10 fix redundancy validation checks.
------|----------|--------
1.3.5 |   1.4.2  | Add RAID10 "far" and "offset" algorithm support.
      |          | Note this feature came later in RHEL6 as part of
      |          | a separate update/feature.
------|----------|--------
1.3.3 |   1.5.0  | Add message interface to allow manipulation of
      |          | the sync_action.
      |          | New status (STATUSTYPE_INFO) fields: sync_action
      |          | and mismatch_cnt.
------|----------|--------
1.3.4 |   1.5.1  | Add ability to restore transiently failed devices
      |          | on resume.
------|----------|--------
1.3.5 |   1.5.2  | 'mismatch_cnt' is zero unless [last_]sync_action
      |          | is "check".
------|----------|--------

To simplify, writemostly/writebehind, scrubbing, and transient device
failure restoration are all tested based on the same version
requirements: (1.3.5 < V < 1.4.0) || (V > 1.5.2).  Since kernel
support for writemostly/writebehind has been around for some time,
this could mean a reduction in the scope of kernels tested for this
feature.  I don't view this as much of a problem, since support for
this feature was only recently added to LVM.  Thus, the user would
have to be using a very recent LVM version with an older kernel.
---
 test/shell/lvchange-raid.sh |   55 +++++++++++++-----------------------------
 1 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 1e20934..2e62312 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -11,8 +11,15 @@
 
 . lib/test
 
-# dm-raid v1.4.1+ contains RAID10 support
-aux target_at_least dm-raid 1 4 1 || skip
+# Writemostly has been in every version since the begining
+# Device refresh in 1.5.1 upstream and 1.3.4 < x < 1.4.0 in RHEL6
+# Sync action    in 1.5.0 upstream and 1.3.3 < x < 1.4.0 in RHEL6
+# Proper mismatch count 1.5.2 upstream,1.3.5 < x < 1.4.0 in RHEL6
+#
+# We will simplify and simple test for 1.5.2 and 1.3.5 < x < 1.4.0
+aux target_at_least dm-raid 1 3 5 && 
+  ! aux target_at_least dm-raid 1 4 0 ||
+  aux target_at_least dm-raid 1 5 2 || skip
 
 aux prepare_vg 6
 
@@ -140,24 +147,6 @@ run_syncaction_check() {
 
 	seek=$(($seek + $size)) # Jump halfway through the RAID image
 
-	# Check all is normal
-	if ! aux target_at_least dm-raid 1 5 2; then
-		# As of version 1.5.2, the mismatch_cnt is non-zero only
-		# after a 'check' sync action has been performed and only
-		# if discrepancies have been found.
-		#
-		# Previous to this version, mismatch_cnt was basically
-		# undefined unless it was queried after a 'check' was
-		# performed.  This meant that unless a 'check' was done,
-		# the 'm' character in the 'lvs' output could show up
-		# randomly.
-
-		# Run "check" should turn up clean
-		lvchange --syncaction check $1/$2
-		aux wait_for_sync $1 $2
-		sync
-	fi
-
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
 	[ `lvs --noheadings -o raid_mismatch_count $1/$2` == 0 ]
 
@@ -228,32 +217,22 @@ run_refresh_check() {
 # run_checks <VG> <LV> [snapshot_dev]
 run_checks() {
 	# Without snapshots
-	if aux target_at_least dm-raid 1 1 0; then
-		run_writemostly_check $1 $2
-	fi
+	run_writemostly_check $1 $2
 
-	if aux target_at_least dm-raid 1 5 0; then
-		run_syncaction_check $1 $2
-	fi
+	run_syncaction_check $1 $2
 
-	if aux target_at_least dm-raid 1 5 1; then
-		run_refresh_check $1 $2
-	fi
+	run_refresh_check $1 $2
 
 	# With snapshots
 	if [ ! -z $3 ]; then
 		lvcreate -s $1/$2 -l 4 -n snap $3
-		if aux target_at_least dm-raid 1 1 0; then
-			run_writemostly_check $1 $2
-		fi
 
-		if aux target_at_least dm-raid 1 5 0; then
-			run_syncaction_check $1 $2
-		fi
+		run_writemostly_check $1 $2
+
+		run_syncaction_check $1 $2
+
+		run_refresh_check $1 $2
 
-		if aux target_at_least dm-raid 1 5 1; then
-			run_refresh_check $1 $2
-		fi
 		lvremove -ff $1/snap
 	fi
 }


