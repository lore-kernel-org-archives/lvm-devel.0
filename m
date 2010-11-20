From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 19 Nov 2010 21:25:39 -0500
Subject: [PATCH 2/3] Add lvm2app helper functions to lookup an lv and pv handle by uuid.
In-Reply-To: <1290219940-29464-1-git-send-email-wysochanski@pobox.com>
References: <1290219940-29464-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290219940-29464-3-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds helpers to allow users to lookup a lv or pv handle by
uuid (given a vg_t of course).

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h |   38 ++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c  |   22 ++++++++++++++++++++++
 liblvm/lvm_pv.c  |   22 ++++++++++++++++++++++
 3 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 4750211..1fff08a 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1032,6 +1032,25 @@ struct dm_list *lvm_lv_list_lvsegs(lv_t lv);
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
@@ -1523,6 +1542,25 @@ struct dm_list *lvm_pv_list_pvsegs(pv_t pv);
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
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 5e8322f..85d536c 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -260,6 +260,28 @@ lv_t lvm_lv_from_name(vg_t vg, const char *name)
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
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 3372fde..5f2014d 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -98,6 +98,28 @@ pv_t lvm_pv_from_name(vg_t vg, const char *name)
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
-- 
1.7.2.2


