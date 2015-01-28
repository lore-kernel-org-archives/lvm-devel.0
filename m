From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 14:16:31 +0000 (UTC)
Subject: master - thin: preserve chunksize with lvconvert
Message-ID: <20150128141631.28A3B61065@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f1309080a462988e10c11a328356a6c5c22dd6e
Commit:        4f1309080a462988e10c11a328356a6c5c22dd6e
Parent:        d2d3f0d747a509178a46f85b6384febde063c633
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 15:12:38 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 15:15:52 2015 +0100

thin: preserve chunksize with lvconvert

When repairing thin pool or swapping thin pool metadata,
preserve  chunk_size property and avoid to be automatically changed
later in the code to better match thin pool metadata size.
---
 WHATS_NEW                           |    1 +
 test/shell/lvconvert-repair-thin.sh |    9 ++++++++-
 tools/lvconvert.c                   |    1 +
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 45a02d6..92b62a6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Preserve chunk size with repair and metadata swap of a thin pool.
   Fix raid --splitmirror 1 functionality (2.02.112).
   Fix tree preload to handle splitting raid images.
   Do not support unpartitioned DASD devices.
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 0e9534b..73f061c 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -24,7 +24,9 @@ aux have_thin 1 0 0 || skip
 aux prepare_vg 4
 
 # Create LV
-lvcreate -T -L20 -V10 -n $lv1 $vg/pool  "$dev1" "$dev2"
+# TODO: investigate problem with --zero n and my repairable damage trick
+#lvcreate -T -L20 -V10 -n $lv1 $vg/pool --discards ignore --zero n --chunksize 128 "$dev1" "$dev2"
+lvcreate -T -L20 -V10 -n $lv1 $vg/pool --chunksize 128 --discards ignore "$dev1" "$dev2"
 lvcreate -T -V10 -n $lv2 $vg/pool
 
 mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
@@ -71,6 +73,11 @@ lvchange -an $vg
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
 
+# Check pool still preserves its original settings
+check lv_field $vg/pool chunksize "128.00k"
+check lv_field $vg/pool discards "ignore"
+check lv_field $vg/pool zero "zero"
+
 # Activate pool - this should now work
 vgchange -ay $vg
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c7acd5d..20f017a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2956,6 +2956,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
+		lp->passed_args |= PASS_ARG_CHUNK_SIZE | PASS_ARG_DISCARDS | PASS_ARG_ZERO;
 		seg = first_seg(pool_lv);
 
 		/* Normally do NOT change chunk size when swapping */


