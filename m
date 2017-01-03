From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:15 +0000 (UTC)
Subject: master - cleanup: defines
Message-ID: <20170103135615.25ABD6102C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee784fd28f70eb35e23da91fe935c601e44648aa
Commit:        ee784fd28f70eb35e23da91fe935c601e44648aa
Parent:        377288fe0362dd41f2332a6634f8f1f7e6edccbb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 24 23:24:37 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

cleanup: defines

---
 lib/metadata/segtype.h |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 292b8b6..c20149d 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -144,6 +144,12 @@ struct dev_manager;
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 #define segtype_is_unknown(segtype)	((segtype)->flags & SEG_UNKNOWN ? 1 : 0)
 
+#define segtype_can_split(segtype)	((segtype)->flags & SEG_CAN_SPLIT ? 1 : 0)
+#define segtype_cannot_be_zeroed(segtype) ((segtype)->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
+#define segtype_monitored(segtype)	((segtype)->flags & SEG_MONITORED ? 1 : 0)
+#define segtype_only_exclusive(segtype)	((segtype)->flags & SEG_ONLY_EXCLUSIVE ? 1 : 0)
+#define segtype_can_error_when_full(segtype)	((segtype)->flags & SEG_CAN_ERROR_WHEN_FULL ? 1 : 0)
+
 #define segtype_supports_stripe_size(segtype)	\
 	((segtype_is_striped(segtype) || segtype_is_mirror(segtype) || \
 	  segtype_is_cache(segtype) || segtype_is_cache_pool(segtype) || \
@@ -188,11 +194,11 @@ struct dev_manager;
 #define seg_is_thin_volume(seg)	segtype_is_thin_volume((seg)->segtype)
 #define seg_is_virtual(seg)	segtype_is_virtual((seg)->segtype)
 #define seg_unknown(seg)	segtype_is_unknown((seg)->segtype)
-#define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
-#define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
-#define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
-#define seg_only_exclusive(seg)	((seg)->segtype->flags & SEG_ONLY_EXCLUSIVE ? 1 : 0)
-#define seg_can_error_when_full(seg) ((seg)->segtype->flags & SEG_CAN_ERROR_WHEN_FULL ? 1 : 0)
+#define seg_can_split(seg)	segtype_can_split((seg)->segtype)
+#define seg_cannot_be_zeroed(seg)	segtype_cannot_be_zeroed((seg)->segtype)
+#define seg_monitored(seg)	segtype_monitored((seg)->segtype)
+#define seg_only_exclusive(seg)	segtype_only_exclusive((seg)->segtype)
+#define seg_can_error_when_full(seg)	segtype_can_error_when_full((seg)->segtype)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */


