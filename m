From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 19:52:49 -0000
Subject: LVM2 lib/metadata/metadata.c lib/metadata/meta ...
Message-ID: <20070613195249.11549.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 19:52:48

Modified files:
	lib/metadata   : metadata.c metadata.h 
	.              : WHATS_NEW 

Log message:
	Add typedef pv_handle_t

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.629&r2=1.630

--- LVM2/lib/metadata/metadata.c	2007/06/12 22:41:27	1.113
+++ LVM2/lib/metadata/metadata.c	2007/06/13 19:52:48	1.114
@@ -586,7 +586,7 @@
  * Note:
  *   FIXME - liblvm todo - tidy up arguments for external use (fmt, mdas, etc)
  */
-void *pv_create(const struct format_type *fmt,
+pv_handle_t pv_create(const struct format_type *fmt,
 		struct device *dev,
 		struct id *id, uint64_t size,
 		uint64_t pe_start,
@@ -595,11 +595,11 @@
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct list *mdas)
 {
-	return _pv_create(fmt, dev, id, size, pe_start, 
-			  existing_extent_count,
-			  existing_extent_size,
-			  pvmetadatacopies,
-			  pvmetadatasize, mdas);
+	return (pv_handle_t) _pv_create(fmt, dev, id, size, pe_start, 
+					existing_extent_count,
+					existing_extent_size,
+					pvmetadatacopies,
+					pvmetadatasize, mdas);
 }
 
 /* Sizes in sectors */
@@ -719,9 +719,9 @@
  * Note
  *   FIXME - liblvm todo - make into function that takes VG handle
  */
-void *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
+pv_handle_t find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
 {
-	return _find_pv_in_vg_by_uuid(vg, id);
+	return (pv_handle_t) _find_pv_in_vg_by_uuid(vg, id);
 }
 
 
@@ -1773,57 +1773,57 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id (void *pv_handle)
+struct id get_pv_id (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, id);
 }
 
-const struct format_type *get_pv_format_type (void *pv_handle)
+const struct format_type *get_pv_format_type (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, fmt);
 }
 
-struct id get_pv_vgid (void *pv_handle)
+struct id get_pv_vgid (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, vgid);
 }
 
-struct device *get_pv_dev (void *pv_handle)
+struct device *get_pv_dev (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, dev);
 }
 
-const char *get_pv_vg_name (void *pv_handle)
+const char *get_pv_vg_name (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, vg_name);
 }
 
-uint64_t get_pv_size(void *pv_handle)
+uint64_t get_pv_size(pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, size);
 }
 
-uint32_t get_pv_status (void *pv_handle)
+uint32_t get_pv_status (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, status);
 }
 
-uint32_t get_pv_pe_size (void *pv_handle)
+uint32_t get_pv_pe_size (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, pe_size);
 }
 
-uint64_t get_pv_pe_start (void *pv_handle)
+uint64_t get_pv_pe_start (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, pe_start);
 }
 
-uint32_t get_pv_pe_count (void *pv_handle)
+uint32_t get_pv_pe_count (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, pe_count);
 }
 
-uint32_t get_pv_pe_alloc_count (void *pv_handle)
+uint32_t get_pv_pe_alloc_count (pv_handle_t pv_handle)
 {
 	return pv_field(pv_handle, pe_alloc_count);
 }
--- LVM2/lib/metadata/metadata.h	2007/06/12 22:41:27	1.159
+++ LVM2/lib/metadata/metadata.h	2007/06/13 19:52:48	1.160
@@ -142,6 +142,7 @@
 	struct list tags;
 };
 
+typedef struct physical_volume * pv_handle_t;
 struct metadata_area;
 struct format_instance;
 
@@ -438,15 +439,15 @@
 
 /* pe_start and pe_end relate to any existing data so that new metadata
  * areas can avoid overlap */
-void *pv_create(const struct format_type *fmt,
-		struct device *dev,
-		struct id *id,
-		uint64_t size,
-		uint64_t pe_start,
-		uint32_t existing_extent_count,
-		uint32_t existing_extent_size,
-		int pvmetadatacopies,
-		uint64_t pvmetadatasize, struct list *mdas);
+pv_handle_t pv_create(const struct format_type *fmt,
+		      struct device *dev,
+		      struct id *id,
+		      uint64_t size,
+		      uint64_t pe_start,
+		      uint32_t existing_extent_count,
+		      uint32_t existing_extent_size,
+		      int pvmetadatacopies,
+		      uint64_t pvmetadatasize, struct list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
               uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
@@ -500,7 +501,7 @@
 
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
-void *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
+pv_handle_t find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv);
@@ -637,16 +638,16 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id (void *pv_handle);
-const struct format_type *get_pv_format_type (void *pv_handle);
-struct id get_pv_vgid (void *pv_handle);
-struct device *get_pv_dev (void *pv_handle);
-const char *get_pv_vg_name (void *pv_handle);
-uint64_t get_pv_size(void *pv_handle);
-uint32_t get_pv_status (void *pv_handle);
-uint32_t get_pv_pe_size (void *pv_handle);
-uint64_t get_pv_pe_start (void *pv_handle);
-uint32_t get_pv_pe_count (void *pv_handle);
-uint32_t get_pv_pe_alloc_count (void *pv_handle);
+struct id get_pv_id (pv_handle_t pv_handle);
+const struct format_type *get_pv_format_type (pv_handle_t pv_handle);
+struct id get_pv_vgid (pv_handle_t pv_handle);
+struct device *get_pv_dev (pv_handle_t pv_handle);
+const char *get_pv_vg_name (pv_handle_t pv_handle);
+uint64_t get_pv_size(pv_handle_t pv_handle);
+uint32_t get_pv_status (pv_handle_t pv_handle);
+uint32_t get_pv_pe_size (pv_handle_t pv_handle);
+uint64_t get_pv_pe_start (pv_handle_t pv_handle);
+uint32_t get_pv_pe_count (pv_handle_t pv_handle);
+uint32_t get_pv_pe_alloc_count (pv_handle_t pv_handle);
 
 #endif
--- LVM2/WHATS_NEW	2007/06/13 15:11:19	1.629
+++ LVM2/WHATS_NEW	2007/06/13 19:52:48	1.630
@@ -1,6 +1,6 @@
 Version 2.02.26 -
 =================================
-  Fix a couple benign warnings by adding variable initializations.
+  Suppress a couple benign warnings by adding variable initializations.
   Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
   Add get_pv_* functions to return PV members (external LVM library).
   Add wrappers to some functions in preparation for external LVM library.


