From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 14:34:56 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c
Message-ID: <20101125143456.10117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 14:34:52

Modified files:
	liblvm         : lvm2app.h lvm_lv.c lvm_pv.c 

Log message:
	This patch adds helpers to allow users to lookup a lv or pv handle by
	uuid (given a vg_t of course).
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/liblvm/lvm2app.h	2010/11/25 14:33:44	1.29
+++ LVM2/liblvm/lvm2app.h	2010/11/25 14:34:51	1.30
@@ -1032,6 +1032,25 @@
 lv_t lvm_lv_from_name(vg_t vg, const char *name);
 
 /**
+ * Lookup an LV handle in a VG by the LV uuid.
+ * The form of the uuid may be either the formatted, human-readable form,
+ * or the non-formatted form.
+ *
+ * \memberof lv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   uuid
+ * UUID of LV to lookup.
+ *
+ * \return
+ * non-NULL handle to the LV with 'uuid' attached to the VG.
+ * NULL is returned if the LV uuid is not associated with the VG handle.
+ */
+lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid);
+
+/**
  * Activate a logical volume.
  *
  * \memberof lv_t
@@ -1523,6 +1542,25 @@
 pv_t lvm_pv_from_name(vg_t vg, const char *name);
 
 /**
+ * Lookup an PV handle in a VG by the PV uuid.
+ * The form of the uuid may be either the formatted, human-readable form,
+ * or the non-formatted form.
+ *
+ * \memberof pv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   uuid
+ * UUID of PV to lookup.
+ *
+ * \return
+ * non-NULL handle to the PV with 'uuid' attached to the VG.
+ * NULL is returned if the PV uuid is not associated with the VG handle.
+ */
+pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
--- LVM2/liblvm/lvm_lv.c	2010/11/25 14:33:44	1.32
+++ LVM2/liblvm/lvm_lv.c	2010/11/25 14:34:51	1.33
@@ -260,6 +260,28 @@
 	return NULL;
 }
 
+lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
+{
+	struct lv_list *lvl;
+	struct id id;
+
+	if (strlen(uuid) < ID_LEN) {
+		log_errno (EINVAL, "Invalid UUID string length");
+		return NULL;
+	}
+	if (strlen(uuid) >= ID_LEN) {
+		if (!id_read_format(&id, uuid)) {
+			log_errno(EINVAL, "Invalid UUID format");
+			return NULL;
+		}
+	}
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (id_equal(&vg->id, &lvl->lv->lvid.id[0]) &&
+		    id_equal(&id, &lvl->lv->lvid.id[1]))
+			return lvl->lv;
+	}
+	return NULL;
+}
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
--- LVM2/liblvm/lvm_pv.c	2010/11/25 14:33:44	1.18
+++ LVM2/liblvm/lvm_pv.c	2010/11/25 14:34:51	1.19
@@ -98,6 +98,28 @@
 	return NULL;
 }
 
+pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
+{
+	struct pv_list *pvl;
+	struct id id;
+
+	if (strlen(uuid) < ID_LEN) {
+		log_errno (EINVAL, "Invalid UUID string length");
+		return NULL;
+	}
+	if (strlen(uuid) >= ID_LEN) {
+		if (!id_read_format(&id, uuid)) {
+			log_errno(EINVAL, "Invalid UUID format");
+			return NULL;
+		}
+	}
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (id_equal(&id, &pvl->pv->id))
+			return pvl->pv;
+	}
+	return NULL;
+}
+
 
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {


