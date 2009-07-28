From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 12:19:58 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090728121958.20705.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 12:19:58

Modified files:
	liblvm         : lvm.h 

Log message:
	Fix lvm.h formatting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/liblvm/lvm.h	2009/07/28 11:03:28	1.37
+++ LVM2/liblvm/lvm.h	2009/07/28 12:19:58	1.38
@@ -136,18 +136,17 @@
  * Once all LVM operations have been completed, use lvm_quit to release
  * the handle and any associated resources.
  *
- * \param   system_dir
- *          Set an alternative LVM system directory. Use NULL to use the
- *          default value. If the environment variable LVM_SYSTEM_DIR is set,
- *          it will override any system_dir setting.
- * \return  A valid LVM handle is returned or NULL if there has been a
- *          memory allocation problem. You have to check if an error occured
- *          with the lvm_error function.
+ * \param system_dir
+ * Set an alternative LVM system directory. Use NULL to use the
+ * default value. If the environment variable LVM_SYSTEM_DIR is set,
+ * it will override any system_dir setting.
+ *
+ * \return
+ * A valid LVM handle is returned or NULL if there has been a
+ * memory allocation problem. You have to check if an error occured
+ * with the lvm_error function.
  */
-// FIXME: Sort out this alignment.  "Set an" directly below "system_dir"
-// looks awful.  Indent differently?  More blank lines?
 lvm_t lvm_init(const char *system_dir);
-// FIXME Find a better name.  lvm_init.
 
 /**
  * Destroy a LVM handle allocated with lvm_init.
@@ -158,7 +157,7 @@
  * cannot be used subsequently.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
  */
 void lvm_quit(lvm_t libh);
 
@@ -170,8 +169,10 @@
  * the application.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
- * \return  0 (success) or -1 (failure).
+ * Handle obtained from lvm_init.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_config_reload(lvm_t libh);
 
@@ -184,11 +185,14 @@
  * you should use lvm_config_reload to apply the new settings.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
+ *
  * \param   config_string
- *          LVM configuration string to apply.  See the lvm.conf file man page
- *          for the format of the config string.
- * \return  0 (success) or -1 (failure).
+ * LVM configuration string to apply.  See the lvm.conf file man page
+ * for the format of the config string.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_config_override(lvm_t libh, const char *config_string);
 
@@ -204,9 +208,10 @@
  * returns a value.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
  *
- * \return  An errno value describing the last LVM error.
+ * \return
+ * An errno value describing the last LVM error.
  */
 int lvm_errno(lvm_t libh);
 
@@ -217,9 +222,10 @@
  * specific error information for a function that is known to have failed.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
  *
- * \return  An error string describing the last LVM error.
+ * \return
+ * An error string describing the last LVM error.
  */
 const char *lvm_errmsg(lvm_t libh);
 
@@ -227,7 +233,8 @@
  * Scan all devices on the system for VGs and LVM metadata.
  * FIXME: Elaborate on when to use, side-effects, .cache file, etc
  *
- * \return  0 (success) or -1 (failure).
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_scan(lvm_t libh);
 
@@ -258,11 +265,12 @@
  *      }
  *
  *
- * \return  A list with entries of type struct lvm_str_list, containing the
- *          VG name strings of the Volume Groups known to the system.
- *          NULL is returned if unable to allocate memory.
- *          An empty list (verify with dm_list_empty) is returned if no VGs
- *          exist on the system.
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * VG name strings of the Volume Groups known to the system.
+ * NULL is returned if unable to allocate memory.
+ * An empty list (verify with dm_list_empty) is returned if no VGs
+ * exist on the system.
  */
 struct dm_list *lvm_list_vg_names(lvm_t libh);
 
@@ -278,13 +286,14 @@
  * begin with a "#" and should be filtered out and not used.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
  *
- * \return  A list with entries of type struct lvm_str_list, containing the
- *          VG UUID strings of the Volume Groups known to the system.
- *          NULL is returned if unable to allocate memory.
- *          An empty list (verify with dm_list_empty) is returned if no VGs
- *          exist on the system.
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * VG UUID strings of the Volume Groups known to the system.
+ * NULL is returned if unable to allocate memory.
+ * An empty list (verify with dm_list_empty) is returned if no VGs
+ * exist on the system.
  */
 struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
@@ -294,14 +303,18 @@
  * Open a VG for reading or writing.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
+ *
  * \param   vgname
- *          Name of the VG to open.
+ * Name of the VG to open.
+ *
  * \param   mode
- *          Open mode - either "r" (read) or "w" (read/write).
- *          Any other character results in an error with EINVAL set.
+ * Open mode - either "r" (read) or "w" (read/write).
+ * Any other character results in an error with EINVAL set.
+ *
  * \param   flags
- *          Open flags - currently ignored.
+ * Open flags - currently ignored.
+ *
  * \return  non-NULL VG handle (success) or NULL (failure).
  */
 vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
@@ -320,10 +333,13 @@
  * release the VG handle.
  *
  * \param   libh
- *          Handle obtained from lvm_init.
+ * Handle obtained from lvm_init.
+ *
  * \param   vg_name
- *          Name of the VG to open.
- * \return  non-NULL vg handle (success) or NULL (failure)
+ * Name of the VG to open.
+ *
+ * \return
+ * non-NULL vg handle (success) or NULL (failure)
  */
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
 
@@ -335,8 +351,10 @@
  * with lvm_vg_close.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  0 (success) or -1 (failure).
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_write(vg_t *vg);
 
@@ -347,8 +365,10 @@
  * lvm_vg_write.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  0 (success) or -1 (failure).
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_remove(vg_t *vg);
 
@@ -359,8 +379,10 @@
  * handle.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  0 (success) or -1 (failure).
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_close(vg_t *vg);
 
@@ -377,10 +399,13 @@
  * before calling lvm_vg_extend.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
  * \param   device
- *          Absolute pathname of device to add to VG.
- * \return  0 (success) or -1 (failure).
+ * Absolute pathname of device to add to VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_extend(vg_t *vg, const char *device);
 
@@ -393,12 +418,13 @@
  * lvm_vg_close.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
  *
  * \param   device
- *          Name of device to remove from VG.
+ * Name of device to remove from VG.
  *
- * \return  0 (success) or -1 (failure).
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_reduce(vg_t *vg, const char *device);
 
@@ -411,10 +437,13 @@
  * handle with lvm_vg_close.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
  * \param   new_size
- *          New extent size in bytes.
- * \return  0 (success) or -1 (failure).
+ * New extent size in bytes.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
 
@@ -425,8 +454,10 @@
  * using dm_free().
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Copy of the uuid string.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Copy of the uuid string.
  */
 char *lvm_vg_get_uuid(const vg_t *vg);
 
@@ -437,8 +468,10 @@
  * using dm_free().
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Copy of the name.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Copy of the name.
  */
 char *lvm_vg_get_name(const vg_t *vg);
 
@@ -446,8 +479,10 @@
  * Get the current size in bytes of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Size in bytes.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Size in bytes.
  */
 uint64_t lvm_vg_get_size(const vg_t *vg);
 
@@ -455,8 +490,10 @@
  * Get the current unallocated space in bytes of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Free size in bytes.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Free size in bytes.
  */
 uint64_t lvm_vg_get_free_size(const vg_t *vg);
 
@@ -464,8 +501,10 @@
  * Get the current extent size in bytes of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Extent size in bytes.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Extent size in bytes.
  */
 uint64_t lvm_vg_get_extent_size(const vg_t *vg);
 
@@ -473,8 +512,10 @@
  * Get the current number of total extents of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Extent count.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Extent count.
  */
 uint64_t lvm_vg_get_extent_count(const vg_t *vg);
 
@@ -482,8 +523,10 @@
  * Get the current number of free extents of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Free extent count.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Free extent count.
  */
 uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
 
@@ -491,8 +534,10 @@
  * Get the current number of physical volumes of a volume group.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Physical volume count.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Physical volume count.
  */
 uint64_t lvm_vg_get_pv_count(const vg_t *vg);
 
@@ -502,9 +547,11 @@
  * Return a list of LV handles for a given VG handle.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  A list of lv_list_t structures containing lv handles for this vg.
- *          If no LVs exist on the given VG, NULL is returned.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * A list of lv_list_t structures containing lv handles for this vg.
+ * If no LVs exist on the given VG, NULL is returned.
  */
 struct dm_list *lvm_vg_list_lvs(vg_t *vg);
 
@@ -517,12 +564,16 @@
  * lv_create_single is refactored by segtype.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
  * \param   name
- *          Name of logical volume to create.
+ * Name of logical volume to create.
+ *
  * \param   size
- *          Size of logical volume in extents.
- * \return  LV object
+ * Size of logical volume in extents.
+ *
+ * \return
+ * non-NULL handle to an LV object created, or NULL if creation fails.
  *
  */
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
@@ -536,8 +587,10 @@
  * lvconvert.
  *
  * \param   lv
- *          Logical volume handle.
- * \return  0 (success) or -1 (failure).
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_lv_activate(lv_t *lv);
 
@@ -547,8 +600,10 @@
  * This function is the equivalent of the lvm command "lvchange -an".
  *
  * \param   lv
- *          Logical volume handle.
- * \return  0 (success) or -1 (failure).
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_lv_deactivate(lv_t *lv);
 
@@ -563,8 +618,10 @@
  * lvm_vg_write.
  *
  * \param   lv
- *          Logical volume handle.
- * \return  0 (success) or -1 (failure).
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_vg_remove_lv(lv_t *lv);
 
@@ -575,8 +632,10 @@
  * using dm_free().
  *
  * \param   lv
- *          Logical volume handle.
- * \return  Copy of the uuid string.
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the uuid string.
  */
 char *lvm_lv_get_uuid(const lv_t *lv);
 
@@ -587,8 +646,10 @@
  * using dm_free().
  *
  * \param   lv
- *          Logical volume handle.
- * \return  Copy of the name.
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the name.
  */
 char *lvm_lv_get_name(const lv_t *lv);
 
@@ -596,8 +657,10 @@
  * Get the current size in bytes of a logical volume.
  *
  * \param   lv
- *          Logical volume handle.
- * \return  Size in bytes.
+ * Logical volume handle.
+ *
+ * \return
+ * Size in bytes.
  */
 uint64_t lvm_lv_get_size(const lv_t *lv);
 
@@ -605,8 +668,10 @@
  * Get the current activation state of a logical volume.
  *
  * \param   lv
- *          Logical volume handle.
- * \return  1 if the LV is active in the kernel, 0 if not
+ * Logical volume handle.
+ *
+ * \return
+ * 1 if the LV is active in the kernel, 0 if not
  */
 uint64_t lvm_lv_is_active(const lv_t *lv);
 
@@ -614,8 +679,10 @@
  * Get the current suspended state of a logical volume.
  *
  * \param   lv
- *          Logical volume handle.
- * \return  1 if the LV is suspended in the kernel, 0 if not
+ * Logical volume handle.
+ *
+ * \return
+ * 1 if the LV is suspended in the kernel, 0 if not
  */
 uint64_t lvm_lv_is_suspended(const lv_t *lv);
 
@@ -623,10 +690,13 @@
  * Resize logical volume to new_size bytes.
  *
  * \param   lv
- *          Logical volume handle.
+ * Logical volume handle.
+ *
  * \param   new_size
- *          New size in bytes.
- * \return  0 (success) or -1 (failure).
+ * New size in bytes.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
  *
  */
 int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
@@ -643,9 +713,11 @@
  * Return a list of PV handles for a given VG handle.
  *
  * \param   vg
- *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  A list of pv_list_t structures containing pv handles for this vg.
- *          If no PVs exist on the given VG, NULL is returned.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * A list of pv_list_t structures containing pv handles for this vg.
+ * If no PVs exist on the given VG, NULL is returned.
  */
 struct dm_list *lvm_vg_list_pvs(vg_t *vg);
 
@@ -656,8 +728,10 @@
  * using dm_free().
  *
  * \param   pv
- *          Physical volume handle.
- * \return  Copy of the uuid string.
+ * Physical volume handle.
+ *
+ * \return
+ * Copy of the uuid string.
  */
 char *lvm_pv_get_uuid(const pv_t *pv);
 
@@ -668,8 +742,10 @@
  * using dm_free().
  *
  * \param   pv
- *          Physical volume handle.
- * \return  Copy of the name.
+ * Physical volume handle.
+ *
+ * \return
+ * Copy of the name.
  */
 char *lvm_pv_get_name(const pv_t *pv);
 
@@ -677,8 +753,10 @@
  * Get the current number of metadata areas in the physical volume.
  *
  * \param   pv
- *          Physical volume handle.
- * \return  metadata area count.
+ * Physical volume handle.
+ *
+ * \return
+ * Number of metadata areas in the PV.
  */
 uint64_t lvm_pv_get_mda_count(const pv_t *pv);
 
@@ -686,11 +764,13 @@
  * Resize physical volume to new_size bytes.
  *
  * \param   pv
- *          Physical volume handle.
+ * Physical volume handle.
+ *
  * \param   new_size
- *          New size in bytes.
- * \return  0 (success) or -1 (failure).
+ * New size in bytes.
  *
+ * \return
+ * 0 (success) or -1 (failure).
  */
 int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
 


