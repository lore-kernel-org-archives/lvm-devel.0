From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 24 Sep 2009 08:59:45 -0400 (EDT)
Subject: [PATCH]: unify logical volume structure initialization
Message-ID: <Pine.LNX.4.64.0909240857590.7388@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I'm submitting this patch to lvm because both snapshot and replicators 
groups need it.

Mikulas

---

Copying code is terrible practice. The code is hard to change for anyone.
Because I need to change this code and don't want to copy the change to any
place, I moved it to a separate function.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>

[snitm: import_snapshots() change should be in different patch?]

---
 lib/format1/import-export.c      |    8 ++------
 lib/format_pool/import_export.c  |   11 ++---------
 lib/format_text/import_vsn1.c    |    6 +-----
 lib/metadata/lv_manip.c          |   18 +++++++++++++-----
 lib/metadata/metadata-exported.h |    1 +
 5 files changed, 19 insertions(+), 25 deletions(-)

Index: LVM2-msnitzer/lib/format1/import-export.c
===================================================================
--- LVM2-msnitzer.orig/lib/format1/import-export.c	2009-09-24 14:56:55.000000000 +0200
+++ LVM2-msnitzer/lib/format1/import-export.c	2009-09-24 14:57:03.000000000 +0200
@@ -337,11 +337,7 @@ int import_lv(struct cmd_context *cmd, s
 	lv->size = lvd->lv_size;
 	lv->le_count = lvd->lv_allocated_le;
 
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
+	lv_init(lv);
 
 	return 1;
 }
@@ -618,7 +614,7 @@ int import_snapshots(struct dm_pool *mem
 			/* insert the snapshot */
 			if (!vg_add_snapshot(org, cow, NULL,
 					     org->le_count,
-					     lvd->lv_chunk_size)) {
+					     lvd->lv_chunk_size, 0)) {
 				log_error("Couldn't add snapshot.");
 				return 0;
 			}
Index: LVM2-msnitzer/lib/format_pool/import_export.c
===================================================================
--- LVM2-msnitzer.orig/lib/format_pool/import_export.c	2009-09-24 14:56:55.000000000 +0200
+++ LVM2-msnitzer/lib/format_pool/import_export.c	2009-09-24 14:57:03.000000000 +0200
@@ -70,11 +70,7 @@ int import_pool_lvs(struct volume_group 
 	lv->name = NULL;
 	lv->le_count = 0;
 	lv->read_ahead = vg->cmd->default_settings.read_ahead;
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
+	lv_init(lv);
 
 	dm_list_iterate_items(pl, pls) {
 		lv->size += pl->pd.pl_blocks;
@@ -99,10 +95,7 @@ int import_pool_lvs(struct volume_group 
 		} else {
 			lv->minor = -1;
 		}
-		lv->snapshot = NULL;
-		dm_list_init(&lv->snapshot_segs);
-		dm_list_init(&lv->segments);
-		dm_list_init(&lv->tags);
+		lv_init(lv);
 	}
 
 	lv->le_count = lv->size / POOL_PE_SIZE;
Index: LVM2-msnitzer/lib/format_text/import_vsn1.c
===================================================================
--- LVM2-msnitzer.orig/lib/format_text/import_vsn1.c	2009-09-24 14:56:55.000000000 +0200
+++ LVM2-msnitzer/lib/format_text/import_vsn1.c	2009-09-24 14:57:03.000000000 +0200
@@ -541,11 +541,7 @@ static int _read_lvnames(struct format_i
 		}
 	}
 
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
+	lv_init(lv);
 
 	/* Optional tags */
 	if ((cn = find_config_node(lvn, "tags")) &&
Index: LVM2-msnitzer/lib/metadata/lv_manip.c
===================================================================
--- LVM2-msnitzer.orig/lib/metadata/lv_manip.c	2009-09-24 14:56:55.000000000 +0200
+++ LVM2-msnitzer/lib/metadata/lv_manip.c	2009-09-24 14:57:03.000000000 +0200
@@ -1863,6 +1863,18 @@ int vg_max_lv_reached(struct volume_grou
 }
 
 /*
+ * Initialize common fields in a structure.
+ */
+void lv_init(struct logical_volume *lv)
+{
+	lv->snapshot = NULL;
+	dm_list_init(&lv->snapshot_segs);
+	dm_list_init(&lv->segments);
+	dm_list_init(&lv->tags);
+	dm_list_init(&lv->segs_using_this_lv);
+}
+
+/*
  * Create a new empty LV.
  */
 struct logical_volume *lv_create_empty(const char *name,
@@ -1904,11 +1916,7 @@ struct logical_volume *lv_create_empty(c
 	lv->minor = -1;
 	lv->size = UINT64_C(0);
 	lv->le_count = 0;
-	lv->snapshot = NULL;
-	dm_list_init(&lv->snapshot_segs);
-	dm_list_init(&lv->segments);
-	dm_list_init(&lv->tags);
-	dm_list_init(&lv->segs_using_this_lv);
+	lv_init(lv);
 
 	if (lvid)
 		lv->lvid = *lvid;
Index: LVM2-msnitzer/lib/metadata/metadata-exported.h
===================================================================
--- LVM2-msnitzer.orig/lib/metadata/metadata-exported.h	2009-09-24 14:56:55.000000000 +0200
+++ LVM2-msnitzer/lib/metadata/metadata-exported.h	2009-09-24 14:57:03.000000000 +0200
@@ -466,6 +466,7 @@ int remove_lvs_in_vg(struct cmd_context 
 void vg_release(struct volume_group *vg);
 
 /* Manipulate LVs */
+void lv_init(struct logical_volume *lv);
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,


