From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Jul 2013 15:21:24 +0000 (UTC)
Subject: master - python: update coding style
Message-ID: <20130705152124.C043E60CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e79cca9e75e5c50b92744cb89be2e29853597ab
Commit:        9e79cca9e75e5c50b92744cb89be2e29853597ab
Parent:        7319bc04207ece28fa22224878ad6a3a0aacdbfa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 5 16:10:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 5 17:20:57 2013 +0200

python: update coding style

Update code to match lvm coding standards
Disable/skip test - since it's accessing VGs available in the system.
Before reenable - validate it's not touching any PV outside those
created during test.
---
 liblvm/lvm_pv.c    |   96 +++++++++++++++++++++++-----------------------------
 test/api/pytest.sh |   21 +++++++----
 2 files changed, 55 insertions(+), 62 deletions(-)

diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 8915e7c..622ef98 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -28,8 +28,7 @@ const char *lvm_pv_get_uuid(const pv_t pv)
 
 const char *lvm_pv_get_name(const pv_t pv)
 {
-	return dm_pool_strndup(pv->vg->vgmem,
-			       (const char *)pv_dev_name(pv), NAME_LEN + 1);
+	return dm_pool_strndup(pv->vg->vgmem, pv_dev_name(pv), NAME_LEN);
 }
 
 uint64_t lvm_pv_get_mda_count(const pv_t pv)
@@ -39,17 +38,17 @@ uint64_t lvm_pv_get_mda_count(const pv_t pv)
 
 uint64_t lvm_pv_get_dev_size(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE * pv_dev_size(pv);
+	return SECTOR_SIZE * pv_dev_size(pv);
 }
 
 uint64_t lvm_pv_get_size(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE * pv_size_field(pv);
+	return SECTOR_SIZE * pv_size_field(pv);
 }
 
 uint64_t lvm_pv_get_free(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE * pv_free(pv);
+	return SECTOR_SIZE * pv_free(pv);
 }
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
@@ -63,11 +62,6 @@ struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, name);
 }
 
-
-#define address_of(p, t, m) ({                  \
-	const typeof( ((t *)0)->m ) *__mptr = (p);    \
-	(t *)( (char *)__mptr - offsetof(t,m) );})
-
 struct lvm_list_wrapper
 {
 	unsigned long magic;
@@ -78,9 +72,10 @@ struct lvm_list_wrapper
 int lvm_pv_remove(lvm_t libh, const char *pv_name)
 {
 	struct cmd_context *cmd = (struct cmd_context *)libh;
-	if ( 1 != pvremove_single(cmd, pv_name, NULL, 0, 0)) {
+
+	if (pvremove_single(cmd, pv_name, NULL, 0, 0) != 1)
 		return -1;
-	}
+
 	return 0;
 }
 
@@ -89,9 +84,7 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 	struct lvm_list_wrapper *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 
-
-	rc = dm_pool_zalloc(cmd->mem, sizeof(*rc));
-	if (!rc) {
+	if (!(rc = dm_pool_zalloc(cmd->mem, sizeof(*rc)))) {
 		log_errno(ENOMEM, "Memory allocation fail for pv list.");
 		return NULL;
 	}
@@ -113,36 +106,33 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 
 int lvm_list_pvs_free(struct dm_list *pvlist)
 {
-	int rc = 0;
-	struct lvm_list_wrapper *to_delete = NULL;
-	struct vg_list *vgl = NULL;
-	struct pv_list *pvl = NULL;
+	struct lvm_list_wrapper *to_delete;
+	struct vg_list *vgl;
+	struct pv_list *pvl;
 	struct cmd_context *cmd = NULL;
 
-	if (pvlist ) {
-		to_delete = address_of(pvlist, struct lvm_list_wrapper, pvslist);
-		if (to_delete->magic == 0xF005BA11) {
+	if (pvlist) {
+		to_delete = dm_list_struct_base(pvlist, struct lvm_list_wrapper, pvslist);
+		if (to_delete->magic != 0xF005BA11) {
+			log_errno(EINVAL, "Not a correct pvlist structure");
+			return -1;
+		}
 
-			dm_list_iterate_items(vgl, &to_delete->vgslist) {
-				cmd = vgl->vg->cmd;
-				release_vg(vgl->vg);
-			}
+		dm_list_iterate_items(vgl, &to_delete->vgslist) {
+			cmd = vgl->vg->cmd;
+			release_vg(vgl->vg);
+		}
 
-			dm_list_iterate_items(pvl, &to_delete->pvslist) {
-				free_pv_fid(pvl->pv);
-			}
+		dm_list_iterate_items(pvl, &to_delete->pvslist)
+			free_pv_fid(pvl->pv);
 
-			unlock_vg(cmd, VG_GLOBAL);
-		} else {
-			log_errno(EINVAL, "Not a correct pvlist structure");
-			rc = -1;
-		}
+		unlock_vg(cmd, VG_GLOBAL);
 
 		to_delete->magic = 0xA5A5A5A5;
 		dm_pool_free(cmd->mem, to_delete);
-
 	}
-	return rc;
+
+	return 0;
 }
 
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
@@ -158,6 +148,7 @@ struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
 		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
 		return NULL;
 	}
+
 	dm_list_init(list);
 
 	dm_list_iterate_items(pvl, &pv->segments) {
@@ -169,6 +160,7 @@ struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
 		pvseg->pvseg = pvl;
 		dm_list_add(list, &pvseg->list);
 	}
+
 	return list;
 }
 
@@ -176,10 +168,10 @@ pv_t lvm_pv_from_name(vg_t vg, const char *name)
 {
 	struct pv_list *pvl;
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (!strcmp(name, pv_dev_name(pvl->pv)))
 			return pvl->pv;
-	}
+
 	return NULL;
 }
 
@@ -198,14 +190,13 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
 		return NULL;
 	}
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->pvs)
 		if (id_equal(&id, &pvl->pv->id))
 			return pvl->pv;
-	}
+
 	return NULL;
 }
 
-
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	uint64_t size = new_size >> SECTOR_SHIFT;
@@ -215,40 +206,37 @@ int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 		return -1;
 	}
 
-	if (!vg_check_write_mode(pv->vg)) {
+	if (!vg_check_write_mode(pv->vg))
 		return -1;
-	}
 
 	if (!pv_resize_single(pv->vg->cmd, pv->vg, pv, size)) {
 		log_error("PV re-size failed!");
 		return -1;
-	} else {
-		return 0;
 	}
+
+	return 0;
 }
 
 int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
 {
-	int rc = -1;
 	struct pvcreate_params pp;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 	uint64_t size_sectors = size;
 
 	pvcreate_params_set_defaults(&pp);
 
-	if (size_sectors != 0 ) {
-		if( size_sectors % SECTOR_SIZE ) {
+	if (size_sectors != 0) {
+		if (size_sectors % SECTOR_SIZE) {
 			log_errno(EINVAL, "Size not a multiple of 512");
-					return -1;
+			return -1;
 		}
 		size_sectors = size_sectors >> SECTOR_SHIFT;
 	}
 
 	pp.size = size_sectors;
 
-	if (ECMD_PROCESSED == pvcreate_locked(cmd, pv_name, &pp)) {
-		rc = 0;
-	}
+	if (pvcreate_locked(cmd, pv_name, &pp) != ECMD_PROCESSED)
+		return -1;
 
-	return rc;
+	return 0;
 }
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index a1a3cb4..1f6968b 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -18,11 +18,16 @@ aux prepare_pvs 6
 
 #Locate the python binding library to use.
 python_lib=`find $abs_top_builddir -name lvm.so`
-if [ "$python_lib" != "" ]
-then
-	export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
-	python_lvm_unit.py -v
-	#nemiver python ../api/python_lvm_unit.py -v -f
-else
-	echo "Unable to test python bindings as library not available"
-fi
+
+# Unable to test python bindings if library not available
+test -z "$python_lib" && skip
+
+export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
+
+skip
+
+# skiped until fixed
+# FIXME - script must ONLY use  $(cat DEVICES) as PVs
+# it must NOT create/modify/remove volumes from other places
+python_lvm_unit.py -v
+# nemiver python ../api/python_lvm_unit.py -v -f


