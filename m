From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:55 -0500
Subject: [PATCH 07/21] Add lvm_vg_get_attr_value() libLVM API to query to value of a VG attribute.
In-Reply-To: <1234153329-2829-7-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This API may be used independently to query the value of a VG attribute,
provided the name of the attribute is known.  If the name of the attribute(s)
are unknown, the previous API, vg_get_attr_list(), may be used.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    2 ++
 lib/report/report.c     |   28 ++++++++++++++++++++++++++++
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |   12 ++++++++++++
 libdm/libdm-report.c    |   29 +++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 57e8b6c..b274762 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -79,6 +79,8 @@ const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
 int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list);
+int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
+			  struct dm_report_field_value_type *value);
 
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 void lvm_vg_close(vg_t *vg);
diff --git a/lib/report/report.c b/lib/report/report.c
index c070d49..fb342a5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1217,3 +1217,31 @@ int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list)
 	dm_report_free(rh);
 	return 1;
 }
+
+/*
+ * Get the value of the VG attribute 'attr_name'.
+ */
+int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
+			  struct dm_report_field_value_type *value)
+{
+	void *rh;
+	report_type_t report_type = VGS;
+
+	if (!(rh = report_init(vg->cmd, attr_name, "", &report_type,
+			       " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		return 0;
+	}
+
+	if (!report_object(rh, vg, NULL, NULL, NULL, NULL)) {
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
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index aa70f29..e7a4906 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -133,6 +133,7 @@ dm_report_field_uint32
 dm_report_field_uint64
 dm_report_field_set_value
 dm_report_get_field_ids
+dm_report_get_field_value
 dm_report_set_output_field_name_prefix
 dm_regex_create
 dm_regex_match
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index cc8302a..d6cb7cf 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -927,6 +927,15 @@ struct dm_report_field_type {
 struct dm_report_field_ids_type {
 	struct dm_list list;
 	const char *id;
+	uint32_t type; /* FIXME: unnecessary ?*/
+};
+
+struct dm_report_field_value_type {
+	unsigned is_string;
+	union {
+		char *s_val;
+		uint64_t n_val;
+	} u;
 };
 
 /*
@@ -935,6 +944,9 @@ struct dm_report_field_ids_type {
 int dm_report_get_field_ids(struct dm_report *rh, uint32_t type,
 			    struct dm_list *list);
 
+int dm_report_get_field_value(struct dm_report *rh,
+			      struct dm_report_field_value_type *value);
+
 /*
  * dm_report_init output_flags
  */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 08bffbd..6bb9c14 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1099,7 +1099,36 @@ int dm_report_get_field_ids(struct dm_report *rh, uint32_t type,
 			log_error("dm_report_get_field_ids: dm_pool_strdup failed");
 			return 0;
 		}
+		field_id->type = type;
 		dm_list_add(list, &field_id->list);
 	}
 	return 1;
 }
+
+
+int dm_report_get_field_value(struct dm_report *rh,
+			      struct dm_report_field_value_type *value)
+{
+	struct dm_report_field *field;
+	struct row *row;
+
+	dm_list_iterate_items(row, &rh->rows) {
+		if ((field = dm_list_item(dm_list_first(&row->fields),
+					  struct dm_report_field))) {
+			if ((field->props->flags & DM_REPORT_FIELD_TYPE_MASK) ==
+			    DM_REPORT_FIELD_TYPE_STRING) {
+				value->is_string = 1;
+				value->u.s_val = dm_pool_strdup(rh->mem,
+								field->sort_value);
+			} else {
+				value->is_string = 0;
+				value->u.n_val = *(const uint64_t *)field->sort_value;
+			}
+			dm_list_del(&field->list);
+		}
+		
+	}
+
+	return 1;
+
+}
-- 
1.6.0.5


