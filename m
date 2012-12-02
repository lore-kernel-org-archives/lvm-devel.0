From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:38 +0000 (UTC)
Subject: master - thin: lvconvert supports swapping metadata device
Message-ID: <20121202170238.AB86BA0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99018b37ee9e916662ebd482ac8fe0f36bbd7ac8
Commit:        99018b37ee9e916662ebd482ac8fe0f36bbd7ac8
Parent:        97f8454eccefe29464336ba1823448f4d1fa009b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:40:07 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 18:01:27 2012 +0100

thin: lvconvert supports swapping metadata device

Support swapping of metadata device if the thin pool already
exists. This way it's easy to i.e. resize metadata or their
repair operation.

User may create some empty LV, replace existing metadata
or dump and restore them into bigger LV.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   11 ++++++++++-
 tools/lvconvert.c  |   50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index be2ebea..ceb2295 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lvconvert support to swap thin pool metadata volume.
   Implement internal function detach_pool_metadata_lv().
   Fix lvm2app to return all property sizes in bytes.
   Recognize DM_DISABLE_UDEV environment variable for a complete fallback.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 48345a9..4fe9bdd 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -231,6 +231,13 @@ Specifies thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
 Thin pool is specified with the option
 \fB\-\-thinpool\fP.
+When the specified thin pool already exists,
+the thin pool's metadata volume will be swapped with the given LV.
+Properties of the thin pool like chunk size, discards or zero
+are preserved by default in this case.
+It can be useful for thin pool metadata repair or its offline resize,
+since the content of metadata becomes accessible for
+thin provisioning tools \fBthin_dump\fP(8) and \fBthin_restore\fP(8).
 .TP
 .BR \-\-poolmetadatasize " " \fIThinPoolMetadataSize [ \fIbBsSkKmMgG ]
 Sets the size of thin pool's metadata logical volume,
@@ -375,4 +382,6 @@ available in the volume group.
 .BR lvextend (8),
 .BR lvreduce (8),
 .BR lvdisplay (8),
-.BR lvscan (8)
+.BR lvscan (8),
+.BR thin_dump(8),
+.BR thin_restore(8)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2ef8d86..d0429d8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1794,10 +1794,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 {
 	int r = 0;
 	char *name;
+	const char *old_name;
 	int len;
 	struct lv_segment *seg;
 	struct logical_volume *data_lv;
 	struct logical_volume *metadata_lv;
+	struct logical_volume *pool_metadata_lv;
 
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s/%s.",
@@ -1805,7 +1807,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_thin_type(pool_lv)) {
+	if (lv_is_thin_type(pool_lv) && !lp->pool_metadata_lv_name) {
 		log_error("Can't use thin logical volume %s/%s for thin pool data.",
 			  pool_lv->vg->name, pool_lv->name);
 		return 0;
@@ -1864,6 +1866,50 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
+
+		/* Swap normal LV with pool's metadata LV ? */
+		if (lv_is_thin_pool(pool_lv)) {
+			if (!deactivate_lv(cmd, metadata_lv)) {
+				log_error("Aborting. Failed to deactivate thin metadata lv.");
+				return 0;
+			}
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Do you want to swap metadata of %s/%s pool with "
+					  "volume %s/%s? [y/n]: ",
+					  pool_lv->vg->name, pool_lv->name,
+					  pool_lv->vg->name, metadata_lv->name) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+			seg = first_seg(pool_lv);
+			/* Swap names between old and new metadata LV */
+			if (!detach_pool_metadata_lv(seg, &pool_metadata_lv))
+				return_0;
+			old_name = metadata_lv->name;
+			if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
+				return_0;
+			if (!lv_rename_update(cmd, pool_metadata_lv, old_name, 0))
+				return_0;
+
+			if (!arg_count(cmd, chunksize_ARG))
+				lp->chunk_size = seg->chunk_size;
+			else if ((lp->chunk_size != seg->chunk_size) &&
+				 !arg_count(cmd, force_ARG) &&
+				 yes_no_prompt("Do you really want to change chunk size %s to %s for %s/%s "
+					       "pool volume? [y/n]: ", display_size(cmd, seg->chunk_size),
+					       display_size(cmd, lp->chunk_size),
+					       pool_lv->vg->name, pool_lv->name) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+			if (!arg_count(cmd, discards_ARG))
+				lp->discards = seg->discards;
+			if (!arg_count(cmd, zero_ARG))
+				lp->zero = seg->zero_new_blocks;
+
+			goto mda_write;
+		}
+
 		if (!lv_is_active(metadata_lv) &&
 		    !activate_lv_local(cmd, metadata_lv)) {
 			log_error("Aborting. Failed to activate thin metadata lv.");
@@ -1941,6 +1987,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 	seg->low_water_mark = 0;
 	seg->transaction_id = 0;
+
+mda_write:
 	seg->chunk_size = lp->chunk_size;
 	seg->discards = lp->discards;
 	seg->zero_new_blocks = lp->zero ? 1 : 0;


