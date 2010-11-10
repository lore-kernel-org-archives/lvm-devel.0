From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:57 -0500
Subject: [PATCH 4/7] Add pvseg_t to lvm2app and lvm_pv_list_pvsegs().
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-5-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a new type and function to lvm2app to enumerate pvsegs.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h |   31 +++++++++++++++++++++++++++++++
 liblvm/lvm_pv.c  |   27 +++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 744d343..de6e8a3 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -96,6 +96,7 @@ struct physical_volume;
 struct volume_group;
 struct logical_volume;
 struct lv_segment;
+struct pv_segment;
 
 /**
  * \class lvm_t
@@ -145,6 +146,13 @@ typedef struct physical_volume *pv_t;
 typedef struct lv_segment *lvseg_t;
 
 /**
+ * \class pvseg_t
+ *
+ * This pv segment object is bound to a pv_t.
+ */
+typedef struct pv_segment *pvseg_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -175,6 +183,16 @@ typedef struct lvm_pv_list {
 } pv_list_t;
 
 /**
+ * Physical Volume Segment object list.
+ *
+ * Lists of these structures are returned by lvm_pv_list_pvsegs().
+ */
+typedef struct lvm_pvseg_list {
+	struct dm_list list;
+	pvseg_t pvseg;
+} pvseg_list_t;
+
+/**
  * String list.
  *
  * This string list contains read-only strings.
@@ -1389,6 +1407,19 @@ uint64_t lvm_pv_get_free(const pv_t pv);
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
 
 /**
+ * Return a list of pvseg handles for a given PV handle.
+ *
+ * \memberof pv_t
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * A list of lvm_pvseg_list structures containing pvseg handles for this pv.
+ */
+struct dm_list *lvm_pv_list_pvsegs(pv_t pv);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 6705dd8..aaaca92 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -54,6 +54,33 @@ struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 	return get_property(pv, NULL, NULL, NULL, name);
 }
 
+struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
+{
+	struct dm_list *list;
+	pvseg_list_t *pvseg;
+	struct pv_segment *pvl;
+
+	if (dm_list_empty(&pv->segments))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(pv->vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(pvl, &pv->segments) {
+		if (!(pvseg = dm_pool_zalloc(pv->vg->vgmem, sizeof(*pvseg)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_pvseg_list.");
+			return NULL;
+		}
+		pvseg->pvseg = pvl;
+		dm_list_add(list, &pvseg->list);
+	}
+	return list;
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-- 
1.7.2.2


