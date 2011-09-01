From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 10:16:33 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20110901101633.11218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 10:16:33

Modified files:
	lib/thin       : thin.c 

Log message:
	Reflect dm_config API update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/thin/thin.c	2011/08/30 14:55:18	1.6
+++ LVM2/lib/thin/thin.c	2011/09/01 10:16:32	1.7
@@ -46,28 +46,24 @@
 static int _thin_pool_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct dm_config_node *cn;
+	const char *lv_name;
 
-	if (!(cn = dm_config_find_node(sn, "data")) ||
-	    !cn->v || cn->v->type != DM_CFG_STRING)
+	if (!dm_config_get_str(sn, "data", &lv_name))
 		return SEG_LOG_ERROR("Thin pool data must be a string in");
 
-	if (!(seg->data_lv = find_lv(seg->lv->vg, cn->v->v.str)))
-		return SEG_LOG_ERROR("Unknown pool data %s in",
-				     cn->v->v.str);
+	if (!(seg->data_lv = find_lv(seg->lv->vg, lv_name)))
+		return SEG_LOG_ERROR("Unknown pool data %s in", lv_name);
 
-	if (!(cn = dm_config_find_node(sn, "metadata")) ||
-	    !cn->v || cn->v->type != DM_CFG_STRING)
+	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Thin pool metadata must be a string in");
 
-	if (!(seg->metadata_lv = find_lv(seg->lv->vg, cn->v->v.str)))
-		return SEG_LOG_ERROR("Unknown pool metadata %s in",
-				     cn->v->v.str);
+	if (!(seg->metadata_lv = find_lv(seg->lv->vg, lv_name)))
+		return SEG_LOG_ERROR("Unknown pool metadata %s in", lv_name);
 
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
-	if (dm_config_find_node(sn, "zero_new_blocks") &&
+	if (dm_config_has_node(sn, "zero_new_blocks") &&
 	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
 
@@ -93,23 +89,20 @@
 static int _thin_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct dm_config_node *cn;
+	const char *lv_name;
 
-	if (!(cn = dm_config_find_node(sn, "thin_pool")) ||
-	    !cn->v || cn->v->type != DM_CFG_STRING)
+	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
 
-	if (!(seg->thin_pool_lv = find_lv(seg->lv->vg, cn->v->v.str)))
-		return SEG_LOG_ERROR("Unknown thin pool %s in",
-				     cn->v->v.str);
+	if (!(seg->thin_pool_lv = find_lv(seg->lv->vg, lv_name)))
+		return SEG_LOG_ERROR("Unknown thin pool %s in", lv_name);
 
-	if ((cn = dm_config_find_node(sn, "origin"))) {
-                if (!cn->v || cn->v->type != DM_CFG_STRING)
+	if (dm_config_has_node(sn, "origin")) {
+		if (!dm_config_get_str(sn, "origin", &lv_name))
 			return SEG_LOG_ERROR("Thin pool origin must be a string in");
 
-		if (!(seg->origin = find_lv(seg->lv->vg, cn->v->v.str)))
-			return SEG_LOG_ERROR("Unknown origin %s in",
-					     cn->v->v.str);
+		if (!(seg->origin = find_lv(seg->lv->vg, lv_name)))
+			return SEG_LOG_ERROR("Unknown origin %s in", lv_name);
 	}
 
 	if (!dm_config_get_uint64(sn, "device_id", &seg->device_id))


