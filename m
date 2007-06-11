From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jun 2007 18:29:31 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20070611182931.19436.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-11 18:29:30

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Add wrappers to functions related to pv commands in preparation for exported LVM lib

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.625&r2=1.626

--- LVM2/lib/metadata/metadata.c	2007/06/06 19:40:27	1.109
+++ LVM2/lib/metadata/metadata.c	2007/06/11 18:29:30	1.110
@@ -28,6 +28,33 @@
 
 #include <sys/param.h>
 
+static struct physical_volume *_pv_read(struct cmd_context *cmd, 
+					const char *pv_name,
+					struct list *mdas, 
+					uint64_t *label_sector,
+					int warnings);
+
+static struct physical_volume *_pv_create(const struct format_type *fmt,
+				  struct device *dev,
+				  struct id *id, uint64_t size,
+				  uint64_t pe_start,
+				  uint32_t existing_extent_count,
+				  uint32_t existing_extent_size,
+				  int pvmetadatacopies,
+				  uint64_t pvmetadatasize, struct list *mdas);
+
+static int _pv_write(struct cmd_context *cmd __attribute((unused)), 
+		     struct physical_volume *pv,
+	     	     struct list *mdas, int64_t label_sector);
+
+static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
+			 			const char *pv_name);
+
+static struct pv_list *_find_pv_in_vg(struct volume_group *vg, const char *pv_name);
+
+static struct physical_volume *_find_pv_in_vg_by_uuid(struct volume_group *vg,
+						      struct id *id);
+
 unsigned long pe_align(void)
 {
 	return MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
@@ -50,7 +77,7 @@
 	}
 
 	list_init(&mdas);
-	if (!(pv = pv_read(fid->fmt->cmd, pv_name, &mdas, NULL, 1))) {
+	if (!(pv = _pv_read(fid->fmt->cmd, pv_name, &mdas, NULL, 1))) {
 		log_error("%s not identified as an existing physical volume",
 			  pv_name);
 		return 0;
@@ -103,7 +130,7 @@
 		return 0;
 	}
 
-	if (find_pv_in_vg(vg, pv_name)) {
+	if (_find_pv_in_vg(vg, pv_name)) {
 		log_error("Physical volume '%s' listed more than once.",
 			  pv_name);
 		return 0;
@@ -533,7 +560,7 @@
 	return 1;
 }
 
-/* Sizes in sectors */
+/* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
@@ -543,6 +570,23 @@
 				  int pvmetadatacopies,
 				  uint64_t pvmetadatasize, struct list *mdas)
 {
+	return _pv_create(fmt, dev, id, size, pe_start, 
+			  existing_extent_count,
+			  existing_extent_size,
+			  pvmetadatacopies,
+			  pvmetadatasize, mdas);
+}
+
+/* Sizes in sectors */
+static struct physical_volume *_pv_create(const struct format_type *fmt,
+				  struct device *dev,
+				  struct id *id, uint64_t size,
+				  uint64_t pe_start,
+				  uint32_t existing_extent_count,
+				  uint32_t existing_extent_size,
+				  int pvmetadatacopies,
+				  uint64_t pvmetadatasize, struct list *mdas)
+{
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
 
@@ -610,8 +654,14 @@
 	return NULL;
 }
 
+/* FIXME: liblvm todo - make into function that returns handle */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name)
 {
+	return _find_pv_in_vg(vg, pv_name);
+}
+
+static struct pv_list *_find_pv_in_vg(struct volume_group *vg, const char *pv_name)
+{
 	struct pv_list *pvl;
 
 	list_iterate_items(pvl, &vg->pvs)
@@ -632,9 +682,17 @@
 	return 0;
 }
 
+/* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *find_pv_in_vg_by_uuid(struct volume_group *vg,
 					      struct id *id)
 {
+	return _find_pv_in_vg_by_uuid(vg, id);
+}
+
+
+static struct physical_volume *_find_pv_in_vg_by_uuid(struct volume_group *vg,
+						      struct id *id)
+{
 	struct pv_list *pvl;
 
 	list_iterate_items(pvl, &vg->pvs)
@@ -691,12 +749,20 @@
 	return NULL;
 }
 
+/* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name)
 {
+	return _find_pv_by_name(cmd, pv_name);
+}
+
+
+static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
+			 			const char *pv_name)
+{
 	struct physical_volume *pv;
 
-	if (!(pv = pv_read(cmd, pv_name, NULL, NULL, 1))) {
+	if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -980,7 +1046,7 @@
 	}
 
 	list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = pv_read(cmd, dev_name(info->dev), NULL, NULL, 1))) {
+		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
@@ -1386,11 +1452,21 @@
 	return lvl->lv;
 }
 
-/* FIXME Use label functions instead of PV functions */
+/* FIXME: liblvm todo - make into function that returns handle */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct list *mdas, uint64_t *label_sector,
 				int warnings)
 {
+	return _pv_read(cmd, pv_name, mdas, label_sector, warnings);
+}
+
+/* FIXME Use label functions instead of PV functions */
+static struct physical_volume *_pv_read(struct cmd_context *cmd, 
+					const char *pv_name,
+					struct list *mdas, 
+					uint64_t *label_sector,
+					int warnings)
+{
 	struct physical_volume *pv;
 	struct label *label;
 	struct lvmcache_info *info;
@@ -1510,9 +1586,18 @@
 	return results;
 }
 
-int pv_write(struct cmd_context *cmd __attribute((unused)), struct physical_volume *pv,
+/* FIXME: liblvm todo - make into function that takes handle */
+int pv_write(struct cmd_context *cmd __attribute((unused)),
+	     struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector)
 {
+	return _pv_write(cmd, pv, mdas, label_sector);
+}
+
+static int _pv_write(struct cmd_context *cmd __attribute((unused)), 
+		     struct physical_volume *pv,
+	     	     struct list *mdas, int64_t label_sector)
+{
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
 		return 0;
@@ -1544,7 +1629,7 @@
 		return 0;
 	}
 
-	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!_pv_write(cmd, pv, NULL, INT64_C(-1))) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  dev_name(pv->dev), old_vg_name);
--- LVM2/WHATS_NEW	2007/06/08 22:38:48	1.625
+++ LVM2/WHATS_NEW	2007/06/11 18:29:30	1.626
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Add wrappers to some functions in preparation for external LVM library.
   Allow vgcfgrestore to list metadata backup files using -f
   Add vg_check_status to consolidate vg status checks and error messages.
   Add pvdisplay --maps implementation.


