From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Feb 2010 16:26:36 -0000
Subject: LVM2 lib/format_text/format-text.c ./WHATS_NEW
Message-ID: <20100202162636.8570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-02 16:26:35

Modified files:
	lib/format_text: format-text.c 
	.              : WHATS_NEW 

Log message:
	Add copy constructor for struct metadata_area.
	
	Clean up cut&paste code with proper copy constructor.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1416&r2=1.1417

--- LVM2/lib/format_text/format-text.c	2009/12/11 13:16:38	1.117
+++ LVM2/lib/format_text/format-text.c	2010/02/02 16:26:34	1.118
@@ -1548,15 +1548,41 @@
 	return 1;
 }
 
+/*
+ * Copy constructor for a metadata_area.
+ */
+static struct metadata_area *_mda_copy(struct dm_pool *mem,
+				       struct metadata_area *mda)
+{
+	struct metadata_area *mda_new;
+	struct mda_context *mdac, *mdac_new;
+
+	if (!(mda_new = dm_pool_alloc(mem, sizeof(*mda_new)))) {
+		log_error("metadata_area allocation failed");
+		return NULL;
+	}
+	/* FIXME: Should have a per-format constructor here */
+	mdac = (struct mda_context *) mda->metadata_locn;
+	if (!(mdac_new = dm_pool_alloc(mem, sizeof(*mdac_new)))) {
+		log_error("mda_context allocation failed");
+		dm_pool_free(mem, mda_new);
+		return NULL;
+	}
+	memcpy(mda_new, mda, sizeof(*mda));
+	memcpy(mdac_new, mdac, sizeof(*mdac));
+	mda_new->metadata_locn = mdac_new;
+	return mda_new;
+}
+
+
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		    struct physical_volume *pv, struct dm_list *mdas,
 		    int scan_label_only)
 {
+	struct metadata_area *mda, *mda_new;
 	struct label *label;
 	struct device *dev;
 	struct lvmcache_info *info;
-	struct metadata_area *mda, *mda_new;
-	struct mda_context *mdac, *mdac_new;
 
 	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
 		return_0;
@@ -1573,18 +1599,9 @@
 
 	/* Add copy of mdas to supplied list */
 	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = (struct mda_context *) mda->metadata_locn;
-		if (!(mda_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda_new)))) {
-			log_error("metadata_area allocation failed");
+		mda_new = _mda_copy(fmt->cmd->mem, mda);
+		if (!mda_new)
 			return 0;
-		}
-		if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac_new)))) {
-			log_error("metadata_area allocation failed");
-			return 0;
-		}
-		memcpy(mda_new, mda, sizeof(*mda));
-		memcpy(mdac_new, mdac, sizeof(*mdac));
-		mda_new->metadata_locn = mdac_new;
 		dm_list_add(mdas, &mda_new->list);
 	}
 
@@ -1672,7 +1689,7 @@
 		     struct physical_volume *pv, struct volume_group *vg)
 {
 	struct metadata_area *mda, *mda_new, *mda2;
-	struct mda_context *mdac, *mdac_new, *mdac2;
+	struct mda_context *mdac, *mdac2;
 	struct dm_list *pvmdas;
 	struct lvmcache_info *info;
 	int found;
@@ -1718,18 +1735,11 @@
 				if (found)
 					continue;
 
-				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new))))
+				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				if (!mda_new)
 					return_0;
-
-				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new))))
-					return_0;
-				/* FIXME multiple dev_areas inside area */
-				memcpy(mda_new, mda, sizeof(*mda));
-				memcpy(mdac_new, mdac, sizeof(*mdac));
-				mda_new->metadata_locn = mdac_new;
 				dm_list_add(mdas, &mda_new->list);
+				/* FIXME multiple dev_areas inside area */
 			}
 		}
 
@@ -1815,7 +1825,7 @@
 	struct format_instance *fid;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda, *mda_new;
-	struct mda_context *mdac, *mdac_new;
+	struct mda_context *mdac;
 	struct dir_list *dl;
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list, *mdas;
@@ -1892,21 +1902,10 @@
 		dm_list_iterate_items(info, &vginfo->infos) {
 			mdas = &info->mdas;
 			dm_list_iterate_items(mda, mdas) {
-				mdac =
-				    (struct mda_context *) mda->metadata_locn;
-
 				/* FIXME Check it holds this VG */
-				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new))))
+				mda_new = _mda_copy(fmt->cmd->mem, mda);
+				if (!mda_new)
 					return_NULL;
-
-				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new))))
-					return_NULL;
-				/* FIXME multiple dev_areas inside area */
-				memcpy(mda_new, mda, sizeof(*mda));
-				memcpy(mdac_new, mdac, sizeof(*mdac));
-				mda_new->metadata_locn = mdac_new;
 				dm_list_add(&fid->metadata_areas, &mda_new->list);
 			}
 		}
--- LVM2/WHATS_NEW	2010/02/02 14:09:17	1.1416
+++ LVM2/WHATS_NEW	2010/02/02 16:26:35	1.1417
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Add copy constructor for metadata_area.
   Remove pointless versioned symlinks to dmeventd plugin libraries.
   Fix dmeventd snapshot plugin build dependency.
   Make clvmd -V return zero status.


