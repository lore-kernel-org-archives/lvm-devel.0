From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 15:30:50 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20100316153050.15161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 15:30:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvcreate.c reporter.c 

Log message:
	Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
	Make find_pv_in_vg_by_uuid() return same type as related functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1461&r2=1.1462
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.319&r2=1.320
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2010/03/16 14:37:38	1.1461
+++ LVM2/WHATS_NEW	2010/03/16 15:30:48	1.1462
@@ -1,5 +1,7 @@
 Version 2.02.63 - 
 ================================
+  Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
+  Make find_pv_in_vg_by_uuid() return same type as related functions.
   Introduce is_missing_pv().
   Fix clvmd Makefile to not overwrite LIBS from template definition.
 
--- LVM2/lib/metadata/metadata-exported.h	2010/03/16 14:37:38	1.134
+++ LVM2/lib/metadata/metadata-exported.h	2010/03/16 15:30:49	1.135
@@ -597,8 +597,8 @@
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			      const char *pv_name);
-struct physical_volume *find_pv_in_vg_by_uuid(const struct volume_group *vg,
-			    const struct id *id);
+struct pv_list *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+				      const struct id *id);
 
 /* Find an LV within a given VG */
 struct lv_list *find_lv_in_vg(const struct volume_group *vg,
--- LVM2/lib/metadata/metadata.c	2010/03/16 14:37:38	1.319
+++ LVM2/lib/metadata/metadata.c	2010/03/16 15:30:49	1.320
@@ -52,9 +52,6 @@
 static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
 				      const char *pv_name);
 
-static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
-						      const struct id *id);
-
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
@@ -1656,37 +1653,36 @@
 	return 0;
 }
 
+static struct pv_list *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
+					      const struct id *id)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs)
+		if (id_equal(&pvl->pv->id, id))
+			return pvl;
+
+	return NULL;
+}
+
 /**
  * find_pv_in_vg_by_uuid - Find PV in VG by PV UUID
  * @vg: volume group to search
  * @id: UUID of the PV to match
  *
  * Returns:
- *   PV handle - if UUID of PV found in VG
+ *   struct pv_list within owning struct volume_group - if UUID of PV found in VG
  *   NULL - invalid parameter or UUID of PV not found in VG
  *
  * Note
  *   FIXME - liblvm todo - make into function that takes VG handle
  */
-struct physical_volume *find_pv_in_vg_by_uuid(const struct volume_group *vg,
-			    const struct id *id)
+struct pv_list *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+				      const struct id *id)
 {
 	return _find_pv_in_vg_by_uuid(vg, id);
 }
 
-
-static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
-						      const struct id *id)
-{
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, &vg->pvs)
-		if (id_equal(&pvl->pv->id, id))
-			return pvl->pv;
-
-	return NULL;
-}
-
 struct lv_list *find_lv_in_vg(const struct volume_group *vg,
 			      const char *lv_name)
 {
--- LVM2/tools/pvcreate.c	2009/11/01 19:51:55	1.88
+++ LVM2/tools/pvcreate.c	2010/03/16 15:30:49	1.89
@@ -56,7 +56,7 @@
 				  pp->restorefile);
 			return 0;
 		}
-		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp))) {
+		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp)->pv)) {
 			log_error("Can't find uuid %s in backup file %s",
 				  uuid, pp->restorefile);
 			return 0;
--- LVM2/tools/reporter.c	2009/11/24 17:07:09	1.58
+++ LVM2/tools/reporter.c	2010/03/16 15:30:49	1.59
@@ -70,29 +70,29 @@
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
 		.name = (char *) "",
-	        .snapshot = NULL,
+		.snapshot = NULL,
 		.status = VISIBLE_LV,
 		.major = -1,
 		.minor = -1,
 	};
 
 	struct lv_segment _free_lv_segment = {
-        	.lv = &_free_logical_volume,
-        	.le = 0,
-        	.status = 0,
-        	.stripe_size = 0,
-        	.area_count = 0,
-        	.area_len = 0,
-        	.origin = NULL,
-        	.cow = NULL,
-        	.chunk_size = 0,
-        	.region_size = 0,
-        	.extents_copied = 0,
-        	.log_lv = NULL,
-        	.areas = NULL,
+		.lv = &_free_logical_volume,
+		.le = 0,
+		.status = 0,
+		.stripe_size = 0,
+		.area_count = 0,
+		.area_len = 0,
+		.origin = NULL,
+		.cow = NULL,
+		.chunk_size = 0,
+		.region_size = 0,
+		.extents_copied = 0,
+		.log_lv = NULL,
+		.areas = NULL,
 	};
 
-        _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
+	_free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
 	dm_list_init(&_free_vg.pvs);
 	dm_list_init(&_free_vg.lvs);
@@ -136,6 +136,7 @@
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
 	struct volume_group *old_vg = vg;
+	char uuid[64] __attribute((aligned(8)));
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -149,16 +150,28 @@
 
 		/*
 		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read_internal() path.
+		 * allocated in vg_read.
 		*/
-		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_dev_name(pv), vg->name);
+		if (!is_missing_pv(pv)) {
+			if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
+				log_error("Unable to find \"%s\" in volume group \"%s\"",
+					  pv_dev_name(pv), vg->name);
+				ret = ECMD_FAILED;
+				goto out;
+			}
+		} else if (!(pvl = find_pv_in_vg_by_uuid(vg, &pv->id))) {
+			if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
+				stack;
+				uuid[0] = '\0';
+			}
+
+			log_error("Unable to find missing PV %s in volume group %s",
+				  uuid, vg->name);
 			ret = ECMD_FAILED;
 			goto out;
 		}
 
-		 pv = pvl->pv;
+		pv = pvl->pv;
 	}
 
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {


