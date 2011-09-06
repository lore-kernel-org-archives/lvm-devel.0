From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Sep 2011 22:35:45 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20110906223545.14191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-06 22:35:45

Modified files:
	lib/thin       : thin.c 

Log message:
	Convert data->pool

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/lib/thin/thin.c	2011/09/06 19:25:44	1.9
+++ LVM2/lib/thin/thin.c	2011/09/06 22:35:44	1.10
@@ -48,19 +48,19 @@
 {
 	const char *lv_name;
 
-	if (!dm_config_get_str(sn, "data", &lv_name))
-		return SEG_LOG_ERROR("Thin pool data must be a string in");
+	if (!dm_config_get_str(sn, "pool", &lv_name))
+		return SEG_LOG_ERROR("Pool must be a string in");
 
 // Use attach_pool_lv
 	if (!(seg->pool_lv = find_lv(seg->lv->vg, lv_name)))
-		return SEG_LOG_ERROR("Unknown pool data %s in", lv_name);
+		return SEG_LOG_ERROR("Unknown pool %s in", lv_name);
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
-		return SEG_LOG_ERROR("Thin pool metadata must be a string in");
+		return SEG_LOG_ERROR("Metadata must be a string in");
 
 // Use attach_pool_metadata()
 	if (!(seg->metadata_lv = find_lv(seg->lv->vg, lv_name)))
-		return SEG_LOG_ERROR("Unknown pool metadata %s in", lv_name);
+		return SEG_LOG_ERROR("Unknown metadata %s in", lv_name);
 
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
@@ -74,7 +74,7 @@
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "data = \"%s\"", seg->pool_lv->name);
+	outf(f, "pool = \"%s\"", seg->pool_lv->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	if (seg->zero_new_blocks)
@@ -101,7 +101,7 @@
 
 	if (dm_config_has_node(sn, "origin")) {
 		if (!dm_config_get_str(sn, "origin", &lv_name))
-			return SEG_LOG_ERROR("Thin pool origin must be a string in");
+			return SEG_LOG_ERROR("Origin must be a string in");
 
 		if (!(seg->origin = find_lv(seg->lv->vg, lv_name)))
 			return SEG_LOG_ERROR("Unknown origin %s in", lv_name);


