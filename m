From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:24 +0000 (UTC)
Subject: master - thin: add detach_pool_metadata_lv
Message-ID: <20121202170224.82384A0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6987a353de9476c57831fdcf9cccb5d80e4f505b
Commit:        6987a353de9476c57831fdcf9cccb5d80e4f505b
Parent:        c5e2f08cf9134ebf2d377ad050a707c0268d1444
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 01:28:51 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:56:29 2012 +0100

thin: add detach_pool_metadata_lv

Add internal function detach_pool_metadata_lv().
---
 WHATS_NEW                 |    1 +
 lib/metadata/metadata.h   |    2 ++
 lib/metadata/thin_manip.c |   18 ++++++++++++++++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 43bdb0e..be2ebea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Implement internal function detach_pool_metadata_lv().
   Fix lvm2app to return all property sizes in bytes.
   Recognize DM_DISABLE_UDEV environment variable for a complete fallback.
   Do not verify udev operations if --noudevsync command option is used.
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 7bc7eaf..19bf742 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -460,6 +460,8 @@ int fixup_imported_mirrors(struct volume_group *vg);
  */
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *pool_metadata_lv);
+int detach_pool_metadata_lv(struct lv_segment *pool_seg,
+			    struct logical_volume **pool_metadata_lv);
 int attach_pool_data_lv(struct lv_segment *pool_seg,
 			struct logical_volume *pool_data_lv);
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e7e96df..e2762a0 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -30,6 +30,24 @@ int attach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume *
 	return add_seg_to_segs_using_this_lv(metadata_lv, pool_seg);
 }
 
+int detach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume **metadata_lv)
+{
+	struct logical_volume *lv = pool_seg->metadata_lv;
+
+	if (!lv || !lv_is_thin_pool_metadata(lv) ||
+	    !remove_seg_from_segs_using_this_lv(lv, pool_seg)) {
+		log_error(INTERNAL_ERROR "LV %s is invalid thin pool.", pool_seg->lv->name);
+		return 0;
+	}
+
+	lv_set_visible(lv);
+	lv->status &= ~THIN_POOL_METADATA;
+	*metadata_lv = lv;
+	pool_seg->metadata_lv = NULL;
+
+	return 1;
+}
+
 int attach_pool_data_lv(struct lv_segment *pool_seg, struct logical_volume *pool_data_lv)
 {
 	if (!set_lv_segment_area_lv(pool_seg, 0, pool_data_lv, 0, THIN_POOL_DATA))


