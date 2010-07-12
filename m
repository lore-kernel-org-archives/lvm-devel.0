From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jul 2010 18:29:32 -0000
Subject: LVM2/liblvm lvm2app.h
Message-ID: <20100712182932.25391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-12 18:29:31

Modified files:
	liblvm         : lvm2app.h 

Log message:
	More comment updates in lvm2app.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/liblvm/lvm2app.h	2010/07/12 18:12:23	1.18
+++ LVM2/liblvm/lvm2app.h	2010/07/12 18:29:31	1.19
@@ -102,7 +102,7 @@
  * This is the base handle that is needed to open and create objects such as
  * volume groups and logical volumes.  In addition, this handle provides a
  * context for error handling information, saving any error number (see
- * lvm_errno) and error message (see lvm_errmsg) that any function may
+ * lvm_errno()) and error message (see lvm_errmsg()) that any function may
  * generate.
  */
 typedef struct lvm *lvm_t;
@@ -174,7 +174,7 @@
  *
  * \memberof lvm_t
  *
- * Once all LVM operations have been completed, use lvm_quit to release
+ * Once all LVM operations have been completed, use lvm_quit() to release
  * the handle and any associated resources.
  *
  * \param system_dir
@@ -185,7 +185,7 @@
  * \return
  * A valid LVM handle is returned or NULL if there has been a
  * memory allocation problem. You have to check if an error occured
- * with the lvm_error function.
+ * with the lvm_error() function.
  */
 lvm_t lvm_init(const char *system_dir);
 
@@ -268,7 +268,7 @@
  *
  * \memberof lvm_t
  *
- * This function may be used in conjunction with lvm_errno to obtain more
+ * This function may be used in conjunction with lvm_errno() to obtain more
  * specific error information for a function that is known to have failed.
  *
  * \param   libh
@@ -295,10 +295,10 @@
  * \memberof lvm_t
  *
  * The memory allocated for the list is tied to the lvm_t handle and will be
- * released when lvm_quit is called.
+ * released when lvm_quit() is called.
  *
  * NOTE: This function normally does not scan devices in the system for LVM
- * metadata.  To scan the system, use lvm_scan.
+ * metadata.  To scan the system, use lvm_scan().
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t vg;
@@ -329,10 +329,10 @@
  * \memberof lvm_t
  *
  * The memory allocated for the list is tied to the lvm_t handle and will be
- * released when lvm_quit is called.
+ * released when lvm_quit() is called.
  *
  * NOTE: This function normally does not scan devices in the system for LVM
- * metadata.  To scan the system, use lvm_scan.
+ * metadata.  To scan the system, use lvm_scan().
  *
  * \param   libh
  * Handle obtained from lvm_init().
@@ -352,7 +352,7 @@
  * \memberof lvm_t
  *
  * The memory allocated for the name is tied to the lvm_t handle and will be
- * released when lvm_quit is called.
+ * released when lvm_quit() is called.
  *
  * NOTE: This function may scan devices in the system for LVM metadata.
  *
@@ -371,7 +371,7 @@
  * \memberof lvm_t
  *
  * The memory allocated for the name is tied to the lvm_t handle and will be
- * released when lvm_quit is called.
+ * released when lvm_quit() is called.
  *
  * NOTE: This function may scan devices in the system for LVM metadata.
  *
@@ -443,7 +443,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * A list of lvm_lv_list structures containing lv handles for this vg.
@@ -457,7 +457,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * A list of lvm_pv_list structures containing pv handles for this vg.
@@ -475,7 +475,7 @@
  * with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -491,7 +491,7 @@
  * calling lvm_vg_write() to commit the removal to disk.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -507,7 +507,7 @@
  * handle.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 0 (success) or -1 (failure).
@@ -526,10 +526,10 @@
  * If the device is not initialized for LVM use, it will be initialized
  * before adding to the VG.  Although some internal checks are done,
  * the caller should be sure the device is not in use by other subsystems
- * before calling lvm_vg_extend.
+ * before calling lvm_vg_extend().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   device
  * Absolute pathname of device to add to VG.
@@ -550,7 +550,7 @@
  * lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   device
  * Name of device to remove from VG.
@@ -571,7 +571,7 @@
  * with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   tag
  * Tag to add to the VG.
@@ -592,7 +592,7 @@
  * with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   tag
  * Tag to remove from VG.
@@ -613,7 +613,7 @@
  * handle with lvm_vg_close().
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   new_size
  * New extent size in bytes.
@@ -629,7 +629,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 1 if the VG is clustered, 0 if not
@@ -642,7 +642,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 1 if the VG is exported, 0 if not
@@ -659,7 +659,7 @@
  * group.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * 1 if the VG is PVs, 0 if not
@@ -676,7 +676,7 @@
  * have changed from a prior query.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Metadata sequence number.
@@ -692,7 +692,7 @@
  * released when lvm_vg_close() is called.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Copy of the uuid string.
@@ -708,7 +708,7 @@
  * released when lvm_vg_close() is called.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Copy of the name.
@@ -721,7 +721,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Size in bytes.
@@ -734,7 +734,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Free size in bytes.
@@ -747,7 +747,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Extent size in bytes.
@@ -760,7 +760,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Extent count.
@@ -773,7 +773,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Free extent count.
@@ -786,7 +786,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Physical volume count.
@@ -799,7 +799,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Maximum number of physical volumes allowed in a volume group.
@@ -812,7 +812,7 @@
  * \memberof vg_t
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \return
  * Maximum number of logical volumes allowed in a volume group.
@@ -858,7 +858,7 @@
  * as the API is developed.
  *
  * \param   vg
- * VG handle obtained from lvm_vg_create or lvm_vg_open().
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
  *
  * \param   name
  * Name of logical volume to create.
@@ -945,7 +945,7 @@
  *
  * \memberof lv_t
  *
- * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * The memory allocated for the name is tied to the vg_t handle and will be
  * released when lvm_vg_close() is called.
  *
  * \param   lv
@@ -1115,7 +1115,7 @@
  *
  * \memberof pv_t
  *
- * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * The memory allocated for the name is tied to the vg_t handle and will be
  * released when lvm_vg_close() is called.
  *
  * \param   pv


