From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:11 +0000 (UTC)
Subject: master - segtypes: macro segtype_is_unknown
Message-ID: <20141024144011.CDB0C60EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c057f33f3581aa29f79bb0a62c7115da30f8672
Commit:        2c057f33f3581aa29f79bb0a62c7115da30f8672
Parent:        237c54802c88f0a7045d11642884c3d69e46180d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 10 22:22:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

segtypes: macro segtype_is_unknown

---
 lib/metadata/segtype.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index e0c46df..749b188 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -57,6 +57,7 @@ struct dev_manager;
 #define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
 #define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
+#define segtype_is_unknown(segtype)	((segtype)->flags & SEG_UNKNOWN ? 1 : 0)
 
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
@@ -73,10 +74,10 @@ struct dev_manager;
 #define seg_is_thin_pool(seg)	segtype_is_thin_pool((seg)->segtype)
 #define seg_is_thin_volume(seg)	segtype_is_thin_volume((seg)->segtype)
 #define seg_is_virtual(seg)	segtype_is_virtual((seg)->segtype)
+#define seg_unknown(seg)	segtype_is_unknown((seg)->segtype)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
-#define seg_unknown(seg)	((seg)->segtype->flags & SEG_UNKNOWN ? 1 : 0)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */


