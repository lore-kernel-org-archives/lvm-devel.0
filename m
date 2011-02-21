From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:17:55 -0000
Subject: LVM2/lib format_text/format-text.c format_text ...
Message-ID: <20110221121755.32180.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:17:54

Modified files:
	lib/format_text: format-text.c format-text.h 
	lib/metadata   : metadata.h 

Log message:
	Add new pv_remove_metadata_area interface function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.234&r2=1.235

--- LVM2/lib/format_text/format-text.c	2011/02/21 12:17:26	1.159
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:17:54	1.160
@@ -2272,6 +2272,29 @@
 	return 0;
 }
 
+int remove_metadata_area_from_pv(struct physical_volume *pv,
+				 unsigned mda_index)
+{
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "can't remove metadata area with "
+					 "index %u from PV %s. Metadata "
+					 "layou not supported by %s format.",
+					  mda_index, dev_name(pv->dev),
+					  pv->fmt->name);
+		return 0;
+	}
+
+	return fid_remove_mda(pv->fid, NULL, (const char *) &pv->id,
+			      ID_LEN, mda_index);
+}
+
+static int _text_pv_remove_metadata_area(const struct format_type *fmt,
+					 struct physical_volume *pv,
+					 unsigned mda_index)
+{
+	return remove_metadata_area_from_pv(pv, mda_index);
+}
+
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							   const struct format_instance_ctx *fic)
@@ -2347,6 +2370,7 @@
 	.pv_read = _text_pv_read,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
+	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
 	.pv_write = _text_pv_write,
 	.vg_setup = _text_vg_setup,
 	.lv_setup = _text_lv_setup,
--- LVM2/lib/format_text/format-text.h	2011/02/21 12:17:26	1.30
+++ LVM2/lib/format_text/format-text.h	2011/02/21 12:17:54	1.31
@@ -61,6 +61,8 @@
 			    uint64_t mda_start,
 			    uint64_t mda_size,
 			    unsigned mda_ignored);
+int remove_metadata_area_from_pv(struct physical_volume *pv,
+				 unsigned mda_index);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:17:26	1.234
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:17:54	1.235
@@ -278,6 +278,13 @@
 				     unsigned metadata_ignored);
 
 	/*
+	 * Remove metadata area from a PV. Changes will take effect on pv_write.
+	 */
+	int (*pv_remove_metadata_area) (const struct format_type *fmt,
+					struct physical_volume *pv,
+					unsigned metadata_index);
+
+	/*
 	 * Write a PV structure to disk. Fails if the PV is in a VG ie
 	 * pv->vg_name must be a valid orphan VG name
 	 */


