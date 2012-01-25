From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 13:10:27 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20120125131027.9786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 13:10:26

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 

Log message:
	Rename  origin_only to more generic use_layer flag
	
	Since now we have more layered devices i.e. thin volumes - support
	selection of layer via flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2239&r2=1.2240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2012/01/25 11:32:41	1.2239
+++ LVM2/WHATS_NEW	2012/01/25 13:10:26	1.2240
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Rename origin_only parameter to more generic flag use_layer for lv_info().
   Thin pools have segment fields thin_count, zero, transaction_id.
   Each new created LV volume has creation lv_time and lv_host.
   Print data_percent and metadata_percent for verbose lvs.
--- LVM2/lib/activate/activate.c	2012/01/25 09:13:10	1.238
+++ LVM2/lib/activate/activate.c	2012/01/25 13:10:26	1.239
@@ -151,13 +151,12 @@
 {
 	return 0;
 }
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned origin_only,
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	return 0;
 }
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-		    unsigned origin_only,
+int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	return 0;
@@ -532,10 +531,11 @@
 /*
  * Returns 1 if info structure populated, else 0 on failure.
  */
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned origin_only,
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
+	const char *layer;
 
 	if (!activation())
 		return 0;
@@ -552,7 +552,14 @@
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, (lv_is_origin(lv) && origin_only) ? "real" : NULL, with_open_count,
+	if (use_layer && lv_is_thin_pool(lv))
+		layer = "tpool";
+	else if (use_layer && lv_is_origin(lv))
+		layer = "real";
+	else
+		layer = NULL;
+
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, layer, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
 		return_0;
 
@@ -568,8 +575,7 @@
 	return 1;
 }
 
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-		    unsigned origin_only,
+int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	int r;
@@ -578,10 +584,7 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	if (!lv_is_origin(lv))
-		origin_only = 0;
-
-	r = lv_info(cmd, lv, origin_only, info, with_open_count, with_read_ahead);
+	r = lv_info(cmd, lv, use_layer, info, with_open_count, with_read_ahead);
 	release_vg(lv->vg);
 
 	return r;
--- LVM2/lib/activate/activate.h	2012/01/25 09:06:43	1.96
+++ LVM2/lib/activate/activate.h	2012/01/25 13:10:26	1.97
@@ -79,10 +79,9 @@
 /*
  * Returns 1 if info structure has been populated, else 0.
  */
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
-	    unsigned origin_only, struct lvinfo *info,
-	    int with_open_count, int with_read_ahead);
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
+	    struct lvinfo *info, int with_open_count, int with_read_ahead);
+int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
 int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,


