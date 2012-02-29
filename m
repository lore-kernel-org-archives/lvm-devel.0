From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Feb 2012 02:35:41 -0000
Subject: LVM2/lib cache/lvmetad.c format1/format1.c for ...
Message-ID: <20120229023541.16547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-29 02:35:37

Modified files:
	lib/cache      : lvmetad.c 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c import-export.h 
	                 import.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Pass 'single_device' parameter down to suppress 'Can't find uuid' messages
	when reading VG text metadate and called from pvscan --lvmetad.
	
	(Longer-term, that check needs moving outside of that code.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.493&r2=1.494
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.267&r2=1.268

--- LVM2/lib/cache/lvmetad.c	2012/02/28 18:23:56	1.9
+++ LVM2/lib/cache/lvmetad.c	2012/02/29 02:35:35	1.10
@@ -588,15 +588,18 @@
 static int _pvscan_lvmetad_single(struct metadata_area *mda, void *baton)
 {
 	struct _pvscan_lvmetad_baton *b = baton;
-	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda);
+	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda, 1);
+
 	if (!b->vg || this->seqno > b->vg->seqno)
 		b->vg = this;
 	else if (b->vg)
 		release_vg(this);
+
 	return 1;
 }
 
-static dev_t _parse_devt(const char *str) { /* Oh. */
+static dev_t _parse_devt(const char *str)
+{	/* Oh. */
 	char *where = (char *) str;
 	int major = strtol(str, &where, 10);
 	int minor;
--- LVM2/lib/format1/format1.c	2012/02/27 11:23:15	1.149
+++ LVM2/lib/format1/format1.c	2012/02/29 02:35:35	1.150
@@ -179,7 +179,8 @@
 
 static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     const char *vg_name,
-				     struct metadata_area *mda __attribute__((unused)))
+				     struct metadata_area *mda __attribute__((unused)),
+				     int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
 	struct disk_list *dl;
--- LVM2/lib/format_pool/format_pool.c	2012/02/27 11:23:15	1.54
+++ LVM2/lib/format_pool/format_pool.c	2012/02/29 02:35:36	1.55
@@ -100,7 +100,8 @@
 
 static struct volume_group *_pool_vg_read(struct format_instance *fid,
 					  const char *vg_name,
-					  struct metadata_area *mda __attribute__((unused)))
+					  struct metadata_area *mda __attribute__((unused)),
+					  int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
 	struct user_subpool *usp;
--- LVM2/lib/format_text/archiver.c	2012/02/27 11:35:59	1.51
+++ LVM2/lib/format_text/archiver.c	2012/02/29 02:35:36	1.52
@@ -288,7 +288,7 @@
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda)))
+		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, 0)))
 			stack;
 		break;
 	}
--- LVM2/lib/format_text/format-text.c	2012/02/28 10:11:36	1.197
+++ LVM2/lib/format_text/format-text.c	2012/02/29 02:35:36	1.198
@@ -483,7 +483,8 @@
 static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      const char *vgname,
 					      struct device_area *area,
-					      int precommitted)
+					      int precommitted,
+					      int single_device)
 {
 	struct volume_group *vg = NULL;
 	struct raw_locn *rlocn;
@@ -510,7 +511,7 @@
 	}
 
 	/* FIXME 64-bit */
-	if (!(vg = text_vg_import_fd(fid, NULL, area->dev,
+	if (!(vg = text_vg_import_fd(fid, NULL, single_device, area->dev, 
 				     (off_t) (area->start + rlocn->offset),
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
@@ -531,7 +532,8 @@
 
 static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 const char *vgname,
-					 struct metadata_area *mda)
+					 struct metadata_area *mda,
+					 int single_device)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -539,7 +541,7 @@
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0, single_device);
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -557,7 +559,7 @@
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1, 0);
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -869,7 +871,8 @@
 
 static struct volume_group *_vg_read_file(struct format_instance *fid,
 					  const char *vgname,
-					  struct metadata_area *mda)
+					  struct metadata_area *mda,
+					  int single_device __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
@@ -1235,7 +1238,7 @@
 		if ((scanned_vgname = vgname_from_mda(fmt, mdah,
 					      &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			vg = _vg_read_raw_area(&fid, scanned_vgname, &rl->dev_area, 0);
+			vg = _vg_read_raw_area(&fid, scanned_vgname, &rl->dev_area, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 
--- LVM2/lib/format_text/import-export.h	2011/09/01 10:25:22	1.28
+++ LVM2/lib/format_text/import-export.h	2012/02/29 02:35:36	1.29
@@ -71,6 +71,7 @@
 					 time_t *when, char **desc);
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
+				       int single_device,
 				       struct device *dev,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
--- LVM2/lib/format_text/import.c	2011/12/18 21:56:04	1.56
+++ LVM2/lib/format_text/import.c	2012/02/29 02:35:36	1.57
@@ -78,6 +78,7 @@
 
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
+				       int single_device,
 				       struct device *dev,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
@@ -111,7 +112,7 @@
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, single_device)))
 			goto_out;
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
@@ -127,7 +128,7 @@
 					 const char *file,
 					 time_t *when, char **desc)
 {
-	return text_vg_import_fd(fid, file, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
+	return text_vg_import_fd(fid, file, 0, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
 				 when, desc);
 }
 
--- LVM2/lib/metadata/metadata.c	2012/02/29 00:19:14	1.493
+++ LVM2/lib/metadata/metadata.c	2012/02/29 02:35:36	1.494
@@ -3017,7 +3017,7 @@
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
 		    (!use_precommitted &&
-		     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
+		     !(vg = mda->ops->vg_read(fid, vgname, mda, 0)))) {
 			inconsistent = 1;
 			release_vg(vg);
 			continue;
@@ -3197,7 +3197,7 @@
 			     !(vg = mda->ops->vg_read_precommit(fid, vgname,
 								mda))) ||
 			    (!use_precommitted &&
-			     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
+			     !(vg = mda->ops->vg_read(fid, vgname, mda, 0)))) {
 				inconsistent = 1;
 				continue;
 			}
--- LVM2/lib/metadata/metadata.h	2012/02/23 13:11:10	1.267
+++ LVM2/lib/metadata/metadata.h	2012/02/29 02:35:36	1.268
@@ -77,7 +77,8 @@
 	struct dm_list list;
 	struct volume_group *(*vg_read) (struct format_instance * fi,
 					 const char *vg_name,
-					 struct metadata_area * mda);
+					 struct metadata_area * mda,
+					 int single_device);
 	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda);


