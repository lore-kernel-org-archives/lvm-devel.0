From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:08 -0500
Subject: [PATCH 12/13] First cut at adding pv_obj_* APIs.
In-Reply-To: <1233607809-1087-12-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-10-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-11-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Impelemnt pv_obj_get(), pv_obj_get_list(), pv_obj_get_attr_list() and
pv_obj_get_attr_value().

This is a first attempt at adding pv_obj_* APIs as outlined by
http://fedoraproject.org/wiki/LVM/liblvm/api

Why add another structure when we could use struct physical_volume
and other internal structs?  At this point it is not clear but would
provide us with the ability to more easily allocate and free handles,
and would allow places to store things like the access mode and API
errors without polluting the internal structures.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c |  121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/lvm2.h |   36 ++++++++++++++++++
 2 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index bb8f295..4108321 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -68,3 +68,124 @@ int lvm_reload_config(lvm_handle_t libh)
 {
 	return refresh_toolcontext((struct cmd_context *)libh);
 }
+
+
+struct lvm_pv_obj {
+	char mode;
+	struct physical_volume *pv;
+};
+
+
+/*
+ * Gets object for a physical volume by volume path
+ * Retuns lvm_pv_obj_t on success, otherwide NULL. errno is used to indicate 
+ * the error.
+ * mode: "r" or "w"
+ */
+lvm_pv_obj_t *lvm_pv_obj_get(lvm_handle_t libh, const char* phys_vol,
+                            const char *mode)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	lvm_pv_obj_t *pv_obj;
+	struct physical_volume *pv;
+	struct dm_list mdas;
+	uint64_t label_sector;
+
+	dm_list_init(&mdas);
+	pv = pv_read(cmd, phys_vol, &mdas, &label_sector, 0);
+	if (!pv)
+		return NULL;
+	
+	pv_obj = dm_pool_alloc(cmd->mem, sizeof(*pv_obj));
+	if (!pv_obj)
+		return NULL;
+
+	pv_obj->pv = pv;
+	pv_obj->mode = mode[0];
+
+	return pv_obj;
+}
+
+
+lvm_pv_obj_list_t *lvm_pv_obj_list(lvm_handle_t libh)
+{
+	struct dm_list *pvs;
+	struct pv_list *pvl;
+	lvm_pv_obj_list_t *head = NULL, *elem;
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+
+	pvs = get_pvs(cmd);
+
+	if (dm_list_empty(pvs))
+		return NULL;
+
+	dm_list_iterate_items(pvl, pvs) {
+		elem = dm_pool_alloc(cmd->mem, sizeof(*elem));
+		if (!elem)
+			return NULL;
+		elem->obj = lvm_pv_obj_get(libh, lvm_pv_name(pvl->pv), "r");
+		if (!head)
+			head = elem;
+		dm_list_add(&head->list, &elem->list);
+	}
+	return head;
+}
+
+
+/*
+ * Get a list of attributes for a vg
+ */
+int lvm_pv_obj_get_attr_list(lvm_pv_obj_t *obj, struct dm_list *list)
+{
+	void *rh;
+	report_type_t report_type = PVS;
+
+	dm_list_init(list);
+
+	/*
+	 * Create a report so we can return the headings.
+	 */
+	if (!(rh = report_init(obj->pv->fmt->cmd, "all", "", &report_type,
+			       " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		return 0;
+	}
+
+	if (!dm_report_get_field_ids(rh, report_type, list)) {
+		dm_report_free(rh);
+		return 0;
+	}
+
+	dm_report_free(rh);
+	return 1;
+}
+
+/*
+ * Get the value of the VG attribute 'attr_name'.
+ */
+int lvm_pv_obj_get_attr_value(lvm_pv_obj_t *obj, const char *attr_name,
+			  struct dm_report_field_value_type *value)
+{
+	void *rh;
+	report_type_t report_type = PVS;
+
+	if (!(rh = report_init(obj->pv->fmt->cmd, attr_name, "", &report_type,
+			       " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		return 0;
+	}
+
+	if (!report_object(rh, NULL, NULL, obj->pv, NULL, NULL)) {
+		stack;
+		return 0;
+	}
+	
+	if (!dm_report_get_field_value(rh, value)) {
+		stack;
+		return 0;
+	}
+	dm_report_free(rh);
+	return 1;
+}
+
+
diff --git a/lib/lvm2.h b/lib/lvm2.h
index 2a5dd9e..a47c0a5 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -104,4 +104,40 @@ struct lvm_pv_list {
 };
 struct dm_list *lvm_pvs_in_vg(vg_t *vg);
 
+/*
+ * The lvm physical volume object.
+ */
+struct lvm_pv_obj;
+typedef struct lvm_pv_obj lvm_pv_obj_t; /* with mode inside (r/rw) */
+
+/*
+ * The lvm physical volume object list.
+ */
+typedef struct lvm_pv_obj_list {
+  struct dm_list list;
+  lvm_pv_obj_t *obj;
+} lvm_pv_obj_list_t;
+
+/*
+ * Gets object for a physical volume by volume path
+ * Retuns lvm_pv_obj_t on success, otherwide NULL. errno is used to indicate 
+ * the error.
+ * mode: "r" or "rw"
+ */
+lvm_pv_obj_t *lvm_pv_obj_get(lvm_handle_t libh, const char* phys_vol,
+                            const char *mode);
+
+
+/*
+ * Returns list of physical volumes.
+ * Retuns lvm_pv_obj_list_t on success, otherwide NULL. errno is used to 
+ * indicate the error. The objects are read only.
+ */
+lvm_pv_obj_list_t *lvm_pv_obj_list(lvm_handle_t libh);
+
+int lvm_pv_obj_get_attr_list(lvm_pv_obj_t *obj, struct dm_list *list);
+int lvm_pv_obj_get_attr_value(lvm_pv_obj_t *obj, const char *attr_name,
+			      struct dm_report_field_value_type *value);
+
+
 #endif
-- 
1.5.5.1


