From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 23 Feb 2010 14:30:23 -0500
Subject: [PATCH 1/4] Update doxygen comments for lvm2app.h.
In-Reply-To: <1266953426-20955-1-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-9-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1266953426-20955-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix add/remove tag function headers.
Fix a lot of little problems with doxygen comments.
Clarify the basic objects and their handles, and place functions with their
appropriate handles/objects.
All this cleanup moves automatic documentation of lvm2app much closer to being
useful as official documentation.  In the future I will add some examples
and plan to build the examples as part of the unit tests.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |  363 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 255 insertions(+), 108 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index e052301..61ffd87 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -33,7 +33,7 @@
  * \mainpage LVM library API
  *
  * The API is designed around the following basic LVM objects:
- * 1) Physical Volume (PV) 2) Volume Group (VG) 3) Logical Volume (LV).
+ * 1) Physical Volume (pv_t) 2) Volume Group (vg_t) 3) Logical Volume (lv_t).
  *
  * The library provides functions to list the objects in a system,
  * get and set object properties (such as names, UUIDs, and sizes), as well
@@ -44,8 +44,8 @@
  * A central object in the library is the Volume Group, represented by the
  * VG handle, vg_t. Performing an operation on a PV or LV object first
  * requires obtaining a VG handle. Once the vg_t has been obtained, it can
- * be used to enumerate the pv_t's and lv_t's within that vg_t. Attributes
- * of these objects can then be queried.
+ * be used to enumerate the pv_t and lv_t objects within that vg_t. Attributes
+ * of these objects can then be queried or changed.
  *
  * A volume group handle may be obtained with read or write permission.
  * Any attempt to change a property of a pv_t, vg_t, or lv_t without
@@ -94,7 +94,7 @@ struct volume_group;
 struct logical_volume;
 
 /**
- * lvm handle.
+ * \class lvm_t
  *
  * This is the base handle that is needed to open and create objects such as
  * volume groups and logical volumes.  In addition, this handle provides a
@@ -105,37 +105,38 @@ struct logical_volume;
 typedef struct lvm *lvm_t;
 
 /**
- * Volume group object.
+ * \class vg_t
  *
- * This object can be either a read-only object or a read-write object
- * depending on the mode it was returned by a function. Create functions
- * return a read-write object, but open functions have the argument mode to
- * define if the object can be modified or not.
+ * The volume group object is a central object in the library, and can be
+ * either a read-only object or a read-write object depending on the function
+ * used to obtain the object handle. For example, lvm_vg_create() always
+ * returns a read/write handle, while lvm_vg_open() has a "mode" argument
+ * to define the read/write mode of the handle.
  */
 typedef struct volume_group *vg_t;
 
 /**
- * Logical Volume object.
+ * \class lv_t
  *
- * This object is bound to a volume group and has the same mode of the volume
- * group.  Changes will be written to disk when the volume group gets
- * committed to disk.
+ * This logical volume object is bound to a vg_t and has the same
+ * read/write mode as the vg_t.  Changes will be written to disk
+ * when the vg_t gets committed to disk by calling lvm_vg_write().
  */
 typedef struct logical_volume *lv_t;
 
 /**
- * Physical volume object.
+ * \class pv_t
  *
- * This object is bound to a volume group and has the same mode of the volume
- * group.  Changes will be written to disk when the volume group gets
- * committed to disk.
+ * This physical volume object is bound to a vg_t and has the same
+ * read/write mode as the vg_t.  Changes will be written to disk
+ * when the vg_t gets committed to disk by calling lvm_vg_write().
  */
 typedef struct physical_volume *pv_t;
 
 /**
  * Logical Volume object list.
  *
- * Lists of these structures are returned by lvm_vg_list_pvs.
+ * Lists of these structures are returned by lvm_vg_list_pvs().
  */
 typedef struct lvm_lv_list {
 	struct dm_list list;
@@ -145,7 +146,7 @@ typedef struct lvm_lv_list {
 /**
  * Physical volume object list.
  *
- * Lists of these structures are returned by lvm_vg_list_pvs.
+ * Lists of these structures are returned by lvm_vg_list_pvs().
  */
 typedef struct lvm_pv_list {
 	struct dm_list list;
@@ -156,8 +157,8 @@ typedef struct lvm_pv_list {
  * String list.
  *
  * This string list contains read-only strings.
- * Lists of these structures are returned by lvm_list_vg_names and
- * lvm_list_vg_uuids.
+ * Lists of these structures are returned by functions such as
+ * lvm_list_vg_names() and lvm_list_vg_uuids().
  */
 typedef struct lvm_str_list {
 	struct dm_list list;
@@ -168,6 +169,8 @@ typedef struct lvm_str_list {
 /**
  * Create a LVM handle.
  *
+ * \memberof lvm_t
+ *
  * Once all LVM operations have been completed, use lvm_quit to release
  * the handle and any associated resources.
  *
@@ -184,7 +187,9 @@ typedef struct lvm_str_list {
 lvm_t lvm_init(const char *system_dir);
 
 /**
- * Destroy a LVM handle allocated with lvm_init.
+ * Destroy a LVM handle allocated with lvm_init().
+ *
+ * \memberof lvm_t
  *
  * This function should be used after all LVM operations are complete or after
  * an unrecoverable error.  Destroying the LVM handle frees the memory and
@@ -192,19 +197,21 @@ lvm_t lvm_init(const char *system_dir);
  * cannot be used subsequently.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  */
 void lvm_quit(lvm_t libh);
 
 /**
  * Reload the original configuration from the system directory.
  *
+ * \memberof lvm_t
+ *
  * This function should be used when any LVM configuration changes in the LVM
  * system_dir or by another lvm_config* function, and the change is needed by
  * the application.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -214,12 +221,14 @@ int lvm_config_reload(lvm_t libh);
 /**
  * Override the LVM configuration with a configuration string.
  *
+ * \memberof lvm_t
+ *
  * This function is equivalent to the --config option on lvm commands.
  * Once this API has been used to over-ride the configuration,
- * use lvm_config_reload to apply the new settings.
+ * use lvm_config_reload() to apply the new settings.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \param   config_string
  * LVM configuration string to apply.  See the lvm.conf file man page
@@ -233,6 +242,8 @@ int lvm_config_override(lvm_t libh, const char *config_string);
 /**
  * Return stored error no describing last LVM API error.
  *
+ * \memberof lvm_t
+ *
  * Users of liblvm should use lvm_errno to determine the details of a any
  * failure of the last call.  A basic success or fail is always returned by
  * every function, either by returning a 0 or -1, or a non-NULL / NULL.
@@ -242,7 +253,7 @@ int lvm_config_override(lvm_t libh, const char *config_string);
  * returns a value.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \return
  * An errno value describing the last LVM error.
@@ -252,11 +263,13 @@ int lvm_errno(lvm_t libh);
 /**
  * Return stored error message describing last LVM error.
  *
+ * \memberof lvm_t
+ *
  * This function may be used in conjunction with lvm_errno to obtain more
  * specific error information for a function that is known to have failed.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \return
  * An error string describing the last LVM error.
@@ -266,16 +279,18 @@ const char *lvm_errmsg(lvm_t libh);
 /**
  * Scan all devices on the system for VGs and LVM metadata.
  *
+ * \memberof lvm_t
+ *
  * \return
  * 0 (success) or -1 (failure).
  */
 int lvm_scan(lvm_t libh);
 
-/*************************** volume group handling **************************/
-
 /**
  * Return the list of volume group names.
  *
+ * \memberof lvm_t
+ *
  * The memory allocated for the list is tied to the lvm_t handle and will be
  * released when lvm_quit is called.
  *
@@ -308,6 +323,8 @@ struct dm_list *lvm_list_vg_names(lvm_t libh);
 /**
  * Return the list of volume group uuids.
  *
+ * \memberof lvm_t
+ *
  * The memory allocated for the list is tied to the lvm_t handle and will be
  * released when lvm_quit is called.
  *
@@ -315,7 +332,7 @@ struct dm_list *lvm_list_vg_names(lvm_t libh);
  * metadata.  To scan the system, use lvm_scan.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \return
  * A list with entries of type struct lvm_str_list, containing the
@@ -331,8 +348,10 @@ struct dm_list *lvm_list_vg_uuids(lvm_t libh);
  *
  * Open a VG for reading or writing.
  *
+ * \memberof lvm_t
+ *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \param   vgname
  * Name of the VG to open.
@@ -352,17 +371,19 @@ vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 /**
  * Create a VG with default parameters.
  *
+ * \memberof lvm_t
+ *
  * This function creates a Volume Group object in memory.
  * Upon success, other APIs may be used to set non-default parameters.
- * For example, to set a non-default extent size, use lvm_vg_set_extent_size.
+ * For example, to set a non-default extent size, use lvm_vg_set_extent_size().
  * Next, to add physical storage devices to the volume group, use
- * lvm_vg_extend for each device.
+ * lvm_vg_extend() for each device.
  * Once all parameters are set appropriately and all devices are added to the
- * VG, use lvm_vg_write to commit the new VG to disk, and lvm_vg_close to
+ * VG, use lvm_vg_write() to commit the new VG to disk, and lvm_vg_close() to
  * release the VG handle.
  *
  * \param   libh
- * Handle obtained from lvm_init.
+ * Handle obtained from lvm_init().
  *
  * \param   vg_name
  * Name of the VG to open.
@@ -372,15 +393,47 @@ vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
  */
 vg_t lvm_vg_create(lvm_t libh, const char *vg_name);
 
- /**
+/*************************** volume group handling **************************/
+
+/**
+ * Return a list of LV handles for a given VG handle.
+ *
+ * \memberof vg_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ *
+ * \return
+ * A list of lvm_lv_list structures containing lv handles for this vg.
+ * If no LVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_lvs(vg_t vg);
+
+/**
+ * Return a list of PV handles for a given VG handle.
+ *
+ * \memberof vg_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ *
+ * \return
+ * A list of lvm_pv_list structures containing pv handles for this vg.
+ * If no PVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_pvs(vg_t vg);
+
+/**
  * Write a VG to disk.
  *
+ * \memberof vg_t
+ *
  * This function commits the Volume Group object referenced by the VG handle
  * to disk. Upon failure, retry the operation and/or release the VG handle
- * with lvm_vg_close.
+ * with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -390,11 +443,13 @@ int lvm_vg_write(vg_t vg);
 /**
  * Remove a VG from the system.
  *
+ * \memberof vg_t
+ *
  * This function removes a Volume Group object in memory, and requires
- * calling lvm_vg_write to commit the removal to disk.
+ * calling lvm_vg_write() to commit the removal to disk.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -402,13 +457,15 @@ int lvm_vg_write(vg_t vg);
 int lvm_vg_remove(vg_t vg);
 
 /**
- * Close a VG opened with lvm_vg_create or lvm_vg_open.
+ * Close a VG opened with lvm_vg_create or lvm_vg_open().
+ *
+ * \memberof vg_t
  *
  * This function releases a VG handle and any resources associated with the
  * handle.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -418,17 +475,19 @@ int lvm_vg_close(vg_t vg);
 /**
  * Extend a VG by adding a device.
  *
- * This function requires calling lvm_vg_write to commit the change to disk.
- * After successfully adding a device, use lvm_vg_write to commit the new VG
+ * \memberof vg_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully adding a device, use lvm_vg_write() to commit the new VG
  * to disk.  Upon failure, retry the operation or release the VG handle with
- * lvm_vg_close.
+ * lvm_vg_close().
  * If the device is not initialized for LVM use, it will be initialized
  * before adding to the VG.  Although some internal checks are done,
  * the caller should be sure the device is not in use by other subsystems
  * before calling lvm_vg_extend.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \param   device
  * Absolute pathname of device to add to VG.
@@ -441,13 +500,15 @@ int lvm_vg_extend(vg_t vg, const char *device);
 /**
  * Reduce a VG by removing an unused device.
  *
- * This function requires calling lvm_vg_write to commit the change to disk.
- * After successfully removing a device, use lvm_vg_write to commit the new VG
+ * \memberof vg_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully removing a device, use lvm_vg_write() to commit the new VG
  * to disk.  Upon failure, retry the operation or release the VG handle with
- * lvm_vg_close.
+ * lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \param   device
  * Name of device to remove from VG.
@@ -458,35 +519,59 @@ int lvm_vg_extend(vg_t vg, const char *device);
 int lvm_vg_reduce(vg_t vg, const char *device);
 
 /**
- * Add/remove a tag to/from a VG.
+ * Add a tag to a VG.
+ *
+ * \memberof vg_t
  *
- * These functions require calling lvm_vg_write to commit the change to disk.
- * After successfully adding/removing a tag, use lvm_vg_write to commit the
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully adding a tag, use lvm_vg_write() to commit the
  * new VG to disk.  Upon failure, retry the operation or release the VG handle
- * with lvm_vg_close.
+ * with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \param   tag
- * Tag to add/remove to/from VG.
+ * Tag to add to the VG.
  *
  * \return
  * 0 (success) or -1 (failure).
  */
 int lvm_vg_add_tag(vg_t vg, const char *tag);
+
+/**
+ * Remove a tag from a VG.
+ *
+ * \memberof vg_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully removing a tag, use lvm_vg_write() to commit the
+ * new VG to disk.  Upon failure, retry the operation or release the VG handle
+ * with lvm_vg_close().
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ *
+ * \param   tag
+ * Tag to remove from VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
 int lvm_vg_remove_tag(vg_t vg, const char *tag);
 
 /**
  * Set the extent size of a VG.
  *
- * This function requires calling lvm_vg_write to commit the change to disk.
- * After successfully setting a new extent size, use lvm_vg_write to commit
+ * \memberof vg_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully setting a new extent size, use lvm_vg_write() to commit
  * the new VG to disk.  Upon failure, retry the operation or release the VG
- * handle with lvm_vg_close.
+ * handle with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \param   new_size
  * New extent size in bytes.
@@ -499,8 +584,10 @@ int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size);
 /**
  * Get whether or not a volume group is clustered.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 1 if the VG is clustered, 0 if not
@@ -510,8 +597,10 @@ uint64_t lvm_vg_is_clustered(vg_t vg);
 /**
  * Get whether or not a volume group is exported.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 1 if the VG is exported, 0 if not
@@ -521,12 +610,14 @@ uint64_t lvm_vg_is_exported(vg_t vg);
 /**
  * Get whether or not a volume group is a partial volume group.
  *
+ * \memberof vg_t
+ *
  * When one or more physical volumes belonging to the volume group
  * are missing from the system the volume group is a partial volume
  * group.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * 1 if the VG is PVs, 0 if not
@@ -536,12 +627,14 @@ uint64_t lvm_vg_is_partial(vg_t vg);
 /**
  * Get the current metadata sequence number of a volume group.
  *
+ * \memberof vg_t
+ *
  * The metadata sequence number is incrented for each metadata change.
  * Applications may use the sequence number to determine if any LVM objects
  * have changed from a prior query.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Metadata sequence number.
@@ -551,11 +644,13 @@ uint64_t lvm_vg_get_seqno(const vg_t vg);
 /**
  * Get the current name of a volume group.
  *
+ * \memberof vg_t
+ *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Copy of the uuid string.
@@ -565,11 +660,13 @@ char *lvm_vg_get_uuid(const vg_t vg);
 /**
  * Get the current uuid of a volume group.
  *
+ * \memberof vg_t
+ *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Copy of the name.
@@ -579,8 +676,10 @@ char *lvm_vg_get_name(const vg_t vg);
 /**
  * Get the current size in bytes of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Size in bytes.
@@ -590,8 +689,10 @@ uint64_t lvm_vg_get_size(const vg_t vg);
 /**
  * Get the current unallocated space in bytes of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Free size in bytes.
@@ -601,8 +702,10 @@ uint64_t lvm_vg_get_free_size(const vg_t vg);
 /**
  * Get the current extent size in bytes of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Extent size in bytes.
@@ -612,8 +715,10 @@ uint64_t lvm_vg_get_extent_size(const vg_t vg);
 /**
  * Get the current number of total extents of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Extent count.
@@ -623,8 +728,10 @@ uint64_t lvm_vg_get_extent_count(const vg_t vg);
 /**
  * Get the current number of free extents of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Free extent count.
@@ -634,8 +741,10 @@ uint64_t lvm_vg_get_free_extent_count(const vg_t vg);
 /**
  * Get the current number of physical volumes of a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Physical volume count.
@@ -645,8 +754,10 @@ uint64_t lvm_vg_get_pv_count(const vg_t vg);
 /**
  * Get the maximum number of physical volumes allowed in a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Maximum number of physical volumes allowed in a volume group.
@@ -656,8 +767,10 @@ uint64_t lvm_vg_get_max_pv(const vg_t vg);
 /**
  * Get the maximum number of logical volumes allowed in a volume group.
  *
+ * \memberof vg_t
+ *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \return
  * Maximum number of logical volumes allowed in a volume group.
@@ -667,6 +780,8 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
 /**
  * Return the list of volume group tags.
  *
+ * \memberof vg_t
+ *
  * The memory allocated for the list is tied to the vg_t handle and will be
  * released when lvm_vg_close is called.
  *
@@ -694,26 +809,14 @@ struct dm_list *lvm_vg_get_tags(const vg_t vg);
 /************************** logical volume handling *************************/
 
 /**
- * Return a list of LV handles for a given VG handle.
- *
- * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
- *
- * \return
- * A list of lv_list_t structures containing lv handles for this vg.
- * If no LVs exist on the given VG, NULL is returned.
- */
-struct dm_list *lvm_vg_list_lvs(vg_t vg);
-
-/**
  * Create a linear logical volume.
  * This function commits the change to disk and does _not_ require calling
- * lvm_vg_write.
+ * lvm_vg_write().
  * NOTE: The commit behavior of this function is subject to change
  * as the API is developed.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ * VG handle obtained from lvm_vg_create or lvm_vg_open().
  *
  * \param   name
  * Name of logical volume to create.
@@ -730,6 +833,8 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 /**
  * Activate a logical volume.
  *
+ * \memberof lv_t
+ *
  * This function is the equivalent of the lvm command "lvchange -ay".
  *
  * NOTE: This function cannot currently handle LVs with an in-progress pvmove or
@@ -746,6 +851,8 @@ int lvm_lv_activate(lv_t lv);
 /**
  * Deactivate a logical volume.
  *
+ * \memberof lv_t
+ *
  * This function is the equivalent of the lvm command "lvchange -an".
  *
  * \param   lv
@@ -759,8 +866,10 @@ int lvm_lv_deactivate(lv_t lv);
 /**
  * Remove a logical volume from a volume group.
  *
+ * \memberof lv_t
+ *
  * This function commits the change to disk and does _not_ require calling
- * lvm_vg_write.
+ * lvm_vg_write().
  * NOTE: The commit behavior of this function is subject to change
  * as the API is developed.
  * Currently only removing linear LVs are possible.
@@ -776,6 +885,8 @@ int lvm_vg_remove_lv(lv_t lv);
 /**
  * Get the current name of a logical volume.
  *
+ * \memberof lv_t
+ *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
  *
@@ -790,6 +901,8 @@ char *lvm_lv_get_uuid(const lv_t lv);
 /**
  * Get the current uuid of a logical volume.
  *
+ * \memberof lv_t
+ *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
  *
@@ -804,6 +917,8 @@ char *lvm_lv_get_name(const lv_t lv);
 /**
  * Get the current size in bytes of a logical volume.
  *
+ * \memberof lv_t
+ *
  * \param   lv
  * Logical volume handle.
  *
@@ -815,6 +930,8 @@ uint64_t lvm_lv_get_size(const lv_t lv);
 /**
  * Get the current activation state of a logical volume.
  *
+ * \memberof lv_t
+ *
  * \param   lv
  * Logical volume handle.
  *
@@ -826,6 +943,8 @@ uint64_t lvm_lv_is_active(const lv_t lv);
 /**
  * Get the current suspended state of a logical volume.
  *
+ * \memberof lv_t
+ *
  * \param   lv
  * Logical volume handle.
  *
@@ -835,28 +954,52 @@ uint64_t lvm_lv_is_active(const lv_t lv);
 uint64_t lvm_lv_is_suspended(const lv_t lv);
 
 /**
- * Add/remove a tag to/from a LV.
+ * Add a tag to an LV.
  *
- * These functions require calling lvm_vg_write to commit the change to disk.
- * After successfully adding/removing a tag, use lvm_vg_write to commit the
+ * \memberof lv_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully adding a tag, use lvm_vg_write() to commit the
  * new VG to disk.  Upon failure, retry the operation or release the VG handle
- * with lvm_vg_close.
+ * with lvm_vg_close().
  *
  * \param   lv
  * Logical volume handle.
  *
  * \param   tag
- * Tag to add/remove to/from LV.
+ * Tag to add to an LV.
  *
  * \return
  * 0 (success) or -1 (failure).
  */
 int lvm_lv_add_tag(lv_t lv, const char *tag);
+
+/**
+ * Remove a tag from an LV.
+ *
+ * \memberof lv_t
+ *
+ * This function requires calling lvm_vg_write() to commit the change to disk.
+ * After successfully removing a tag, use lvm_vg_write() to commit the
+ * new VG to disk.  Upon failure, retry the operation or release the VG handle
+ * with lvm_vg_close().
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   tag
+ * Tag to remove from LV.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
 int lvm_lv_remove_tag(lv_t lv, const char *tag);
 
 /**
  * Return the list of logical volume tags.
  *
+ * \memberof lv_t
+ *
  * The memory allocated for the list is tied to the vg_t handle and will be
  * released when lvm_vg_close is called.
  *
@@ -885,6 +1028,8 @@ struct dm_list *lvm_lv_get_tags(const lv_t lv);
 /**
  * Resize logical volume to new_size bytes.
  *
+ * \memberof lv_t
+ *
  * NOTE: This function is currently not implemented.
  *
  * \param   lv
@@ -908,19 +1053,9 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
  */
 
 /**
- * Return a list of PV handles for a given VG handle.
+ * Get the current uuid of a physical volume.
  *
- * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open.
- *
- * \return
- * A list of pv_list_t structures containing pv handles for this vg.
- * If no PVs exist on the given VG, NULL is returned.
- */
-struct dm_list *lvm_vg_list_pvs(vg_t vg);
-
-/**
- * Get the current uuid of a logical volume.
+ * \memberof pv_t
  *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
@@ -934,7 +1069,9 @@ struct dm_list *lvm_vg_list_pvs(vg_t vg);
 char *lvm_pv_get_uuid(const pv_t pv);
 
 /**
- * Get the current name of a logical volume.
+ * Get the current name of a physical volume.
+ *
+ * \memberof pv_t
  *
  * Memory is allocated using dm_malloc() and caller must free the memory
  * using dm_free().
@@ -950,6 +1087,8 @@ char *lvm_pv_get_name(const pv_t pv);
 /**
  * Get the current number of metadata areas in the physical volume.
  *
+ * \memberof pv_t
+ *
  * \param   pv
  * Physical volume handle.
  *
@@ -962,6 +1101,8 @@ uint64_t lvm_pv_get_mda_count(const pv_t pv);
  * Get the current size in bytes of a device underlying a
  * physical volume.
  *
+ * \memberof pv_t
+ *
  * \param   pv
  * Physical volume handle.
  *
@@ -973,6 +1114,8 @@ uint64_t lvm_pv_get_dev_size(const pv_t pv);
 /**
  * Get the current size in bytes of a physical volume.
  *
+ * \memberof pv_t
+ *
  * \param   pv
  * Physical volume handle.
  *
@@ -984,6 +1127,8 @@ uint64_t lvm_pv_get_size(const pv_t pv);
 /**
  * Get the current unallocated space in bytes of a physical volume.
  *
+ * \memberof pv_t
+ *
  * \param   pv
  * Physical volume handle.
  *
@@ -995,6 +1140,8 @@ uint64_t lvm_pv_get_free(const pv_t pv);
 /**
  * Resize physical volume to new_size bytes.
  *
+ * \memberof pv_t
+ *
  * NOTE: This function is currently not implemented.
  *
  * \param   pv
-- 
1.6.0.6


