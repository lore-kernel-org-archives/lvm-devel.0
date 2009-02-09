From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:58 -0500
Subject: [PATCH 10/21] Add lvm_lv_get_attr_list() and lvm_lv_get_attr_value().
In-Reply-To: <1234153329-2829-10-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h          |    3 ++
 lib/report/report.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 25ce12d..2a5dd9e 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -91,6 +91,9 @@ struct lvm_lv_list {
 };
 struct dm_list *lvm_lvs_in_vg(vg_t *vg);
 
+int lvm_lv_get_attr_list(lv_t *lv, struct dm_list *list);
+int lvm_lv_get_attr_value(lv_t *lv, const char *attr_name,
+			  struct dm_report_field_value_type *value);
 /*
  * FIXME: struct lvm_pv_list is not equivalent to struct pv_list, which
  * is used in lvm_pvs_in_vg().  Ideally we should not need a new structure.
diff --git a/lib/report/report.c b/lib/report/report.c
index fb342a5..1d219bf 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1245,3 +1245,60 @@ int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 	dm_report_free(rh);
 	return 1;
 }
+
+
+/*
+ * Get a list of attributes for a LV
+ */
+int lvm_lv_get_attr_list(lv_t *lv, struct dm_list *list)
+{
+	void *rh;
+	report_type_t report_type = LVS;
+
+	dm_list_init(list);
+
+	/*
+	 * Create a report so we can return the headings.
+	 */
+	if (!(rh = report_init(lv->vg->cmd, "all", "", &report_type,
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
+ * Get the value of the LV attribute 'attr_name'.
+ */
+int lvm_lv_get_attr_value(lv_t *lv, const char *attr_name,
+			  struct dm_report_field_value_type *value)
+{
+	void *rh;
+	report_type_t report_type = LVS;
+
+	if (!(rh = report_init(lv->vg->cmd, attr_name, "", &report_type,
+			       " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		return 0;
+	}
+
+	if (!report_object(rh, NULL, lv, NULL, NULL, NULL)) {
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
-- 
1.6.0.5


