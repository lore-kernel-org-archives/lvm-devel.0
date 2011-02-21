From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:16:02 -0000
Subject: LVM2 lib/format1/format1.c lib/format_pool/for ...
Message-ID: <20110221121602.31534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:16:00

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : pvremove.c pvresize.c toollib.c 

Log message:
	Remove useless mdas parameter for pv_read (from now on, we store mdas in a
	format instance)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.429&r2=1.430
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222

--- LVM2/lib/format1/format1.c	2011/02/21 12:05:49	1.128
+++ LVM2/lib/format1/format1.c	2011/02/21 12:15:59	1.129
@@ -331,8 +331,7 @@
 }
 
 static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct dm_list *mdas __attribute__((unused)),
-		    int scan_label_only __attribute__((unused)))
+		    struct physical_volume *pv, int scan_label_only __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
 	struct disk_list *dl;
--- LVM2/lib/format_pool/format_pool.c	2011/02/21 12:05:50	1.36
+++ LVM2/lib/format_pool/format_pool.c	2011/02/21 12:15:59	1.37
@@ -206,7 +206,6 @@
 
 static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
 			 struct physical_volume *pv,
-			 struct dm_list *mdas __attribute__((unused)),
 			 int scan_label_only __attribute__((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
--- LVM2/lib/format_text/format-text.c	2011/02/21 12:07:03	1.157
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:15:59	1.158
@@ -1668,10 +1668,8 @@
 }
 
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct dm_list *mdas,
-		    int scan_label_only)
+		    struct physical_volume *pv, int scan_label_only)
 {
-	struct metadata_area *mda, *mda_new;
 	struct label *label;
 	struct device *dev;
 	struct lvmcache_info *info;
@@ -1686,17 +1684,6 @@
 	if (!_populate_pv_fields(info, pv, scan_label_only))
 		return 0;
 
-	if (!mdas)
-		return 1;
-
-	/* Add copy of mdas to supplied list */
-	dm_list_iterate_items(mda, &info->mdas) {
-		mda_new = mda_copy(fmt->cmd->mem, mda);
-		if (!mda_new)
-			return 0;
-		dm_list_add(mdas, &mda_new->list);
-	}
-
 	return 1;
 }
 
--- LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:01:22	1.177
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:16:00	1.178
@@ -368,8 +368,8 @@
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, int warnings, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				struct dm_list *mdas, uint64_t *label_sector,
-				int warnings, int scan_label_only);
+				uint64_t *label_sector, int warnings,
+				int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /*
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:13:40	1.429
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:16:00	1.430
@@ -38,7 +38,6 @@
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings, int scan_label_only);
 
@@ -1338,14 +1337,11 @@
 {
 	struct physical_volume *pv;
 	struct device *dev;
-	struct dm_list mdas;
-
-	dm_list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, &mdas, NULL, 0, 0);
+	pv = pv_read(cmd, name, NULL, 0, 0);
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -1353,10 +1349,10 @@
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv) && mdas_empty_or_ignored(&mdas)) {
+	if (pv && is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
-		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
+		pv = pv_read(cmd, name, NULL, 0, 0);
 	}
 
 	/* Allow partial & exported VGs to be destroyed. */
@@ -1821,20 +1817,18 @@
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 			 			const char *pv_name)
 {
-	struct dm_list mdas;
 	struct physical_volume *pv;
 
-	dm_list_init(&mdas);
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
 
-	if (is_orphan_vg(pv->vg_name) && mdas_empty_or_ignored(&mdas)) {
+	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd, 1))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -2659,8 +2653,8 @@
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), vg->fid,
-				    NULL, NULL, warnings, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev),
+				    vg->fid, NULL, warnings, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -3377,10 +3371,10 @@
  *   FIXME - liblvm todo - make into function that returns handle
  */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				struct dm_list *mdas, uint64_t *label_sector,
-				int warnings, int scan_label_only)
+				uint64_t *label_sector, int warnings,
+				int scan_label_only)
 {
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, mdas, label_sector, warnings, scan_label_only);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, label_sector, warnings, scan_label_only);
 }
 
 /* FIXME Use label functions instead of PV functions */
@@ -3388,7 +3382,6 @@
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings, int scan_label_only)
 {
@@ -3419,8 +3412,7 @@
 	}
 
 	/* FIXME Move more common code up here */
-	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas,
-	      scan_label_only))) {
+	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
 			  pv_name);
 		goto bad;
@@ -4258,8 +4250,5 @@
  */
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
-	struct dm_list mdas;
-
-	dm_list_init(&mdas);
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0);
 }
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:10:59	1.232
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:16:00	1.233
@@ -252,8 +252,7 @@
 	 * Return PV with given path.
 	 */
 	int (*pv_read) (const struct format_type * fmt, const char *pv_name,
-			struct physical_volume * pv, struct dm_list *mdas,
-			int scan_label_only);
+			struct physical_volume * pv, int scan_label_only);
 
 	/*
 	 * Tweak an already filled out a pv ready for importing into a
--- LVM2/tools/pvremove.c	2010/11/23 01:56:02	1.31
+++ LVM2/tools/pvremove.c	2011/02/21 12:16:00	1.32
@@ -25,15 +25,12 @@
 static int pvremove_check(struct cmd_context *cmd, const char *name)
 {
 	struct physical_volume *pv;
-	struct dm_list mdas;
-
-	dm_list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, &mdas, NULL, 1, 0))) {
+	if (!(pv = pv_read(cmd, name, NULL, 1, 0))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
 		log_error("Physical Volume %s not found", name);
@@ -47,13 +44,14 @@
 	 * means checking every VG by scanning every
 	 * PV on the system.
 	 */
-	if (is_orphan(pv) && !dm_list_size(&mdas)) {
+	if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use) &&
+	    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
 		if (!scan_vgs_for_pvs(cmd, 0)) {
 			log_error("Rescan for PVs without metadata areas "
 				  "failed.");
 			return 0;
 		}
-		if (!(pv = pv_read(cmd, name, NULL, NULL, 1, 0))) {
+		if (!(pv = pv_read(cmd, name, NULL, 1, 0))) {
 			log_error("Failed to read physical volume %s", name);
 			return 0;
 		}
--- LVM2/tools/pvresize.c	2011/02/18 14:11:23	1.38
+++ LVM2/tools/pvresize.c	2011/02/21 12:16:00	1.39
@@ -32,28 +32,26 @@
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	int r = 0;
-	struct dm_list mdas;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = pv_vg_name(pv);
 	struct lvmcache_info *info;
 	int mda_count = 0;
 	struct volume_group *old_vg = vg;
 
-	dm_list_init(&mdas);
-
 	if (is_orphan_vg(vg_name)) {
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphans");
 			return 0;
 		}
 
-		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
+		if (!(pv = pv_read(cmd, pv_name, NULL, 1, 0))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
 		}
 
-		mda_count = dm_list_size(&mdas);
+		mda_count = dm_list_size(&pv->fid->metadata_areas_in_use) +
+			    dm_list_size(&pv->fid->metadata_areas_ignored);
 	} else {
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
--- LVM2/tools/toollib.c	2011/02/18 15:02:25	1.221
+++ LVM2/tools/toollib.c	2011/02/21 12:16:00	1.222
@@ -649,7 +649,7 @@
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(pv = pv_read(cmd, dev_name(dev), NULL, NULL, 0, 0))) {
+		if (!(pv = pv_read(cmd, dev_name(dev), NULL, 0, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
 			dm_list_init(&pv_dummy.tags);
 			dm_list_init(&pv_dummy.segments);
@@ -691,7 +691,6 @@
 	struct str_list *sll;
 	char *at_sign, *tagname;
 	int scanned = 0;
-	struct dm_list mdas;
 
 	dm_list_init(&tags);
 
@@ -733,10 +732,8 @@
 				}
 				pv = pvl->pv;
 			} else {
-
-				dm_list_init(&mdas);
-				if (!(pv = pv_read(cmd, argv[opt], &mdas,
-						   NULL, 1, scan_label_only))) {
+				if (!(pv = pv_read(cmd, argv[opt], NULL,
+						   1, scan_label_only))) {
 					log_error("Failed to read physical "
 						  "volume \"%s\"", argv[opt]);
 					ret_max = ECMD_FAILED;
@@ -751,7 +748,8 @@
 				 * PV on the system.
 				 */
 				if (!scanned && is_orphan(pv) &&
-				    !dm_list_size(&mdas)) {
+				    !dm_list_size(&pv->fid->metadata_areas_in_use) &&
+				    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
 					if (!scan_label_only &&
 					    !scan_vgs_for_pvs(cmd, 1)) {
 						stack;
@@ -760,7 +758,7 @@
 					}
 					scanned = 1;
 					if (!(pv = pv_read(cmd, argv[opt],
-							   NULL, NULL, 1,
+							   NULL, 1,
 							   scan_label_only))) {
 						log_error("Failed to read "
 							  "physical volume "


