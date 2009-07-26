From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:35:58 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090726163558.21864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:35:57

Modified files:
	liblvm         : lvm.h 

Log message:
	Update lvm.h - comments describing function behavior, divide into sections.
	
	Hard to divide into smaller patches because of the moving around and
	commenting, so just put in the new file diffs.  We will review and can
	update as necessary.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/liblvm/lvm.h	2009/07/26 16:11:58	1.20
+++ LVM2/liblvm/lvm.h	2009/07/26 16:35:57	1.21
@@ -110,13 +110,6 @@
 	const char *str;
 };
 
-/**
- * Return a list of LV handles for a given VG handle.
- *
- * \return  A list of lv_list_t structures containing lv handles for this vg.
- *          If no LVs exist on the given VG, NULL is returned.
- */
-struct dm_list *lvm_vg_list_lvs(vg_t *vg);
 /*************************** generic lvm handling ***************************/
 
 /**
@@ -146,65 +139,105 @@
 /**
  * Reload the original configuration from the system directory.
  *
+ * This function should be used when any system configuration changes,
+ * and the change is needed by the application.
+ *
  * \param   libh
  *          Handle obtained from lvm_create.
  */
 int lvm_reload_config(lvm_t libh);
 
 /**
- * Create a linear logical volume.
- * This API commits the change to disk and does _not_ require calling
- * lvm_vg_write.
- * FIXME: This API should probably not commit to disk but require calling
- * lvm_vg_write.  However, this appears to be non-trivial change until
- * lv_create_single is refactored by segtype.
+ * Return stored error no describing last LVM API error.
  *
- * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * Users of liblvm should use lvm_errno to determine success or failure
+ * of the last call, unless the API indicates another method of determining
+ * success or failure.
  *
- * \param   name
- *          Name of logical volume to create.
+ * \param   libh
+ *          Handle obtained from lvm_create.
  *
- * \param   size
- *          Size of logical volume in extents.
+ * \return  An errno value describing the last LVM error.
+ */
+int lvm_errno(lvm_t libh);
+
+/**
+ * Return stored error message describing last LVM error.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
  *
+ * \return  An error string describing the last LVM error.
  */
-lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
+const char *lvm_errmsg(lvm_t libh);
 
 /**
- * Remove a logical volume from a volume group.
- * This API commits the change to disk and does _not_ require calling
- * lvm_vg_write.
- * Currently only removing linear LVs are possible.
+ * Scan all devices on the system for VGs and LVM metadata.
  *
- * FIXME: This API should probably not commit to disk but require calling
- * lvm_vg_write.
+ * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_remove_lv(lv_t *lv);
+int lvm_scan_vgs(lvm_t libh);
+
+/*************************** volume group handling **************************/
 
 /**
- * Return stored error no describing last LVM API error.
+ * Return the list of volume group names.
  *
- * Users of liblvm should use lvm_errno to determine success or failure
- * of the last call, unless the API indicates another method of determining
- * success or failure.
+ * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
+ * To scan the system, use lvm_scan_vgs.
+ *
+ * To process the list, use the dm_list iterator functions.  For example:
+ *      vg_t *vg;
+ *      struct dm_list *vgnames;
+ *      struct lvm_str_list *strl;
+ *
+ *      vgnames = lvm_list_vg_names(libh);
+ *	dm_list_iterate_items(strl, vgnames) {
+ *		vgname = strl->str;
+ *              vg = lvm_vg_open(libh, vgname, "r");
+ *              // do something with vg
+ *              lvm_vg_close(vg);
+ *      }
+ *
+ *
+ * \return  A list of struct lvm_str_list
+ *          If no VGs exist on the system, NULL is returned.
+ *
+ * FIXME: handle list memory cleanup
+ */
+struct dm_list *lvm_list_vg_names(lvm_t libh);
+
+/**
+ * Return the list of volume group uuids.
+ *
+ * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
+ * To scan the system, use lvm_scan_vgs.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
  *
- * \return  An errno value describing the last LVM error.
+ * \return  List of copied uuid strings.
  */
-int lvm_errno(lvm_t libh);
+struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
 /**
- * Return stored error message describing last LVM error.
+ * Open an existing VG.
+ *
+ * Open a VG for reading or writing.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
- *
- * \return  An error string describing the last LVM error.
+ * \param   vgname
+ *          Name of the VG to open.
+ * \param   mode
+ *          Open mode - either "r" (read) or "w" (read/write).
+ *          Any other character results in an error with EINVAL set.
+ * \param   flags
+ *          Open flags - currently ignored.
+ * \return  non-NULL VG handle (success) or NULL (failure).
  */
-const char *lvm_errmsg(lvm_t libh);
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags);
 
 /**
  * Create a VG with default parameters.
@@ -220,11 +253,48 @@
  *
  * \param   libh
  *          Handle obtained from lvm_create.
- *
+ * \param   vg_name
+ *          Name of the VG to open.
  * \return  non-NULL vg handle (success) or NULL (failure)
  */
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
 
+ /**
+ * Write a VG to disk.
+ *
+ * This API commits the VG to disk.
+ * Upon failure, retry the operation and/or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_write(vg_t *vg);
+
+/**
+ * Remove a VG from the system.
+ *
+ * This API commits the change to disk and does not require calling
+ * lvm_vg_write.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_remove(vg_t *vg);
+
+/**
+ * Close a VG opened with lvm_vg_create
+ *
+ * This API releases a VG handle and any resources associated with the handle.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_close(vg_t *vg);
+
 /**
  * Extend a VG by adding a device.
  *
@@ -238,11 +308,9 @@
  * before calling lvm_vg_extend.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create.
- *
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   device
  *          Name of device to add to VG.
- *
  * \return  Status code of 1 (success) or 0 (failure).
  */
 int lvm_vg_extend(vg_t *vg, const char *device);
@@ -256,148 +324,220 @@
  * handle with lvm_vg_close.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create.
- *
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   new_size
  *          New extent size to set (in sectors).
- *
  * \return  Status code of 1 (success) or 0 (failure).
  */
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
 
 /**
- * Write a VG to disk.
+ * Get the current name of a volume group.
  *
- * This API commits the VG to disk.
- * Upon failure, retry the operation and/or release the VG handle with
- * lvm_vg_close.
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create.
- *
- * \return  Status code of 1 (success) or 0 (failure).
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Copy of the uuid string.
  */
-int lvm_vg_write(vg_t *vg);
+char *lvm_vg_get_uuid(const vg_t *vg);
 
 /**
- * Remove a VG from the system.
+ * Get the current uuid of a volume group.
  *
- * This API commits the change to disk and does not require calling
- * lvm_vg_write.
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create.
- *
- * \return  Status code of 1 (success) or 0 (failure).
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Copy of the name.
  */
-int lvm_vg_remove(vg_t *vg);
+char *lvm_vg_get_name(const vg_t *vg);
 
 /**
- * Get the current name or uuid of a PV, VG, or LV.
+ * Get the current size in bytes of a volume group.
  *
- * Returns a copy of the current name or uuid for the given PV,
- * VG, or LV.
- *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Size in bytes.
  */
-char *lvm_pv_get_uuid(const pv_t *pv);
-char *lvm_vg_get_uuid(const vg_t *vg);
-char *lvm_lv_get_uuid(const lv_t *lv);
-char *lvm_pv_get_name(const pv_t *pv);
-char *lvm_vg_get_name(const vg_t *vg);
-char *lvm_lv_get_name(const lv_t *lv);
+uint64_t lvm_vg_get_size(const vg_t *vg);
 
 /**
- * Get various pv, vg, or lv properties.
- * For full description of each property, consult the man pages for pvs,
- * vgs, and lvs.
- * FIXME: What value to return for invalid handle or other errors?
+ * Get the current unallocated space in bytes of a volume group.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Free size in bytes.
  */
-uint64_t lvm_pv_get_mda_count(const pv_t *pv);
-uint64_t lvm_vg_get_size(const vg_t *vg);
 uint64_t lvm_vg_get_free_size(const vg_t *vg);
+
+/**
+ * Get the current extent size in bytes of a volume group.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Extent size in bytes.
+ */
 uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+
+/**
+ * Get the current number of total extents of a volume group.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Extent count.
+ */
 uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+
+/**
+ * Get the current number of free extents of a volume group.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Free extent count.
+ */
 uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
+
+/**
+ * Get the current number of physical volumes of a volume group.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  Physical volume count.
+ */
 uint64_t lvm_vg_get_pv_count(const vg_t *vg);
-uint64_t lvm_lv_get_size(const lv_t *lv);
+
+/************************** logical volume handling *************************/
 
 /**
- * Close a VG opened with lvm_vg_create
+ * Return a list of LV handles for a given VG handle.
  *
- * This API releases a VG handle and any resources associated with the handle.
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \return  A list of lv_list_t structures containing lv handles for this vg.
+ *          If no LVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_lvs(vg_t *vg);
+
+/**
+ * Create a linear logical volume.
+ * This API commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * FIXME: This API should probably not commit to disk but require calling
+ * lvm_vg_write.  However, this appears to be non-trivial change until
+ * lv_create_single is refactored by segtype.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create.
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * \param   name
+ *          Name of logical volume to create.
+ * \param   size
+ *          Size of logical volume in extents.
+ * \return  LV object
  *
- * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_close(vg_t *vg);
+lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
 
 /**
- * Open an existing VG.
+ * Remove a logical volume from a volume group.
  *
- * Open a VG for reading or writing.
+ * This function commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * Currently only removing linear LVs are possible.
  *
- * \param   libh
- *          Handle obtained from lvm_create.
+ * FIXME: This API should probably not commit to disk but require calling
+ * lvm_vg_write.
  *
- * \param   vgname
- *          Name of the VG to open.
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_remove_lv(lv_t *lv);
+
+/**
+ * Get the current name of a logical volume.
  *
- * \param   mode
- *          Open mode - either "r" (read) or "w" (read/write).
- *          Any other character results in an error with EINVAL set.
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
  *
- * \param   flags
- *          Open flags - currently ignored.
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Copy of the uuid string.
+ */
+char *lvm_lv_get_uuid(const lv_t *lv);
+
+/**
+ * Get the current uuid of a logical volume.
  *
- * \return  non-NULL VG handle (success) or NULL (failure).
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Copy of the name.
+ */
+char *lvm_lv_get_name(const lv_t *lv);
+
+/**
+ * Get the current size in bytes of a logical volume.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Size in bytes.
+ */
+uint64_t lvm_lv_get_size(const lv_t *lv);
+
+/************************** physical volume handling ************************/
+
+/**
+ * Physical volume handling should not be needed anymore. Only physical volumes
+ * bound to a vg contain useful information. Therefore the creation,
+ * modification and the removal of orphan physical volumes is not suported.
  */
-vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
-		  uint32_t flags);
 
 /**
  * Return a list of PV handles for a given VG handle.
  *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \return  A list of pv_list_t structures containing pv handles for this vg.
  *          If no PVs exist on the given VG, NULL is returned.
  */
 struct dm_list *lvm_vg_list_pvs(vg_t *vg);
 
 /**
- * Return a list of VG names or VG uuids in the system.
+ * Get the current uuid of a logical volume.
  *
- * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
- * To scan the system, use lvm_scan_vgs.
- *
- * To process the list, use the dm_list iterator functions.  For example:
- *      vg_t *vg;
- *      struct dm_list *vgnames;
- *      struct lvm_str_list *strl;
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
  *
- *      vgnames = lvm_list_vg_names(libh);
- *	dm_list_iterate_items(strl, vgnames) {
- *		vgname = strl->str;
- *              vg = lvm_vg_open(libh, vgname, "r");
- *              // do something with vg
- *              lvm_vg_close(vg);
- *      }
+ * \param   pv
+ *          Physical volume handle.
+ * \return  Copy of the uuid string.
+ */
+char *lvm_pv_get_uuid(const pv_t *pv);
+
+/**
+ * Get the current name of a logical volume.
  *
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
  *
- * \return  A list of struct lvm_str_list
- *          If no VGs exist on the system, NULL is returned.
- * FIXME: handle list memory cleanup
+ * \param   pv
+ *          Physical volume handle.
+ * \return  Copy of the name.
  */
-struct dm_list *lvm_list_vg_names(lvm_t libh);
-struct dm_list *lvm_list_vg_uuids(lvm_t libh);
+char *lvm_pv_get_name(const pv_t *pv);
 
 /**
- * Scan all devices on the system for VGs and LVM metadata.
+ * Get the current number of metadata areas in the physical volume.
  *
- * \return  Status code of 1 (success) or 0 (failure).
+ * \param   pv
+ *          Physical volume handle.
+ * \return  metadata area count.
  */
-int lvm_scan_vgs(lvm_t libh);
+uint64_t lvm_pv_get_mda_count(const pv_t *pv);
 
 #endif /* _LIB_LVM_H */


