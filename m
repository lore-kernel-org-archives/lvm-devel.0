From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Apr 2010 15:22:25 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c
Message-ID: <20100419152225.3141.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-19 15:22:24

Modified files:
	liblvm         : lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	Use vg->vgmem to allocate vg/lv/pv string properties instead of dm_malloc/fr
	
	Everywhere else in the API the caller can rely on lvm2app taking care of
	memory allocation and free, so make the 'name' and 'uuid' properties of a
	vg/lv/pv use the vg handle to allocate memory.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/liblvm/lvm2app.h	2010/02/24 18:16:44	1.14
+++ LVM2/liblvm/lvm2app.h	2010/04/19 15:22:24	1.15
@@ -642,12 +642,12 @@
 uint64_t lvm_vg_get_seqno(const vg_t vg);
 
 /**
- * Get the current name of a volume group.
+ * Get the current uuid of a volume group.
  *
  * \memberof vg_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   vg
  * VG handle obtained from lvm_vg_create or lvm_vg_open().
@@ -655,15 +655,15 @@
  * \return
  * Copy of the uuid string.
  */
-char *lvm_vg_get_uuid(const vg_t vg);
+const char *lvm_vg_get_uuid(const vg_t vg);
 
 /**
- * Get the current uuid of a volume group.
+ * Get the current name of a volume group.
  *
  * \memberof vg_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the name is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   vg
  * VG handle obtained from lvm_vg_create or lvm_vg_open().
@@ -671,7 +671,7 @@
  * \return
  * Copy of the name.
  */
-char *lvm_vg_get_name(const vg_t vg);
+const char *lvm_vg_get_name(const vg_t vg);
 
 /**
  * Get the current size in bytes of a volume group.
@@ -783,7 +783,7 @@
  * \memberof vg_t
  *
  * The memory allocated for the list is tied to the vg_t handle and will be
- * released when lvm_vg_close is called.
+ * released when lvm_vg_close() is called.
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t vg;
@@ -896,7 +896,7 @@
  * \return
  * Copy of the uuid string.
  */
-char *lvm_lv_get_uuid(const lv_t lv);
+const char *lvm_lv_get_uuid(const lv_t lv);
 
 /**
  * Get the current uuid of a logical volume.
@@ -912,7 +912,7 @@
  * \return
  * Copy of the name.
  */
-char *lvm_lv_get_name(const lv_t lv);
+const char *lvm_lv_get_name(const lv_t lv);
 
 /**
  * Get the current size in bytes of a logical volume.
@@ -1001,7 +1001,7 @@
  * \memberof lv_t
  *
  * The memory allocated for the list is tied to the vg_t handle and will be
- * released when lvm_vg_close is called.
+ * released when lvm_vg_close() is called.
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      lv_t lv;
@@ -1057,8 +1057,8 @@
  *
  * \memberof pv_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   pv
  * Physical volume handle.
@@ -1066,15 +1066,15 @@
  * \return
  * Copy of the uuid string.
  */
-char *lvm_pv_get_uuid(const pv_t pv);
+const char *lvm_pv_get_uuid(const pv_t pv);
 
 /**
  * Get the current name of a physical volume.
  *
  * \memberof pv_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   pv
  * Physical volume handle.
@@ -1082,7 +1082,7 @@
  * \return
  * Copy of the name.
  */
-char *lvm_pv_get_name(const pv_t pv);
+const char *lvm_pv_get_name(const pv_t pv);
 
 /**
  * Get the current number of metadata areas in the physical volume.
--- LVM2/liblvm/lvm_lv.c	2010/03/25 18:22:05	1.21
+++ LVM2/liblvm/lvm_lv.c	2010/04/19 15:22:24	1.22
@@ -39,7 +39,7 @@
 	return SECTOR_SIZE * lv_size(lv);
 }
 
-char *lvm_lv_get_uuid(const lv_t lv)
+const char *lvm_lv_get_uuid(const lv_t lv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -47,17 +47,13 @@
 		log_error(INTERNAL_ERROR "unable to convert uuid");
 		return NULL;
 	}
-	return strndup((const char *)uuid, 64);
+	return dm_pool_strndup(lv->vg->vgmem, (const char *)uuid, 64);
 }
 
-char *lvm_lv_get_name(const lv_t lv)
+const char *lvm_lv_get_name(const lv_t lv)
 {
-	char *name;
-
-	name = dm_malloc(NAME_LEN + 1);
-	strncpy(name, (const char *)lv->name, NAME_LEN);
-	name[NAME_LEN] = '\0';
-	return name;
+	return dm_pool_strndup(lv->vg->vgmem, (const char *)lv->name,
+			       NAME_LEN+1);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
--- LVM2/liblvm/lvm_pv.c	2010/03/25 18:22:05	1.10
+++ LVM2/liblvm/lvm_pv.c	2010/04/19 15:22:24	1.11
@@ -17,7 +17,7 @@
 #include "metadata-exported.h"
 #include "lvm-string.h"
 
-char *lvm_pv_get_uuid(const pv_t pv)
+const char *lvm_pv_get_uuid(const pv_t pv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -25,17 +25,13 @@
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
 		return NULL;
 	}
-	return strndup((const char *)uuid, 64);
+	return dm_pool_strndup(pv->vg->vgmem, (const char *)uuid, 64);
 }
 
-char *lvm_pv_get_name(const pv_t pv)
+const char *lvm_pv_get_name(const pv_t pv)
 {
-	char *name;
-
-	name = dm_malloc(NAME_LEN + 1);
-	strncpy(name, (const char *)pv_dev_name(pv), NAME_LEN);
-	name[NAME_LEN] = '\0';
-	return name;
+	return dm_pool_strndup(pv->vg->vgmem,
+			       (const char *)pv_dev_name(pv), NAME_LEN + 1);
 }
 
 uint64_t lvm_pv_get_mda_count(const pv_t pv)
--- LVM2/liblvm/lvm_vg.c	2010/03/25 18:22:05	1.39
+++ LVM2/liblvm/lvm_vg.c	2010/04/19 15:22:24	1.40
@@ -328,7 +328,7 @@
 	return vg_max_lv(vg);
 }
 
-char *lvm_vg_get_uuid(const vg_t vg)
+const char *lvm_vg_get_uuid(const vg_t vg)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -336,17 +336,12 @@
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
 		return NULL;
 	}
-	return strndup((const char *)uuid, 64);
+	return dm_pool_strndup(vg->vgmem, (const char *)uuid, 64);
 }
 
-char *lvm_vg_get_name(const vg_t vg)
+const char *lvm_vg_get_name(const vg_t vg)
 {
-	char *name;
-
-	name = dm_malloc(NAME_LEN + 1);
-	strncpy(name, (const char *)vg->name, NAME_LEN);
-	name[NAME_LEN] = '\0';
-	return name;
+	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)


