From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:45 +0000 (UTC)
Subject: master - validation: use validate_pool_chunk_size
Message-ID: <20141006133345.8667060DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d272ba0ada6deae264e44705a4ce3b7ece93cd0
Commit:        8d272ba0ada6deae264e44705a4ce3b7ece93cd0
Parent:        6c4429900645959966784dd0f0045ec0c4f6233f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 11:54:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

validation: use validate_pool_chunk_size

We could validation pool chunk size with a single function.
---
 lib/metadata/merge.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 0afe596..ad918f1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -224,13 +224,9 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					inc_error_count;
 				}
 
-				if ((seg_is_thin_pool(seg) &&
-				     ((seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-				     (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE))) ||
-				    (seg_is_cache_pool(seg) &&
-				     ((seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
-				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)))) {
-					log_error("LV %s: %s segment %u has chunk size %u out of range.",
+				if (seg_is_pool(seg) &&
+				    !validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size)) {
+					log_error("LV %s: %s segment %u has invalid chunk size %u.",
 						  lv->name, seg->segtype->name, seg_count, seg->chunk_size);
 					inc_error_count;
 				}


