From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 20:55:56 -0000
Subject: LVM2/lib/metadata metadata.c metadata.h
Message-ID: <20070613205556.8830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 20:55:56

Modified files:
	lib/metadata   : metadata.c metadata.h 

Log message:
	Convert pv_handle_t to pv_t * and tidy up whitespace

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/lib/metadata/metadata.c	2007/06/13 19:52:48	1.114
+++ LVM2/lib/metadata/metadata.c	2007/06/13 20:55:56	1.115
@@ -586,7 +586,7 @@
  * Note:
  *   FIXME - liblvm todo - tidy up arguments for external use (fmt, mdas, etc)
  */
-pv_handle_t pv_create(const struct format_type *fmt,
+pv_t *pv_create(const struct format_type *fmt,
 		struct device *dev,
 		struct id *id, uint64_t size,
 		uint64_t pe_start,
@@ -595,7 +595,7 @@
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct list *mdas)
 {
-	return (pv_handle_t) _pv_create(fmt, dev, id, size, pe_start, 
+	return (pv_t *) _pv_create(fmt, dev, id, size, pe_start, 
 					existing_extent_count,
 					existing_extent_size,
 					pvmetadatacopies,
@@ -719,9 +719,9 @@
  * Note
  *   FIXME - liblvm todo - make into function that takes VG handle
  */
-pv_handle_t find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
+pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
 {
-	return (pv_handle_t) _find_pv_in_vg_by_uuid(vg, id);
+	return (pv_t *) _find_pv_in_vg_by_uuid(vg, id);
 }
 
 
@@ -1773,57 +1773,57 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id (pv_handle_t pv_handle)
+struct id get_pv_id(pv_t *pv)
 {
-	return pv_field(pv_handle, id);
+	return pv_field(pv, id);
 }
 
-const struct format_type *get_pv_format_type (pv_handle_t pv_handle)
+const struct format_type *get_pv_format_type(pv_t *pv)
 {
-	return pv_field(pv_handle, fmt);
+	return pv_field(pv, fmt);
 }
 
-struct id get_pv_vgid (pv_handle_t pv_handle)
+struct id get_pv_vgid(pv_t *pv)
 {
-	return pv_field(pv_handle, vgid);
+	return pv_field(pv, vgid);
 }
 
-struct device *get_pv_dev (pv_handle_t pv_handle)
+struct device *get_pv_dev(pv_t *pv)
 {
-	return pv_field(pv_handle, dev);
+	return pv_field(pv, dev);
 }
 
-const char *get_pv_vg_name (pv_handle_t pv_handle)
+const char *get_pv_vg_name(pv_t *pv)
 {
-	return pv_field(pv_handle, vg_name);
+	return pv_field(pv, vg_name);
 }
 
-uint64_t get_pv_size(pv_handle_t pv_handle)
+uint64_t get_pv_size(pv_t *pv)
 {
-	return pv_field(pv_handle, size);
+	return pv_field(pv, size);
 }
 
-uint32_t get_pv_status (pv_handle_t pv_handle)
+uint32_t get_pv_status(pv_t *pv)
 {
-	return pv_field(pv_handle, status);
+	return pv_field(pv, status);
 }
 
-uint32_t get_pv_pe_size (pv_handle_t pv_handle)
+uint32_t get_pv_pe_size(pv_t *pv)
 {
-	return pv_field(pv_handle, pe_size);
+	return pv_field(pv, pe_size);
 }
 
-uint64_t get_pv_pe_start (pv_handle_t pv_handle)
+uint64_t get_pv_pe_start(pv_t *pv)
 {
-	return pv_field(pv_handle, pe_start);
+	return pv_field(pv, pe_start);
 }
 
-uint32_t get_pv_pe_count (pv_handle_t pv_handle)
+uint32_t get_pv_pe_count(pv_t *pv)
 {
-	return pv_field(pv_handle, pe_count);
+	return pv_field(pv, pe_count);
 }
 
-uint32_t get_pv_pe_alloc_count (pv_handle_t pv_handle)
+uint32_t get_pv_pe_alloc_count(pv_t *pv)
 {
-	return pv_field(pv_handle, pe_alloc_count);
+	return pv_field(pv, pe_alloc_count);
 }
--- LVM2/lib/metadata/metadata.h	2007/06/13 19:52:48	1.160
+++ LVM2/lib/metadata/metadata.h	2007/06/13 20:55:56	1.161
@@ -142,7 +142,7 @@
 	struct list tags;
 };
 
-typedef struct physical_volume * pv_handle_t;
+typedef struct physical_volume pv_t;
 struct metadata_area;
 struct format_instance;
 
@@ -439,7 +439,7 @@
 
 /* pe_start and pe_end relate to any existing data so that new metadata
  * areas can avoid overlap */
-pv_handle_t pv_create(const struct format_type *fmt,
+pv_t *pv_create(const struct format_type *fmt,
 		      struct device *dev,
 		      struct id *id,
 		      uint64_t size,
@@ -501,7 +501,7 @@
 
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
-pv_handle_t find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
+pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv);
@@ -638,16 +638,16 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id (pv_handle_t pv_handle);
-const struct format_type *get_pv_format_type (pv_handle_t pv_handle);
-struct id get_pv_vgid (pv_handle_t pv_handle);
-struct device *get_pv_dev (pv_handle_t pv_handle);
-const char *get_pv_vg_name (pv_handle_t pv_handle);
-uint64_t get_pv_size(pv_handle_t pv_handle);
-uint32_t get_pv_status (pv_handle_t pv_handle);
-uint32_t get_pv_pe_size (pv_handle_t pv_handle);
-uint64_t get_pv_pe_start (pv_handle_t pv_handle);
-uint32_t get_pv_pe_count (pv_handle_t pv_handle);
-uint32_t get_pv_pe_alloc_count (pv_handle_t pv_handle);
+struct id get_pv_id(pv_t *pv);
+const struct format_type *get_pv_format_type(pv_t *pv);
+struct id get_pv_vgid(pv_t *pv);
+struct device *get_pv_dev(pv_t *pv);
+const char *get_pv_vg_name(pv_t *pv);
+uint64_t get_pv_size(pv_t *pv);
+uint32_t get_pv_status(pv_t *pv);
+uint32_t get_pv_pe_size(pv_t *pv);
+uint64_t get_pv_pe_start(pv_t *pv);
+uint32_t get_pv_pe_count(pv_t *pv);
+uint32_t get_pv_pe_alloc_count(pv_t *pv);
 
 #endif


