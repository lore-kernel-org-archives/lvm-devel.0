From: Milan Broz <mbroz@redhat.com>
Date: Mon,  8 Jun 2009 15:46:21 +0200
Subject: [PATCH] Support crypt segment in libdevmapper tree.
Message-ID: <1244468781-2434-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - it can support multiple segments, but note that
to work properly, correct IV (initialization vector)
offset paramater must be set properly.

Because most usage of IV start offset is when we join
several crypto segments together (so iv_offset is the segmen
start offset), DM_CRYPT_IV_DEFAULT is defined to simplify
the process.

Both cipher and key must be supplied in correct dm-crypt format.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |    8 ++++++++
 libdm/libdm-deptree.c   |   36 +++++++++++++++++++++++++++++++++---
 3 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 2c80b05..82a7c9e 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -67,6 +67,7 @@ dm_tree_node_add_error_target
 dm_tree_node_add_zero_target
 dm_tree_node_add_linear_target
 dm_tree_node_add_striped_target
+dm_tree_node_add_crypt_target
 dm_tree_node_add_mirror_target
 dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c8ce21f..59023ac 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -374,6 +374,14 @@ int dm_tree_node_add_linear_target(struct dm_tree_node *node,
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       uint32_t stripe_size);
+
+#define DM_CRYPT_IV_DEFAULT	UINT64_C(-1)	/* iv_offset == seg offset */
+
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *key,
+				  uint64_t iv_offset);
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 				      uint64_t size);
  
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 179cf95..14e8a01 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -28,7 +28,8 @@
 
 /* Supported segment types */
 enum {
-	SEG_ERROR, 
+	SEG_CRYPT,
+	SEG_ERROR,
 	SEG_LINEAR,
 	SEG_MIRRORED,
 	SEG_SNAPSHOT,
@@ -43,6 +44,7 @@ struct {
 	unsigned type;
 	const char *target;
 } dm_segtypes[] = {
+	{ SEG_CRYPT, "crypt" },
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
@@ -69,8 +71,8 @@ struct load_segment {
 
 	uint64_t size;
 
-	unsigned area_count;		/* Linear + Striped + Mirrored */
-	struct dm_list areas;		/* Linear + Striped + Mirrored */
+	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt */
+	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt */
 
 	uint32_t stripe_size;		/* Striped */
 
@@ -85,6 +87,10 @@ struct load_segment {
 	unsigned mirror_area_count;	/* Mirror */
 	uint32_t flags;			/* Mirror log */
 	char *uuid;			/* Clustered mirror log */
+
+	const char *cipher;		/* Crypt */
+	const char *key;		/* Crypt */
+	uint64_t iv_offset;		/* Crypt */
 };
 
 /* Per-device properties */
@@ -1328,6 +1334,11 @@ static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uin
 	case SEG_STRIPED:
 		EMIT_PARAMS(pos, "%u %u", seg->area_count, seg->stripe_size);
 		break;
+	case SEG_CRYPT:
+		EMIT_PARAMS(pos, "%s %s %" PRIu64, seg->cipher, seg->key,
+			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
+			    seg->iv_offset : *seg_start);
+		break;
 	}
 
 	switch(seg->type) {
@@ -1336,6 +1347,7 @@ static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uin
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_ZERO:
 		break;
+	case SEG_CRYPT:
 	case SEG_LINEAR:
 	case SEG_MIRRORED:
 	case SEG_STRIPED:
@@ -1673,6 +1685,24 @@ int dm_tree_node_add_striped_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *key,
+				  uint64_t iv_offset)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_CRYPT, size)))
+		return_0;
+
+	seg->cipher = cipher;
+	seg->key = key;
+	seg->iv_offset = iv_offset;
+
+	return 1;
+}
+
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
 					  unsigned clustered, 
-- 
1.6.3.1


