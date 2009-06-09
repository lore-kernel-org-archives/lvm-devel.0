From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2009 16:10:32 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/.exported_symbols li ...
Message-ID: <20090609161032.22799.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-09 16:10:25

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Support crypt segment in libdevmapper tree.
	
	- it can support multiple segments, but note that
	to work properly, correct IV (initialization vector)
	offset parameter must be set properly.
	
	Because most usage of IV start offset is when we join
	several crypto segments together (so iv_offset is the segment
	start offset), DM_CRYPT_IV_DEFAULT is defined to simplify
	the process.
	
	Function accepts the string in cipher agrument (already
	including chainmode and iv type; chainmode and iv parameters are NULL
	in this case) or user can provide split parameters which will
	join into dm-crypt cipher specification "cipher-chainmode-iv".
	
	All these parameters must be supplied in correct dm-crypt format.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.275&r2=1.276
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW_DM	2009/06/04 13:23:10	1.275
+++ LVM2/WHATS_NEW_DM	2009/06/09 16:10:20	1.276
@@ -1,5 +1,6 @@
-Version 1.02.33 -    
+Version 1.02.33 -
 ===============================
+  Add crypt target handling to libdevmapper node.
   Add splitname command to dmsetup.
   Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
   Make mempool optional in dm_split_lvm_name().
--- LVM2/libdm/.exported_symbols	2009/05/20 09:52:37	1.35
+++ LVM2/libdm/.exported_symbols	2009/06/09 16:10:24	1.36
@@ -67,6 +67,7 @@
 dm_tree_node_add_zero_target
 dm_tree_node_add_linear_target
 dm_tree_node_add_striped_target
+dm_tree_node_add_crypt_target
 dm_tree_node_add_mirror_target
 dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
--- LVM2/libdm/libdevmapper.h	2009/06/03 11:40:23	1.88
+++ LVM2/libdm/libdevmapper.h	2009/06/09 16:10:24	1.89
@@ -374,6 +374,21 @@
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       uint32_t stripe_size);
+
+#define DM_CRYPT_IV_DEFAULT	UINT64_C(-1)	/* iv_offset == seg offset */
+/*
+ * Function accepts one string in cipher specification
+ * (chainmode and iv should be NULL because included in cipher string)
+ *   or
+ * separate arguments which will be joined to "cipher-chainmode-iv"
+ */
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *chainmode,
+				  const char *iv,
+				  uint64_t iv_offset,
+				  const char *key);
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 				      uint64_t size);
  
--- LVM2/libdm/libdm-deptree.c	2009/05/20 09:52:37	1.50
+++ LVM2/libdm/libdm-deptree.c	2009/06/09 16:10:25	1.51
@@ -28,7 +28,8 @@
 
 /* Supported segment types */
 enum {
-	SEG_ERROR, 
+	SEG_CRYPT,
+	SEG_ERROR,
 	SEG_LINEAR,
 	SEG_MIRRORED,
 	SEG_SNAPSHOT,
@@ -43,6 +44,7 @@
 	unsigned type;
 	const char *target;
 } dm_segtypes[] = {
+	{ SEG_CRYPT, "crypt" },
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
@@ -69,8 +71,8 @@
 
 	uint64_t size;
 
-	unsigned area_count;		/* Linear + Striped + Mirrored */
-	struct dm_list areas;		/* Linear + Striped + Mirrored */
+	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt */
+	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt */
 
 	uint32_t stripe_size;		/* Striped */
 
@@ -85,6 +87,12 @@
 	unsigned mirror_area_count;	/* Mirror */
 	uint32_t flags;			/* Mirror log */
 	char *uuid;			/* Clustered mirror log */
+
+	const char *cipher;		/* Crypt */
+	const char *chainmode;		/* Crypt */
+	const char *iv;			/* Crypt */
+	uint64_t iv_offset;		/* Crypt */
+	const char *key;		/* Crypt */
 };
 
 /* Per-device properties */
@@ -1328,6 +1336,13 @@
 	case SEG_STRIPED:
 		EMIT_PARAMS(pos, "%u %u", seg->area_count, seg->stripe_size);
 		break;
+	case SEG_CRYPT:
+		EMIT_PARAMS(pos, "%s%s%s%s%s %s %" PRIu64, seg->cipher,
+			    seg->chainmode ? "-" : "", seg->chainmode ?: "",
+			    seg->iv ? "-" : "", seg->iv ?: "", seg->key,
+			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
+			    seg->iv_offset : *seg_start);
+		break;
 	}
 
 	switch(seg->type) {
@@ -1336,6 +1351,7 @@
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_ZERO:
 		break;
+	case SEG_CRYPT:
 	case SEG_LINEAR:
 	case SEG_MIRRORED:
 	case SEG_STRIPED:
@@ -1673,6 +1689,28 @@
 	return 1;
 }
 
+int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *cipher,
+				  const char *chainmode,
+				  const char *iv,
+				  uint64_t iv_offset,
+				  const char *key)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_CRYPT, size)))
+		return_0;
+
+	seg->cipher = cipher;
+	seg->chainmode = chainmode;
+	seg->iv = iv;
+	seg->iv_offset = iv_offset;
+	seg->key = key;
+
+	return 1;
+}
+
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
 					  unsigned clustered, 


