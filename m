From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 19 Nov 2010 21:25:38 -0500
Subject: [PATCH 1/3] Add lvm2app helper functions to lookup an lv and pv handle by name.
In-Reply-To: <1290219940-29464-1-git-send-email-wysochanski@pobox.com>
References: <1290219940-29464-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290219940-29464-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds helpers to allow users to lookup a lv or pv handle by
name (given a vg_t of course).

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h |   34 ++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c  |   11 +++++++++++
 liblvm/lvm_pv.c  |   12 ++++++++++++
 3 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index d6378ac..4750211 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1015,6 +1015,23 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 struct dm_list *lvm_lv_list_lvsegs(lv_t lv);
 
 /**
+ * Lookup an LV handle in a VG by the LV name.
+ *
+ * \memberof lv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of LV to lookup.
+ *
+ * \return
+ * non-NULL handle to the LV 'name' attached to the VG.
+ * NULL is returned if the LV name is not associated with the VG handle.
+ */
+lv_t lvm_lv_from_name(vg_t vg, const char *name);
+
+/**
  * Activate a logical volume.
  *
  * \memberof lv_t
@@ -1489,6 +1506,23 @@ struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv);
 
 /**
+ * Lookup an PV handle in a VG by the PV name.
+ *
+ * \memberof pv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of PV to lookup.
+ *
+ * \return
+ * non-NULL handle to the PV 'name' attached to the VG.
+ * NULL is returned if the PV name is not associated with the VG handle.
+ */
+pv_t lvm_pv_from_name(vg_t vg, const char *name);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 432f5b7..5e8322f 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -249,6 +249,17 @@ struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
 	return list;
 }
 
+lv_t lvm_lv_from_name(vg_t vg, const char *name)
+{
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!strcmp(name, lvl->lv->name))
+			return lvl->lv;
+	}
+	return NULL;
+}
+
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 9ca92d5..3372fde 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -87,6 +87,18 @@ struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
 	return list;
 }
 
+pv_t lvm_pv_from_name(vg_t vg, const char *name)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!strcmp(name, pv_dev_name(pvl->pv)))
+			return pvl->pv;
+	}
+	return NULL;
+}
+
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-- 
1.7.2.2


