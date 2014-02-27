From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 12:01:30 +0000 (UTC)
Subject: master - snapshot: correct previous snapshot commit
Message-ID: <20140227120130.14A5B60311@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d00fc1de784cee27d6ddb1b045a67c930f743074
Commit:        d00fc1de784cee27d6ddb1b045a67c930f743074
Parent:        1769eddde7dcdd16716d646e14487cc1df6a3efc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 27 12:55:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 13:00:49 2014 +0100

snapshot: correct previous snapshot commit

Condition was swapped - however since it's been based on 'random'
memory content it's been missed as attribute has not been set.

So now we have quite a few possible results when testing.

We have old status without separate metadata and
we have kernels with fixed snapshot leak bug.

(in-release update)
---
 lib/metadata/snapshot_manip.c |    4 ++--
 lib/snapshot/snapshot.c       |    3 +++
 test/shell/snapshot-usage.sh  |   31 ++++++++++++++++++++++++-------
 3 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 25fee76..8fcab0c 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -46,9 +46,9 @@ static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
 	    segtype->ops->target_present &&
 	    segtype->ops->target_present(cmd, NULL, &attrs) &&
 	    (attrs & SNAPSHOT_FEATURE_FIXED_LEAK))
-		return (n_chunks + 63) / 64;
+		return 0;
 
-	return 0;
+	return (n_chunks + 63) / 64;
 }
 
 static uint64_t _cow_max_size(struct cmd_context *cmd, uint64_t origin_size, uint32_t chunk_size)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 0b7b845..64919b0 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -165,6 +165,9 @@ static int _snap_target_present(struct cmd_context *cmd,
 			log_very_verbose("Target snapshot may leak metadata.");
 	}
 
+	if (attributes)
+		*attributes = _snap_attrs;
+
 	/* TODO: test everything at once */
 	if (seg && (seg->status & MERGING)) {
 		if (!_snap_merge_checked) {
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index cb60556..bd0723d 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -33,6 +33,25 @@ vgcreate -s 4M $vg $(cat DEVICES)
 TSIZE=15P
 aux can_use_16T || TSIZE=15T
 
+# With different snapshot target driver we may obtain different results.
+# Older targets have metadata leak bug which needs extra compenstion.
+# Ancient targets do not even provide separate info for metadata.
+EXPECT1="16.00k"
+EXPECT2="512.00k"
+EXPECT3="32.00k"
+EXPECT4="66.67"
+if aux target_at_least dm-snapshot 1 10 0 ; then
+	# Extra metadata size
+	EXPECT4="0.00"
+
+	if aux target_at_least dm-snapshot 1 12 0 ; then
+		# When fixed leak, expect smaller sizes
+		EXPECT1="12.00k"
+		EXPECT2="384.00k"
+		EXPECT3="28.00k"
+	fi
+fi
+
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
 aux extend_filter_LVMTEST
@@ -86,12 +105,12 @@ lvcreate -an -Zn -l1 -n $lv1 $vg1
 not lvcreate -s -l1 $vg1/$lv1
 not lvcreate -s -l3 $vg1/$lv1
 lvcreate -s -l30 -n $lv2 $vg1/$lv1
-check lv_field $vg1/$lv2 size "12.00k"
+check lv_field $vg1/$lv2 size "$EXPECT1"
 
 not lvcreate -s -c512 -l512 $vg1/$lv1
 lvcreate -s -c128 -l1700 -n $lv3 $vg1/$lv1
 # 3 * 128
-check lv_field $vg1/$lv3 size "384.00k"
+check lv_field $vg1/$lv3 size "$EXPECT2"
 lvremove -ff $vg1
 
 lvcreate -aey -l20 $vg1
@@ -110,7 +129,7 @@ lvextend --use-policies $vg1/lvol1
 check lv_field $vg1/lvol1 size "18.00k"
 
 lvextend -l+33 $vg1/lvol1
-check lv_field $vg1/lvol1 size "32.00k"
+check lv_field $vg1/lvol1 size "$EXPECT3"
 
 fill 20K
 lvremove -f $vg1
@@ -138,14 +157,12 @@ fsck -n "$DM_DEV_DIR/$vg1/snap"
 # This test would trigger read of weird percentage for undeleted header
 # And since older snapshot target counts with metadata sectors
 # we have 2 valid results  (unsure about correct version number)
-EXPECT="0.00"
-aux target_at_least dm-snapshot 1 10 0 || EXPECT="66.67"
-check lv_field $vg1/snap data_percent "$EXPECT"
+check lv_field $vg1/snap data_percent "$EXPECT4"
 
 vgremove -ff $vg1
 
 # Can't test >= 16T devices on 32bit
-if test "$TSIZE" -eq 15P ; then
+if test "$TSIZE" = 15P ; then
 
 # Check usability with largest extent size
 pvcreate "$DM_DEV_DIR/$vg/$lv"


