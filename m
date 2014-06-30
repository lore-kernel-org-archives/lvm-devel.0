From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 30 Jun 2014 10:25:19 +0000 (UTC)
Subject: master - cleanup: more lv_is_ functions
Message-ID: <20140630102519.A2175611C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ada6852162c2dc2ee0f92220c29fe5f0959f510
Commit:        2ada6852162c2dc2ee0f92220c29fe5f0959f510
Parent:        6da14a82c665dd8be0039548a54a87f182508cd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 27 00:02:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 30 12:16:08 2014 +0200

cleanup: more lv_is_ functions

---
 lib/metadata/metadata-exported.h |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a7d30b3..eece882 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -163,17 +163,21 @@
 #define vg_is_archived(vg)	(((vg)->status & ARCHIVED_VG) ? 1 : 0)
 
 #define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)
-#define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
-#define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)
+#define lv_is_thin_volume(lv)	(((lv)->status & (THIN_VOLUME)) ? 1 : 0)
+#define lv_is_thin_pool(lv)	(((lv)->status & (THIN_POOL)) ? 1 : 0)
 #define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
-#define lv_is_thin_pool_data(lv)	((lv)->status & THIN_POOL_DATA ? 1 : 0)
-#define lv_is_thin_pool_metadata(lv)	((lv)->status & THIN_POOL_METADATA ? 1 : 0)
-#define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
-#define lv_is_rlog(lv)		((lv)->status & REPLICATOR_LOG ? 1 : 0)
-
-#define lv_is_thin_type(lv)	((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA) ? 1 : 0)
-#define lv_is_mirror_type(lv)	((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE) ? 1 : 0)
+#define lv_is_thin_pool_data(lv)	(((lv)->status & (THIN_POOL_DATA)) ? 1 : 0)
+#define lv_is_thin_pool_metadata(lv)	(((lv)->status & (THIN_POOL_METADATA)) ? 1 : 0)
+#define lv_is_mirrored(lv)	(((lv)->status & (MIRRORED)) ? 1 : 0)
+#define lv_is_rlog(lv)		(((lv)->status & (REPLICATOR_LOG)) ? 1 : 0)
+
+#define lv_is_thin_type(lv)	(((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA)) ? 1 : 0)
+#define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE)) ? 1 : 0)
+#define lv_is_mirror_image(lv)	(((lv)->status & (MIRROR_IMAGE)) ? 1 : 0)
+#define lv_is_mirror_log(lv)	(((lv)->status & (MIRROR_LOG)) ? 1 : 0)
 #define lv_is_raid(lv)		(((lv)->status & (RAID)) ? 1 : 0)
+#define lv_is_raid_image(lv)	(((lv)->status & (RAID_IMAGE)) ? 1 : 0)
+#define lv_is_raid_metadata(lv)	(((lv)->status & (RAID_META)) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
 #define lv_is_cache(lv)		(((lv)->status & (CACHE)) ? 1 : 0)
@@ -182,8 +186,8 @@
 #define lv_is_cache_pool_metadata(lv)	(((lv)->status & (CACHE_POOL_METADATA)) ? 1 : 0)
 #define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
-#define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
-#define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
+#define lv_is_virtual(lv)	(((lv)->status & (VIRTUAL)) ? 1 : 0)
+#define lv_is_pool_metadata_spare(lv)	(((lv)->status & (POOL_METADATA_SPARE)) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
 typedef enum {


