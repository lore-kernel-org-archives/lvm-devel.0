From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Mar 2007 12:43:18 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20070323124318.3616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-03-23 12:43:17

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
	Split metadata areas in vgsplit properly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.590&r2=1.591
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2007/03/19 21:16:49	1.590
+++ LVM2/WHATS_NEW	2007/03/23 12:43:17	1.591
@@ -1,5 +1,7 @@
 Version 2.02.25 -
 =================================
+  Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
+  Split metadata areas in vgsplit properly.
 
 Version 2.02.24 - 19th March 2007
 =================================
--- LVM2/lib/format_text/format-text.c	2007/01/25 14:37:48	1.72
+++ LVM2/lib/format_text/format-text.c	2007/03/23 12:43:17	1.73
@@ -80,6 +80,22 @@
 	return 1;
 }
 
+/*
+ * Check if metadata area belongs to vg
+ */
+static int _mda_in_vg_raw(struct format_instance *fid __attribute((unused)),
+			     struct volume_group *vg, struct metadata_area *mda)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct pv_list *pvl;
+
+	list_iterate_items(pvl, &vg->pvs)
+		if (pvl->pv->dev == mdac->area.dev)
+			return 1;
+
+	return 0;
+}
+
 static int _text_lv_setup(struct format_instance *fid __attribute((unused)),
 			  struct logical_volume *lv)
 {
@@ -1395,7 +1411,8 @@
 	.vg_remove = _vg_remove_raw,
 	.vg_precommit = _vg_precommit_raw,
 	.vg_commit = _vg_commit_raw,
-	.vg_revert = _vg_revert_raw
+	.vg_revert = _vg_revert_raw,
+	.mda_in_vg = _mda_in_vg_raw,
 };
 
 /* pvmetadatasize in sectors */
--- LVM2/lib/metadata/metadata.c	2007/02/07 13:29:52	1.103
+++ LVM2/lib/metadata/metadata.c	2007/03/23 12:43:17	1.104
@@ -505,6 +505,34 @@
 	return 1;
 }
 
+int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
+		  struct volume_group *vg_to)
+{
+	struct metadata_area *mda, *mda2;
+	struct list *mdas_from, *mdas_to;
+	int common_mda = 0;
+
+	mdas_from = &vg_from->fid->metadata_areas;
+	mdas_to = &vg_to->fid->metadata_areas;
+
+	list_iterate_items_safe(mda, mda2, mdas_from) {
+		if (!mda->ops->mda_in_vg) {
+			common_mda = 1;
+			continue;
+		}
+
+		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda)) {
+			list_del(&mda->list);
+			list_add(mdas_to, &mda->list);
+		}
+	}
+
+	if (list_empty(mdas_from) || list_empty(mdas_to))
+		return common_mda;
+
+	return 1;
+}
+
 /* Sizes in sectors */
 struct physical_volume *pv_create(const struct format_type *fmt,
 				  struct device *dev,
@@ -759,6 +787,12 @@
 				r = 0;
 			}
 		}
+
+		if (strcmp(pvl->pv->vg_name, vg->name)) {
+			log_error("Internal error: VG name for PV %s is corrupted",
+				  dev_name(pvl->pv->dev));
+			r = 0;
+		}
 	}
 
 	if (!check_pv_segments(vg)) {
--- LVM2/lib/metadata/metadata.h	2007/02/07 13:29:52	1.153
+++ LVM2/lib/metadata/metadata.h	2007/03/23 12:43:17	1.154
@@ -178,6 +178,11 @@
 			  struct volume_group * vg, struct metadata_area * mda);
 	int (*vg_remove) (struct format_instance * fi, struct volume_group * vg,
 			  struct metadata_area * mda);
+	/*
+	 * Check if metadata area belongs to vg
+	 */
+	int (*mda_in_vg) (struct format_instance * fi,
+			    struct volume_group * vg, struct metadata_area *mda);
 };
 
 struct metadata_area {
@@ -450,6 +455,8 @@
 	      int pv_count, char **pv_names);
 int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
 		     uint32_t new_extent_size);
+int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
+		  struct volume_group *vg_to);
 
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(struct format_instance *fi,
--- LVM2/tools/vgsplit.c	2007/03/09 21:25:33	1.23
+++ LVM2/tools/vgsplit.c	2007/03/23 12:43:17	1.24
@@ -299,6 +299,10 @@
 		goto error;
 	}
 
+	/* Set metadata format of original VG */
+	/* FIXME: need some common logic */
+	cmd->fmt = vg_from->fid->fmt;
+
 	/* Create new VG structure */
 	if (!(vg_to = vg_create(cmd, vg_name_to, vg_from->extent_size,
 				vg_from->max_pv, vg_from->max_lv,
@@ -330,11 +334,15 @@
 	if (!(_move_mirrors(vg_from, vg_to)))
 		goto error;
 
-	/* FIXME Split mdas properly somehow too! */
-	/* Currently we cheat by sharing the format instance and relying on 
-	 * vg_write to ignore mdas outside the VG!  Done this way, with text 
-	 * format, vg_from disappears for a short time. */
-	vg_to->fid = vg_from->fid;
+	/* Split metadata areas and check if both vgs have at least one area */
+	if (!(vg_split_mdas(cmd, vg_from, vg_to))) {
+		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
+		goto error;
+	}
+
+	/* Set proper name for all PVs in new VG */
+	if (!vg_rename(cmd, vg_to, vg_name_to))
+		goto error;
 
 	/* store it on disks */
 	log_verbose("Writing out updated volume groups");


