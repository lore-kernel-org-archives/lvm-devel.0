From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:42 +0100
Subject: [PATCH 01/15] Support crypt segment in libdevmapper tree.
In-Reply-To: <cover.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
Message-ID: <f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - it can support multiple segments, but note that
to work properly, correct IV (initialization vector)
offset parameter must be set properly.

Both cipher and key must be supplied in correct dm-crypt format,

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |    4 ++++
 libdm/libdm-deptree.c   |   31 ++++++++++++++++++++++++++++---
 3 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..f8dba1b 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -66,6 +66,7 @@ dm_tree_node_add_error_target
 dm_tree_node_add_zero_target
 dm_tree_node_add_linear_target
 dm_tree_node_add_striped_target
+dm_tree_node_add_crypt_target
 dm_tree_node_add_mirror_target
 dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..775b4ec 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -373,6 +373,10 @@ int dm_tree_node_add_linear_target(struct dm_tree_node *node,
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       uint32_t stripe_size);
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *key);
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 				      uint64_t size);
  
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 11428ca..310b30e 100644
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
 
@@ -85,6 +87,9 @@ struct load_segment {
 	unsigned mirror_area_count;	/* Mirror */
 	uint32_t flags;			/* Mirror log */
 	char *uuid;			/* Clustered mirror log */
+
+	const char *cipher;		/* Crypt */
+	const char *key;		/* Crypt */
 };
 
 /* Per-device properties */
@@ -1323,6 +1328,9 @@ static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uin
 	case SEG_STRIPED:
 		EMIT_PARAMS(pos, "%u %u", seg->area_count, seg->stripe_size);
 		break;
+	case SEG_CRYPT:
+		EMIT_PARAMS(pos, "%s %s %" PRIu64, seg->cipher, seg->key, *seg_start);
+		break;
 	}
 
 	switch(seg->type) {
@@ -1331,6 +1339,7 @@ static int _emit_segment_line(struct dm_task *dmt, struct load_segment *seg, uin
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_ZERO:
 		break;
+	case SEG_CRYPT:
 	case SEG_LINEAR:
 	case SEG_MIRRORED:
 	case SEG_STRIPED:
@@ -1664,6 +1673,22 @@ int dm_tree_node_add_striped_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *key)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_CRYPT, size)))
+		return_0;
+
+	seg->cipher = cipher;
+	seg->key = key;
+
+	return 1;
+}
+
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
 					  unsigned clustered, 
-- 
1.5.6.5


