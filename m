From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Sep 2009 17:46:18 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20090928174618.26950.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-28 17:46:16

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_manip.c metadata.h 

Log message:
	Consolidate LV allocation into alloc_lv().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1275&r2=1.1276
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.198&r2=1.199

--- LVM2/WHATS_NEW	2009/09/28 16:36:03	1.1275
+++ LVM2/WHATS_NEW	2009/09/28 17:46:15	1.1276
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Consolidate LV allocation into alloc_lv().
   Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
   Use standard output units for 'PE Size' and 'Stripe size' in pv/lvdisplay.
   Add configure --enable-units-compat to set si_unit_consistency off by default.
--- LVM2/lib/format1/import-export.c	2009/09/15 18:35:14	1.109
+++ LVM2/lib/format1/import-export.c	2009/09/28 17:46:16	1.110
@@ -337,12 +337,6 @@
 	lv->size = lvd->lv_size;
 	lv->le_count = lvd->lv_allocated_le;
 
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
-
 	return 1;
 }
 
@@ -457,7 +451,7 @@
 {
 	struct logical_volume *lv;
 
-	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
+	if (!(lv = alloc_lv(mem)))
 		return_NULL;
 
 	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
--- LVM2/lib/format_pool/import_export.c	2009/05/13 21:25:02	1.27
+++ LVM2/lib/format_pool/import_export.c	2009/09/28 17:46:16	1.28
@@ -59,10 +59,8 @@
 	struct pool_list *pl;
 	struct logical_volume *lv;
 
-	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
-		log_error("Unable to allocate logical volume structure");
-		return 0;
-	}
+	if (!(lv = alloc_lv(mem)))
+		return_0;
 
 	lv->status = 0;
 	lv->alloc = ALLOC_NORMAL;
@@ -70,11 +68,6 @@
 	lv->name = NULL;
 	lv->le_count = 0;
 	lv->read_ahead = vg->cmd->default_settings.read_ahead;
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
 
 	dm_list_iterate_items(pl, pls) {
 		lv->size += pl->pd.pl_blocks;
@@ -99,10 +92,6 @@
 		} else {
 			lv->minor = -1;
 		}
-		lv->snapshot = NULL;
-		dm_list_init(&lv->snapshot_segs);
-		dm_list_init(&lv->segments);
-		dm_list_init(&lv->tags);
 	}
 
 	lv->le_count = lv->size / POOL_PE_SIZE;
--- LVM2/lib/format_text/import_vsn1.c	2009/07/27 17:43:40	1.64
+++ LVM2/lib/format_text/import_vsn1.c	2009/09/28 17:46:16	1.65
@@ -495,7 +495,7 @@
 	struct logical_volume *lv;
 	struct config_node *cn;
 
-	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
+	if (!(lv = alloc_lv(mem)))
 		return_0;
 
 	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
@@ -541,12 +541,6 @@
 		}
 	}
 
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
-
 	/* Optional tags */
 	if ((cn = find_config_node(lvn, "tags")) &&
 	    !(read_tags(mem, &lv->tags, cn->v))) {
--- LVM2/lib/metadata/lv_manip.c	2009/07/26 02:33:35	1.183
+++ LVM2/lib/metadata/lv_manip.c	2009/09/28 17:46:16	1.184
@@ -1862,6 +1862,24 @@
 	return 1;
 }
 
+struct logical_volume *alloc_lv(struct dm_pool *mem)
+{
+	struct logical_volume *lv;
+
+	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
+		log_error("Unable to allocate logical volume structure");
+		return NULL;
+	}
+
+	lv->snapshot = NULL;
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
+
+	return lv;
+}
+
 /*
  * Create a new empty LV.
  */
@@ -1891,7 +1909,7 @@
 
 	log_verbose("Creating logical volume %s", name);
 
-	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
+	if (!(lv = alloc_lv(vg->vgmem)))
 		return_NULL;
 
 	if (!(lv->name = dm_pool_strdup(vg->vgmem, name)))
@@ -1904,11 +1922,6 @@
 	lv->minor = -1;
 	lv->size = UINT64_C(0);
 	lv->le_count = 0;
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
 
 	if (lvid)
 		lv->lvid = *lvid;
--- LVM2/lib/metadata/metadata.h	2009/07/30 17:45:29	1.198
+++ LVM2/lib/metadata/metadata.h	2009/09/28 17:46:16	1.199
@@ -316,6 +316,8 @@
  */
 const char *strip_dir(const char *vg_name, const char *dir);
 
+struct logical_volume *alloc_lv(struct dm_pool *mem);
+
 /*
  * Checks that an lv has no gaps or overlapping segments.
  * Set complete_vg to perform additional VG level checks.


