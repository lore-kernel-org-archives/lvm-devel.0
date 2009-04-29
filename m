From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:32 -0400
Subject: [PATCH 6/8] Add lvm_lvs_in_vg() - returns a list of lv handles for a given vg.
In-Reply-To: <1241034934-25639-6-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-4-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-5-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- Use vgmem pool to allocate a list of lvm_lv_list structs
- Allocate a new list each call (list may have changed since last call)
- Add lvm_lvs_in_vg to liblvm's exported symbols

NOTE: we may want to think about memory management beyond using the
vgmem pool.  Another possibility is to have a list handle that is allocated
and freed, then the memory is attached to that.  With a list handle you
would not have to close/release the vg to free the list memory.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    1 +
 liblvm/lvm.h             |    7 +++++++
 liblvm/lvm_base.c        |   26 ++++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index f00bb19..d05be6f 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -5,3 +5,4 @@ lvm_lv_get_name
 lvm_lv_get_uuid
 lvm_vg_get_name
 lvm_vg_get_uuid
+lvm_lvs_in_vg
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index b345b36..9574991 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -58,6 +58,13 @@ typedef struct lvm_lv_list {
 	lv_t *lv;
 } lv_list_t;
 
+/**
+ * Return a list of LV handles for a given VG handle.
+ *
+ * \return  A list of lv_list_t structures containing lv handles for this vg.
+ *          If no LVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_lvs_in_vg(vg_t *vg);
 
 struct lvm; /* internal data */
 
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 213246a..4e235ab 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -60,3 +60,29 @@ int lvm_reload_config(lvm_t libh)
 	/* FIXME: re-init locking needed here? */
 	return refresh_toolcontext((struct cmd_context *)libh);
 }
+
+struct dm_list *lvm_lvs_in_vg(vg_t *vg)
+{
+	struct dm_list *list;
+	lv_list_t *lvs;
+	struct lv_list *lvl;
+
+	if (dm_list_empty(&vg->lvs))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
+		log_error("Memory allocation fail for dm_list.\n");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
+			log_error("Memory allocation fail for lvm_lv_list.\n");
+			return NULL;
+		}
+		lvs->lv = lvl->lv;
+		dm_list_add(list, &lvs->list);
+	}
+	return list;
+}
-- 
1.6.0.6


