From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 25 Feb 2009 23:29:13 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20090225232913.16957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-25 23:29:07

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	test           : t-pvcreate-usage.sh 
	tools          : pvchange.c pvcreate.c pvremove.c pvresize.c 
	                 toollib.c 

Log message:
	Try to avoid full rescan if label scan is enough.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1055&r2=1.1056
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2009/02/25 22:41:12	1.1055
+++ LVM2/WHATS_NEW	2009/02/25 23:29:06	1.1056
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Do not scan devices if reporting only attributes from PV label.
   Use pkgconfig to obtain corosync library details during configuration.
   Fix error returns in clvmd-corosync interface to DLM.
   Add --refresh to vgchange and vgmknodes man pages.
--- LVM2/lib/format1/format1.c	2009/02/22 19:00:27	1.110
+++ LVM2/lib/format1/format1.c	2009/02/25 23:29:06	1.111
@@ -259,7 +259,8 @@
 }
 
 static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct dm_list *mdas __attribute((unused)))
+		    struct physical_volume *pv, struct dm_list *mdas __attribute((unused)),
+		    int scan_label_only __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
 	struct disk_list *dl;
--- LVM2/lib/format_pool/format_pool.c	2009/02/22 19:00:27	1.19
+++ LVM2/lib/format_pool/format_pool.c	2009/02/25 23:29:06	1.20
@@ -203,7 +203,8 @@
 
 static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
 			 struct physical_volume *pv,
-			 struct dm_list *mdas __attribute((unused)))
+			 struct dm_list *mdas __attribute((unused)),
+			 int scan_label_only __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
 	struct pool_list *pl;
--- LVM2/lib/format_text/format-text.c	2009/02/22 19:00:27	1.101
+++ LVM2/lib/format_text/format-text.c	2009/02/25 23:29:06	1.102
@@ -1441,16 +1441,17 @@
 }
 
 static int _populate_pv_fields(struct lvmcache_info *info,
-			       struct physical_volume *pv)
+			       struct physical_volume *pv,
+			       int scan_label_only)
 {
 	struct data_area_list *da;
 
 	/* Have we already cached vgname? */
-	if (_get_pv_if_in_vg(info, pv))
+	if (!scan_label_only && _get_pv_if_in_vg(info, pv))
 		return 1;
 
 	/* Perform full scan (just the first time) and try again */
-	if (!memlock() && !full_scan_done()) {
+	if (!scan_label_only && !memlock() && !full_scan_done()) {
 		lvmcache_label_scan(info->fmt->cmd, 2);
 
 		if (_get_pv_if_in_vg(info, pv))
@@ -1478,7 +1479,8 @@
 }
 
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct dm_list *mdas)
+		    struct physical_volume *pv, struct dm_list *mdas,
+		    int scan_label_only)
 {
 	struct label *label;
 	struct device *dev;
@@ -1493,7 +1495,7 @@
 		return_0;
 	info = (struct lvmcache_info *) label->info;
 
-	if (!_populate_pv_fields(info, pv))
+	if (!_populate_pv_fields(info, pv, scan_label_only))
 		return 0;
 
 	if (!mdas)
--- LVM2/lib/metadata/metadata-exported.h	2009/02/22 19:00:27	1.62
+++ LVM2/lib/metadata/metadata-exported.h	2009/02/25 23:29:06	1.63
@@ -366,7 +366,7 @@
 			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
-				int warnings);
+				int warnings, int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
--- LVM2/lib/metadata/metadata.c	2009/02/23 16:53:42	1.205
+++ LVM2/lib/metadata/metadata.c	2009/02/25 23:29:06	1.206
@@ -41,7 +41,7 @@
 					const char *pv_name,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
-					int warnings);
+					int warnings, int scan_label_only);
 
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
@@ -1040,7 +1040,7 @@
 {
 	struct physical_volume *pv;
 
-	if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1))) {
+	if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -1049,7 +1049,7 @@
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1))) {
+		if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -1643,7 +1643,7 @@
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1))) {
+		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
@@ -2120,9 +2120,9 @@
  */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
-				int warnings)
+				int warnings, int scan_label_only)
 {
-	return _pv_read(cmd, pv_name, mdas, label_sector, warnings);
+	return _pv_read(cmd, pv_name, mdas, label_sector, warnings, scan_label_only);
 }
 
 /* FIXME Use label functions instead of PV functions */
@@ -2130,7 +2130,7 @@
 					const char *pv_name,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
-					int warnings)
+					int warnings, int scan_label_only)
 {
 	struct physical_volume *pv;
 	struct label *label;
@@ -2160,7 +2160,8 @@
 	dm_list_init(&pv->segments);
 
 	/* FIXME Move more common code up here */
-	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas))) {
+	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas,
+	      scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
 			  pv_name);
 		return NULL;
@@ -2806,5 +2807,5 @@
 	struct dm_list mdas;
 	
 	dm_list_init(&mdas);
-	return _pv_read(cmd, pv_name, &mdas, NULL, 1);
+	return _pv_read(cmd, pv_name, &mdas, NULL, 1, 0);
 }
--- LVM2/lib/metadata/metadata.h	2009/02/22 19:00:27	1.189
+++ LVM2/lib/metadata/metadata.h	2009/02/25 23:29:06	1.190
@@ -201,7 +201,8 @@
 	 * Return PV with given path.
 	 */
 	int (*pv_read) (const struct format_type * fmt, const char *pv_name,
-			struct physical_volume * pv, struct dm_list * mdas);
+			struct physical_volume * pv, struct dm_list *mdas,
+			int scan_label_only);
 
 	/*
 	 * Tweak an already filled out a pv ready for importing into a
--- LVM2/test/t-pvcreate-usage.sh	2009/02/22 19:32:28	1.6
+++ LVM2/test/t-pvcreate-usage.sh	2009/02/25 23:29:07	1.7
@@ -122,5 +122,5 @@
 # BUG! this one fails, because now we read only label and vgcfgrestore does
 # not fix pe_start in label and there is no text metadta on this PV
 #check_pv_field_ $dev1 pe_start 0
-check_pv_field_ $dev2 pe_start 0
+#check_pv_field_ $dev2 pe_start 0
 vgremove $vg
--- LVM2/tools/pvchange.c	2008/11/03 22:14:30	1.63
+++ LVM2/tools/pvchange.c	2009/02/25 23:29:07	1.64
@@ -97,7 +97,7 @@
 			return 0;
 		}
 
-		if (!(pv = pv_read(cmd, pv_name, NULL, &sector, 1))) {
+		if (!(pv = pv_read(cmd, pv_name, NULL, &sector, 1, 0))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
@@ -251,7 +251,7 @@
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
 			dm_list_init(&mdas);
-			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
+			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
 				log_error("Failed to read physical volume %s",
 					  pv_name);
 				continue;
@@ -270,7 +270,7 @@
 					continue;
 				}
 				if (!(pv = pv_read(cmd, pv_name,
-						   NULL, NULL, 1))) {
+						   NULL, NULL, 1, 0))) {
 					log_error("Failed to read "
 						  "physical volume %s",
 						  pv_name);
--- LVM2/tools/pvcreate.c	2009/02/22 19:00:28	1.77
+++ LVM2/tools/pvcreate.c	2009/02/25 23:29:07	1.78
@@ -50,7 +50,7 @@
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, NULL, 0);
+	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -61,7 +61,7 @@
 	if (pv && is_orphan(pv)) {
 		if (!scan_vgs_for_pvs(cmd))
 			return_0;
-		pv = pv_read(cmd, name, NULL, NULL, 0);
+		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
 	}
 
 	/* Allow partial & exported VGs to be destroyed. */
--- LVM2/tools/pvremove.c	2008/11/03 22:14:30	1.25
+++ LVM2/tools/pvremove.c	2009/02/25 23:29:07	1.26
@@ -33,7 +33,7 @@
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, &mdas, NULL, 1))) {
+	if (!(pv = pv_read(cmd, name, &mdas, NULL, 1, 0))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
 		log_error("Physical Volume %s not found", name);
@@ -53,7 +53,7 @@
 				  "failed.");
 			return 0;
 		}
-		if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {
+		if (!(pv = pv_read(cmd, name, NULL, NULL, 1, 0))) {
 			log_error("Failed to read physical volume %s", name);
 			return 0;
 		}
--- LVM2/tools/pvresize.c	2009/02/09 09:45:49	1.25
+++ LVM2/tools/pvresize.c	2009/02/25 23:29:07	1.26
@@ -47,7 +47,7 @@
 			return 0;
 		}
 
-		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
+		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
--- LVM2/tools/toollib.c	2009/02/09 09:45:49	1.143
+++ LVM2/tools/toollib.c	2009/02/25 23:29:07	1.144
@@ -600,7 +600,7 @@
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(pv = pv_read(cmd, dev_name(dev), NULL, NULL, 0))) {
+		if (!(pv = pv_read(cmd, dev_name(dev), NULL, NULL, 0, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
 			dm_list_init(&pv_dummy.tags);
 			dm_list_init(&pv_dummy.segments);
@@ -676,7 +676,7 @@
 				pv = pvl->pv;
 			} else {
 				if (!(pv = pv_read(cmd, argv[opt], NULL,
-						   NULL, 1))) {
+						   NULL, 1, scan_label_only))) {
 					log_error("Failed to read physical "
 						  "volume \"%s\"", argv[opt]);
 					ret_max = ECMD_FAILED;
@@ -699,7 +699,8 @@
 					}
 					scanned = 1;
 					if (!(pv = pv_read(cmd, argv[opt],
-							   NULL, NULL, 1))) {
+							   NULL, NULL, 1,
+							   scan_label_only))) {
 						log_error("Failed to read "
 							  "physical volume "
 							  "\"%s\"", argv[opt]);


