From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:54 -0500
Subject: [PATCH 1/7] Add lvseg_t to lvm2app and lvm_lv_list_lvsegs().
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dave Wysochanski <dwysocha@redhat.com>

Add a new type and function to lvm2app to enumerate lvsegs.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h |   31 +++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c  |   27 +++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index a5f65e9..82ed383 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -95,6 +95,7 @@ struct lvm;
 struct physical_volume;
 struct volume_group;
 struct logical_volume;
+struct lv_segment;
 
 /**
  * \class lvm_t
@@ -137,6 +138,13 @@ typedef struct logical_volume *lv_t;
 typedef struct physical_volume *pv_t;
 
 /**
+ * \class lvseg_t
+ *
+ * This lv segment object is bound to a lv_t.
+ */
+typedef struct lv_segment *lvseg_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -147,6 +155,16 @@ typedef struct lvm_lv_list {
 } lv_list_t;
 
 /**
+ * Logical Volume Segment object list.
+ *
+ * Lists of these structures are returned by lvm_lv_list_lvsegs().
+ */
+typedef struct lvm_lvseg_list {
+	struct dm_list list;
+	lvseg_t lvseg;
+} lvseg_list_t;
+
+/**
  * Physical volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_pvs().
@@ -936,6 +954,19 @@ struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name);
 lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 
 /**
+ * Return a list of lvseg handles for a given LV handle.
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * A list of lvm_lvseg_list structures containing lvseg handles for this lv.
+ */
+struct dm_list *lvm_lv_list_lvsegs(lv_t lv);
+
+/**
  * Activate a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index cef87f5..42982f9 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -216,6 +216,33 @@ int lvm_lv_deactivate(lv_t lv)
 	return 0;
 }
 
+struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
+{
+	struct dm_list *list;
+	lvseg_list_t *lvseg;
+	struct lv_segment *lvl;
+
+	if (dm_list_empty(&lv->segments))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(lv->vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(lvl, &lv->segments) {
+		if (!(lvseg = dm_pool_zalloc(lv->vg->vgmem, sizeof(*lvseg)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lvseg_list.");
+			return NULL;
+		}
+		lvseg->lvseg = lvl;
+		dm_list_add(list, &lvseg->list);
+	}
+	return list;
+}
+
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
-- 
1.7.2.2


