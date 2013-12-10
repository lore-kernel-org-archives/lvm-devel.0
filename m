From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Dec 2013 10:18:55 +0000 (UTC)
Subject: master - cleanup: share segtype macros
Message-ID: <20131210101855.5B554601DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99d5b4b807f95ac1845526dc23553ef6442f883e
Commit:        99d5b4b807f95ac1845526dc23553ef6442f883e
Parent:        cf857ecabdb3ef54e42a326d08c33b0518a5b3e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 10:45:21 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 11:16:53 2013 +0100

cleanup: share segtype macros

Write query macro just once.
---
 lib/metadata/segtype.h |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 1a23658..2c02d1b 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -43,30 +43,30 @@ struct dev_manager;
 #define SEG_THIN_VOLUME		0x00001000U
 #define SEG_UNKNOWN		0x80000000U
 
-#define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
+#define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
+#define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
+#define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
+#define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
+#define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
+
+#define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
+#define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
+#define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
-#define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
-#define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
-#define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
-#define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
-#define seg_is_thin(seg)	((seg)->segtype->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
-#define seg_is_thin_pool(seg)	((seg)->segtype->flags & SEG_THIN_POOL ? 1 : 0)
-#define seg_is_thin_volume(seg)	((seg)->segtype->flags & SEG_THIN_VOLUME ? 1 : 0)
+#define seg_is_striped(seg)	segtype_is_striped((seg)->segtype)
+#define seg_is_thin(seg)	segtype_is_thin((seg)->segtype)
+#define seg_is_thin_pool(seg)	segtype_is_thin_pool((seg)->segtype)
+#define seg_is_thin_volume(seg)	segtype_is_thin_volume((seg)->segtype)
+#define seg_is_virtual(seg)	segtype_is_virtual((seg)->segtype)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
 #define seg_unknown(seg)	((seg)->segtype->flags & SEG_UNKNOWN ? 1 : 0)
 
-#define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
-#define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
-#define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
-#define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
-#define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
-#define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
-#define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
-
 struct segment_type {
 	struct dm_list list;		/* Internal */
 	struct cmd_context *cmd;	/* lvm_register_segtype() sets this. */


