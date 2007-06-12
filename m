From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jun 2007 22:41:28 -0000
Subject: LVM2 ./WHATS_NEW tools/pvcreate.c lib/metadata ...
Message-ID: <20070612224128.15301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-12 22:41:27

Modified files:
	.              : WHATS_NEW 
	tools          : pvcreate.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Convert find_pv_in_vg_by_uuid and pv_create to use PV handles

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.627&r2=1.628
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/WHATS_NEW	2007/06/12 21:20:20	1.627
+++ LVM2/WHATS_NEW	2007/06/12 22:41:27	1.628
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
   Add get_pv_* functions to return PV members (external LVM library).
   Add wrappers to some functions in preparation for external LVM library.
   Allow vgcfgrestore to list metadata backup files using -f
--- LVM2/tools/pvcreate.c	2006/05/16 16:48:31	1.48
+++ LVM2/tools/pvcreate.c	2007/06/12 22:41:27	1.49
@@ -118,7 +118,8 @@
 			   void *handle)
 {
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
-	struct physical_volume *pv, *existing_pv;
+	void *pv;
+	void *existing_pv;
 	struct id id, *idp = NULL;
 	const char *uuid = NULL;
 	uint64_t size = 0;
@@ -159,9 +160,9 @@
 				  uuid, restorefile);
 			return ECMD_FAILED;
 		}
-		pe_start = existing_pv->pe_start;
-		extent_size = existing_pv->pe_size;
-		extent_count = existing_pv->pe_count;
+		pe_start = get_pv_pe_start(existing_pv);
+		extent_size = get_pv_pe_size(existing_pv);
+		extent_count = get_pv_pe_count(existing_pv);
 	}
 
 	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
@@ -210,10 +211,10 @@
 	}
 
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-		    " available sectors", pv_name, pv->size);
+		    " available sectors", pv_name, get_pv_size(pv));
 
 	/* Wipe existing label first */
-	if (!label_remove(pv->dev)) {
+	if (!label_remove(get_pv_dev(pv))) {
 		log_error("Failed to wipe existing label on %s", pv_name);
 		goto error;
 	}
@@ -235,7 +236,8 @@
 
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
-	if (!(pv_write(cmd, pv, &mdas, arg_int64_value(cmd, labelsector_ARG,
+	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
+		       arg_int64_value(cmd, labelsector_ARG,
 						       DEFAULT_LABELSECTOR)))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
--- LVM2/lib/metadata/metadata.c	2007/06/12 21:39:49	1.112
+++ LVM2/lib/metadata/metadata.c	2007/06/12 22:41:27	1.113
@@ -566,15 +566,34 @@
 	return 1;
 }
 
-/* FIXME: liblvm todo - make into function that returns handle */
-struct physical_volume *pv_create(const struct format_type *fmt,
-				  struct device *dev,
-				  struct id *id, uint64_t size,
-				  uint64_t pe_start,
-				  uint32_t existing_extent_count,
-				  uint32_t existing_extent_size,
-				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct list *mdas)
+/**
+ * pv_create - initialize a physical volume for use with a volume group
+ * @fmt: format type
+ * @dev: PV device to initialize
+ * @id: PV UUID to use for initialization
+ * @size: size of the PV in sectors
+ * @pe_start: physical extent start
+ * @existing_extent_count
+ * @existing_extent_size
+ * @pvmetadatacopies
+ * @pvmetadatasize
+ * @mdas
+ *
+ * Returns:
+ *   PV handle - physical volume initialized successfully
+ *   NULL - invalid parameter or problem initializing the physical volume
+ *
+ * Note:
+ *   FIXME - liblvm todo - tidy up arguments for external use (fmt, mdas, etc)
+ */
+void *pv_create(const struct format_type *fmt,
+		struct device *dev,
+		struct id *id, uint64_t size,
+		uint64_t pe_start,
+		uint32_t existing_extent_count,
+		uint32_t existing_extent_size,
+		int pvmetadatacopies,
+		uint64_t pvmetadatasize, struct list *mdas)
 {
 	return _pv_create(fmt, dev, id, size, pe_start, 
 			  existing_extent_count,
@@ -688,9 +707,19 @@
 	return 0;
 }
 
-/* FIXME: liblvm todo - make into function that returns handle */
-struct physical_volume *find_pv_in_vg_by_uuid(struct volume_group *vg,
-					      struct id *id)
+/**
+ * find_pv_in_vg_by_uuid - Find PV in VG by PV UUID
+ * @vg: volume group to search
+ * @id: UUID of the PV to match
+ *
+ * Returns:
+ *   PV handle - if UUID of PV found in VG
+ *   NULL - invalid parameter or UUID of PV not found in VG
+ *
+ * Note
+ *   FIXME - liblvm todo - make into function that takes VG handle
+ */
+void *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
 {
 	return _find_pv_in_vg_by_uuid(vg, id);
 }
--- LVM2/lib/metadata/metadata.h	2007/06/12 21:20:20	1.158
+++ LVM2/lib/metadata/metadata.h	2007/06/12 22:41:27	1.159
@@ -438,15 +438,15 @@
 
 /* pe_start and pe_end relate to any existing data so that new metadata
  * areas can avoid overlap */
-struct physical_volume *pv_create(const struct format_type *fmt,
-				  struct device *dev,
-				  struct id *id,
-				  uint64_t size,
-				  uint64_t pe_start,
-				  uint32_t existing_extent_count,
-				  uint32_t existing_extent_size,
-				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct list *mdas);
+void *pv_create(const struct format_type *fmt,
+		struct device *dev,
+		struct id *id,
+		uint64_t size,
+		uint64_t pe_start,
+		uint32_t existing_extent_count,
+		uint32_t existing_extent_size,
+		int pvmetadatacopies,
+		uint64_t pvmetadatasize, struct list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
               uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
@@ -500,8 +500,7 @@
 
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
-struct physical_volume *find_pv_in_vg_by_uuid(struct volume_group *vg,
-					      struct id *id);
+void *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv);


