From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:38:57 -0400
Subject: master - thin: properly check for status for max sizes metadata
Message-ID: <201704121938.v3CJcvAl012266@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=109532290138d3b8b535457150052b6bda4f797c
Commit:        109532290138d3b8b535457150052b6bda4f797c
Parent:        3503ef23e30da87f16b881248be92842a774d7d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 8 19:38:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:34:08 2017 +0200

thin: properly check for status for max sizes metadata

When metadata LV size was over DM_THIN_MAX_METADATA_SIZE sectors,
the info() routine was incorrectly trying to match bigger size,
while we do never pass any bigger device.

Fixing a case, where lvs should be displaying status for metadata
LV with 16GB size.
---
 WHATS_NEW                       |    1 +
 lib/activate/dev_manager.c      |    5 +++++
 test/shell/lvcreate-thin-big.sh |    5 +++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a597c42..bc958e2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.170 - 
 ==================================
+  Look for limited thin pool metadata size when using 16G metadata.
   Add lvconvert pool creation rule disallowing options with poolmetadata.
   Fix lvconvert when the same LV is incorrectly reused in options.
   Fix lvconvert VG name validation in option values.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a2e399d..8f71771 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -260,6 +260,11 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		start *= seg_status->seg->le;
 		length *= _seg_len(seg_status->seg);
 
+		/* Uses max DM_THIN_MAX_METADATA_SIZE sectors for metadata device */
+		if (lv_is_thin_pool_metadata(seg_status->seg->lv) &&
+		    (length > DM_THIN_MAX_METADATA_SIZE))
+			length = DM_THIN_MAX_METADATA_SIZE;
+
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 9abc1fd..da7812f 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -37,6 +37,11 @@ lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
 grep "WARNING: Maximum" out
 check lv_field $vg/pool1_tmeta size "2.00m"
 check lv_field $vg/pool2_tmeta size "16.00g"
+
+# Check can start and see thinpool with metadata size above kernel limit
+lvcreate -L4M --poolmetadatasize 16G -T $vg/poolM
+check lv_field $vg/poolM data_percent "0.00"
+
 lvremove -ff $vg
 
 # Test automatic calculation of pool metadata size


