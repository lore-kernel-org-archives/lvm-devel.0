From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:29 +0000 (UTC)
Subject: master - thin: shuffle code
Message-ID: <20121202170229.38C2BA0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0da2842cfec05753154e5516f01e0dfd7331640
Commit:        f0da2842cfec05753154e5516f01e0dfd7331640
Parent:        0be8a9126f9e6e66bce186192fedbb5d841007f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:27:39 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:56:44 2012 +0100

thin: shuffle code

Reorder code lines for next patch.
---
 tools/lvconvert.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76588d2..a75a7fc 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1917,12 +1917,6 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* Rename deactivated metadata LV to have _tmeta suffix */
-	/* Implicit checks if metadata_lv is visible */
-	if (strcmp(metadata_lv->name, name) &&
-	    !lv_rename_update(cmd, metadata_lv, name, 0))
-		return_0;
-
 	/*
 	 * Since we wish to have underlaying dev, to match _tdata
 	 * rename data LV first, also checks for visible LV
@@ -1940,18 +1934,24 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	seg->segtype = lp->segtype;
 	seg->lv->status |= THIN_POOL;
 
-	seg->chunk_size = lp->chunk_size;
-	seg->zero_new_blocks = lp->zero ? 1 : 0;
-	seg->discards = lp->discards;
+	/* Drop reference as attach_pool_data_lv() takes it again */
+	remove_seg_from_segs_using_this_lv(data_lv, seg);
+	if (!attach_pool_data_lv(seg, data_lv))
+		return_0;
+
 	seg->low_water_mark = 0;
 	seg->transaction_id = 0;
+	seg->chunk_size = lp->chunk_size;
+	seg->discards = lp->discards;
+	seg->zero_new_blocks = lp->zero ? 1 : 0;
 
-	if (!attach_pool_metadata_lv(seg, metadata_lv))
+	/* Rename deactivated metadata LV to have _tmeta suffix */
+	/* Implicit checks if metadata_lv is visible */
+	if (strcmp(metadata_lv->name, name) &&
+	    !lv_rename_update(cmd, metadata_lv, name, 0))
 		return_0;
 
-	/* Drop reference as attach_pool_data_lv() takes it again */
-	remove_seg_from_segs_using_this_lv(data_lv, seg);
-	if (!attach_pool_data_lv(seg, data_lv))
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
 		return_0;
 
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))


