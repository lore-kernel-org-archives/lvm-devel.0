From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:24 +0200
Subject: [PATCH 12/25] Replicator: segtype.h - replicated
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <7e590b343f8ce3c715f857ae2269841e0ed528bf.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change REPLICATOR_DEV to REPLICATED

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/segtype.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index d15df8b..799d6be 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -36,12 +36,12 @@ struct dev_manager;
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
 #define SEG_REPLICATOR		0x00000100U
-#define SEG_REPLICATOR_DEV	0x00000200U
+#define SEG_REPLICATED		0x00000200U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
-#define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
+#define seg_is_replicated(seg)	((seg)->segtype->flags & SEG_REPLICATED ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
-- 
1.7.2.1


