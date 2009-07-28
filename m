From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 00:36:59 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090728003659.10149.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 00:36:59

Modified files:
	liblvm         : lvm.h 

Log message:
	Update lvm.h to address feeback.
	
	This addresses a a large amount of Alasdair's review.  Subsequent patches
	will address remaining issues.
	Addressed:
	// FIXME Mention that's also required on error.
	// FIXME Be consistent in terminology.  It's called "system_dir" then last sentence says "system directory setting".  Is it referring to "system_dir" there or something else?
	// FIXME Mention it frees all resources and cannot be used subsequently?
	// FIXME What does "any system configuration" mean?
	// FIXME Expand on that explanation a bit, now that we know what the other fns look like.
	// FIXME Not sure about that - it needs to scan sometimes.  "will not" or "might not" ?
	// FIXME: That's a FIXME in the code!!!
	// FIXME What does "copied" mean in this context???
	// FIXME Say what struct the returned struct dm_list is a list of...
	// FIXME "This API" ?  This function creates an object in memory?
	// FIXME This function commits the Volume Group object referenced by the VG handle to disk?
	// FIXME Where is "Name" defined?  Absolute pathname?
	
	Outstanding:
	// FIXME Version function first?  No structs or handles needed for that.
	// FIXME Sort out this alignment.  "Set an" directly below "system_dir" looks awful.  Indent differently?  More blank lines?
	// FIXME Check how doxygen processes this.  E.g. "return: LVM handle.  You must use lvm_error() to check there were no errors and confirm that the handle is valid for passing to other functions."
	// FIXME Find a better name.  lvm_init.
	// FIXME Consider renaming according to the new name for lvm_create.
	// FIXME Please can we use dm_malloc throughout?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/liblvm/lvm.h	2009/07/27 21:13:54	1.33
+++ LVM2/liblvm/lvm.h	2009/07/28 00:36:58	1.34
@@ -31,7 +31,14 @@
 
 /******************************** structures ********************************/
 
-/* Internal object structures - do not use directly */
+/**
+ * Opaque structures - do not use directly.  Internal structures may change
+ * without notice between releases, whereas this API will be changed much less
+ * frequently.  Backwards compatibility will normally be preserved in future
+ * releases.  On any occasion when the developers do decide to break backwards
+ * compatibility in any significant way, the LVM_LIBAPI number (included in
+ * the library's soname) will be incremented.
+ */
 struct lvm;
 struct physical_volume;
 struct volume_group;
@@ -40,23 +47,15 @@
 /**
  * lvm handle.
  *
- * This is the base handle that is needed to open and create objects. Also
- * error handling is bound to this handle.
+ * This is the base handle that is needed to open and create objects such as
+ * volume groups and logical volumes.  In addition, this handle provides a
+ * context for error handling information, saving any error number (see
+ * lvm_errno) and error message (see lvm_errmsg) that any function may
+ * generate.
  */
 typedef struct lvm *lvm_t;
 
 /**
- * Physical volume object.
- *
- * This object can be either a read-only object or a read-write object and
- * depends on the mode of the volume group.  This object can not be
- * written to disk independently, and changes will be written to disk
- * when the volume group gets committed to disk. The open mode is the
- * same as the volume group object it was created from.
- */
-typedef struct physical_volume pv_t;
-
-/**
  * Volume group object.
  *
  * This object can be either a read-only object or a read-write object
@@ -69,51 +68,47 @@
 /**
  * Logical Volume object.
  *
- * This object can be either a read-only object or a read-write object
- * depending on the mode of the volume group. This object can not be
- * written to disk independently, it is bound to a volume group and changes
- * will be written to disk when the volume group gets committed to disk. The
- * open mode is the same as the volume group object is was created from.
+ * This object is bound to a volume group and has the same mode of the volume
+ * group.  Changes will be written to disk when the volume group gets
+ * committed to disk.
  */
 typedef struct logical_volume lv_t;
 
 /**
- * Physical volume object list.
+ * Physical volume object.
  *
- * The properties of physical volume objects also applies to the list of
- * physical volumes.
+ * This object is bound to a volume group and has the same mode of the volume
+ * group.  Changes will be written to disk when the volume group gets
+ * committed to disk.
  */
-typedef struct lvm_pv_list {
-	struct dm_list list;
-	pv_t *pv;
-} pv_list_t;
+typedef struct physical_volume pv_t;
 
 /**
- * Volume group object list.
+ * Logical Volume object list.
  *
- * The properties of volume group objects also applies to the list of
- * volume groups.
+ * Lists of these structures are returned by lvm_vg_list_pvs.
  */
-typedef struct lvm_vg_list {
+typedef struct lvm_lv_list {
 	struct dm_list list;
-	vg_t *vg;
-} vg_list_t;
+	lv_t *lv;
+} lv_list_t;
 
 /**
- * Logical Volume object list.
+ * Physical volume object list.
  *
- * The properties of logical volume objects also applies to the list of
- * logical volumes.
+ * Lists of these structures are returned by lvm_vg_list_pvs.
  */
-typedef struct lvm_lv_list {
+typedef struct lvm_pv_list {
 	struct dm_list list;
-	lv_t *lv;
-} lv_list_t;
+	pv_t *pv;
+} pv_list_t;
 
 /**
  * String list.
  *
  * This string list contains read-only strings.
+ * Lists of these structures are returned by lvm_list_vg_names and
+ * lvm_list_vg_uuids.
  */
 struct lvm_str_list {
 	struct dm_list list;
@@ -121,7 +116,6 @@
 };
 
 /*************************** generic lvm handling ***************************/
-
 /**
  * Create a LVM handle.
  *
@@ -131,16 +125,24 @@
  * \param   system_dir
  *          Set an alternative LVM system directory. Use NULL to use the
  *          default value. If the environment variable LVM_SYSTEM_DIR is set,
- *          it will override any LVM system directory setting.
+ *          it will override any system_dir setting.
  * \return  A valid LVM handle is returned or NULL if there has been a
  *          memory allocation problem. You have to check if an error occured
  *          with the lvm_error function.
  */
+// FIXME: Sort out this alignment.  "Set an" directly below "system_dir"
+// looks awful.  Indent differently?  More blank lines?
 lvm_t lvm_create(const char *system_dir);
+// FIXME Find a better name.  lvm_init.
 
 /**
  * Destroy a LVM handle allocated with lvm_create.
  *
+ * This function should be used after all LVM operations are complete or after
+ * an unrecoverable error.  Destroying the LVM handle frees the memory and
+ * other resources associated with the handle.  Once destroyed, the handle
+ * cannot be used subsequently.
+ *
  * \param   libh
  *          Handle obtained from lvm_create.
  */
@@ -149,8 +151,9 @@
 /**
  * Reload the original configuration from the system directory.
  *
- * This function should be used when any system configuration changes,
- * and the change is needed by the application.
+ * This function should be used when any LVM configuration changes in the LVM
+ * system_dir or by another lvm_config* function, and the change is needed by
+ * the application.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
@@ -161,13 +164,14 @@
 /**
  * Override the LVM configuration with a configuration string.
  *
- * This API is equivalent to the --config option on lvm commands.
+ * This function is equivalent to the --config option on lvm commands.
  * FIXME: submit a patch to document the --config option
  * Once this API has been used to over-ride the configuration,
  * you should use lvm_config_reload to apply the new settings.
+ *
  * \param   libh
  *          Handle obtained from lvm_create.
- * \param   config_settings
+ * \param   config_string
  *          LVM configuration string to apply.  See the lvm.conf file man page
  *          for the format of the config string.
  * \return  0 (success) or -1 (failure).
@@ -177,9 +181,13 @@
 /**
  * Return stored error no describing last LVM API error.
  *
- * Users of liblvm should use lvm_errno to determine success or failure
- * of the last call, unless the API indicates another method of determining
- * success or failure.
+ * Users of liblvm should use lvm_errno to determine the details of a any
+ * failure of the last call.  A basic success or fail is always returned by
+ * every function, either by returning a 0 or -1, or a non-NULL / NULL.
+ * If a function has failed, lvm_errno may be used to get a more specific
+ * error code describing the failure.  In this way, lvm_errno may be used
+ * after every function call, even after a 'get' function call that simply
+ * returns a value.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
@@ -191,6 +199,9 @@
 /**
  * Return stored error message describing last LVM error.
  *
+ * This function may be used in conjunction with lvm_errno to obtain more
+ * specific error information for a function that is known to have failed.
+ *
  * \param   libh
  *          Handle obtained from lvm_create.
  *
@@ -214,8 +225,8 @@
  * The memory allocated for the list is tied to the lvm_t handle and will be
  * released when lvm_destroy is called.
  *
- * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
- * To scan the system, use lvm_scan.
+ * NOTE: This function normally does not scan devices in the system for LVM
+ * metadata.  To scan the system, use lvm_scan.
  * NOTE: This function currently returns hidden VG names.  These names always
  * begin with a "#" and should be filtered out and not used.
  *
@@ -233,7 +244,8 @@
  *      }
  *
  *
- * \return  A list of struct lvm_str_list
+ * \return  A list with entries of type struct lvm_str_list, containing the
+ *          VG name strings of the Volume Groups known to the system.
  *          NULL is returned if unable to allocate memory.
  *          An empty list (verify with dm_list_empty) is returned if no VGs
  *          exist on the system.
@@ -246,15 +258,16 @@
  * The memory allocated for the list is tied to the lvm_t handle and will be
  * released when lvm_destroy is called.
  *
- * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
- * To scan the system, use lvm_scan.
+ * NOTE: This function normally does not scan devices in the system for LVM
+ * metadata.  To scan the system, use lvm_scan.
  * NOTE: This function currently returns hidden VG names.  These names always
  * begin with a "#" and should be filtered out and not used.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
  *
- * \return  List of copied uuid strings.
+ * \return  A list with entries of type struct lvm_str_list, containing the
+ *          VG UUID strings of the Volume Groups known to the system.
  *          NULL is returned if unable to allocate memory.
  *          An empty list (verify with dm_list_empty) is returned if no VGs
  *          exist on the system.
@@ -283,7 +296,7 @@
 /**
  * Create a VG with default parameters.
  *
- * This API requires calling lvm_vg_write to commit the change to disk.
+ * This function creates a Volume Group object in memory.
  * Upon success, other APIs may be used to set non-default parameters.
  * For example, to set a non-default extent size, use lvm_vg_set_extent_size.
  * Next, to add physical storage devices to the volume group, use
@@ -303,9 +316,9 @@
  /**
  * Write a VG to disk.
  *
- * This API commits the VG to disk.
- * Upon failure, retry the operation and/or release the VG handle with
- * lvm_vg_close.
+ * This function commits the Volume Group object referenced by the VG handle
+ * to disk. Upon failure, retry the operation and/or release the VG handle
+ * with lvm_vg_close.
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
@@ -316,7 +329,7 @@
 /**
  * Remove a VG from the system.
  *
- * This API commits the change to disk and does not require calling
+ * This function commits the change to disk and does not require calling
  * lvm_vg_write.
  *
  * \param   vg
@@ -328,7 +341,8 @@
 /**
  * Close a VG opened with lvm_vg_create or lvm_vg_open.
  *
- * This API releases a VG handle and any resources associated with the handle.
+ * This function releases a VG handle and any resources associated with the
+ * handle.
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
@@ -339,7 +353,7 @@
 /**
  * Extend a VG by adding a device.
  *
- * This API requires calling lvm_vg_write to commit the change to disk.
+ * This function requires calling lvm_vg_write to commit the change to disk.
  * After successfully adding a device, use lvm_vg_write to commit the new VG
  * to disk.  Upon failure, retry the operation or release the VG handle with
  * lvm_vg_close.
@@ -351,7 +365,7 @@
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   device
- *          Name of device to add to VG.
+ *          Absolute pathname of device to add to VG.
  * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_extend(vg_t *vg, const char *device);
@@ -359,7 +373,7 @@
 /**
  * Reduce a VG by removing an unused device.
  *
- * This API requires calling lvm_vg_write to commit the change to disk.
+ * This function requires calling lvm_vg_write to commit the change to disk.
  * After successfully removing a device, use lvm_vg_write to commit the new VG
  * to disk.  Upon failure, retry the operation or release the VG handle with
  * lvm_vg_close.
@@ -377,7 +391,7 @@
 /**
  * Set the extent size of a VG.
  *
- * This API requires calling lvm_vg_write to commit the change to disk.
+ * This function requires calling lvm_vg_write to commit the change to disk.
  * After successfully setting a new extent size, use lvm_vg_write to commit
  * the new VG to disk.  Upon failure, retry the operation or release the VG
  * handle with lvm_vg_close.
@@ -482,9 +496,9 @@
 
 /**
  * Create a linear logical volume.
- * This API commits the change to disk and does _not_ require calling
+ * This function commits the change to disk and does _not_ require calling
  * lvm_vg_write.
- * FIXME: This API should probably not commit to disk but require calling
+ * FIXME: This function should probably not commit to disk but require calling
  * lvm_vg_write.  However, this appears to be non-trivial change until
  * lv_create_single is refactored by segtype.
  *
@@ -502,9 +516,9 @@
 /**
  * Activate a logical volume.
  *
- * This API is the equivalent of the lvm command "lvchange -ay".
+ * This function is the equivalent of the lvm command "lvchange -ay".
  *
- * NOTE: This API cannot currently handle LVs with an in-progress pvmove or
+ * NOTE: This function cannot currently handle LVs with an in-progress pvmove or
  * lvconvert.
  *
  * \param   lv
@@ -516,7 +530,7 @@
 /**
  * Deactivate a logical volume.
  *
- * This API is the equivalent of the lvm command "lvchange -an".
+ * This function is the equivalent of the lvm command "lvchange -an".
  *
  * \param   lv
  *          Logical volume handle.
@@ -531,7 +545,7 @@
  * lvm_vg_write.
  * Currently only removing linear LVs are possible.
  *
- * FIXME: This API should probably not commit to disk but require calling
+ * FIXME: This function should probably not commit to disk but require calling
  * lvm_vg_write.
  *
  * \param   lv


