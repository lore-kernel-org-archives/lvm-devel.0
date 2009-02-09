From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:56 -0500
Subject: [PATCH 08/21] Add lvm_lvs_in_vg() API.
In-Reply-To: <1234153329-2829-8-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Returns list of only user-displayable LVs.
Add exported lvm_lv_list structure along with the API.  Note that this
struct is very similar to struct lv_list.
TODO: merge struct lv_list and struct lvm_lv_list

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    7 +++++++
 lib/metadata/metadata.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index b274762..4d25d25 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -84,4 +84,11 @@ int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 void lvm_vg_close(vg_t *vg);
+
+struct lvm_lv_list {
+	struct dm_list list;
+	lv_t *lv;
+};
+struct dm_list *lvm_lvs_in_vg(vg_t *vg);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0fa5db4..67fe58e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2497,6 +2497,35 @@ void lvm_vg_close(vg_t *vg)
 }
 
 /*
+ * Returns a list of all top-level, user-displayable LVs in a VG.
+ */
+struct dm_list *lvm_lvs_in_vg(vg_t *vg)
+{
+	struct dm_list *l;
+	struct lvm_lv_list *ll;
+	struct lv_list *lvl;
+	/* FIXME: lv_list should be replaced by lvm_lv_list */
+	struct dm_pool *mem = vg->cmd->mem;
+
+	/* FIXME: Return code for memory allocation failure */
+	if (!(l = dm_pool_alloc(mem, sizeof(struct dm_list)))) {
+		log_error("Error allocating LV list.");
+		return NULL;
+	}
+	dm_list_init(l);
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!lv_is_displayable(lvl->lv))
+			continue;
+		if (!(ll = dm_pool_alloc(mem, sizeof(*ll))))
+			log_error("Error allocating LV list member");
+		ll->lv = lvl->lv;
+		dm_list_add(l, &ll->list);
+	}
+
+	return l;
+}
+
+/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */
-- 
1.6.0.5


