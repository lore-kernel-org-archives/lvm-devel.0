From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:03 -0500
Subject: [PATCH 07/13] Add lvm_vg_get_attr_list() libLVM API to return a list of VG attribute names.
In-Reply-To: <1233607809-1087-7-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This API returns a list of attribute names for a VG.  A later API will
allow the values of the attributes to be queried.  The API implementation
relies on adding an exported call to libdevmapper, dm_report_get_field_ids(),
which is the interface into dm's reporting infrastructure to retrieve the
attribute/field names/ids.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    3 +++
 lib/report/report.c     |   28 ++++++++++++++++++++++++++++
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |   12 ++++++++++++
 libdm/libdm-report.c    |   27 +++++++++++++++++++++++++++
 5 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 85014f5..57e8b6c 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -17,6 +17,7 @@
 
 #include <stdint.h>
 #include <fcntl.h>
+#include "libdevmapper.h"
 
 /*
  * lvm_handle_t
@@ -77,6 +78,8 @@ const char *lvm_pv_name(const pv_t *pv);
 const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
+int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list);
+
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 void lvm_vg_close(vg_t *vg);
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 8439b2b..8e733d8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1191,3 +1191,31 @@ int report_object(void *handle, struct volume_group *vg,
 
 	return dm_report_object(handle, &obj);
 }
+
+/*
+ * Get a list of attributes for a vg
+ */
+int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list)
+{
+	void *rh;
+	report_type_t report_type = VGS;
+
+	dm_list_init(list);
+
+	/*
+	 * Create a report so we can return the headings.
+	 */
+	if (!(rh = report_init(vg->cmd, "all", "", &report_type,
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
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..aa70f29 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -132,6 +132,7 @@ dm_report_field_int32
 dm_report_field_uint32
 dm_report_field_uint64
 dm_report_field_set_value
+dm_report_get_field_ids
 dm_report_set_output_field_name_prefix
 dm_regex_create
 dm_regex_match
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..cc8302a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -924,6 +924,17 @@ struct dm_report_field_type {
 	const char *desc;	/* description of the field */
 };
 
+struct dm_report_field_ids_type {
+	struct dm_list list;
+	const char *id;
+};
+
+/*
+ * Returns a list of all field ids for a specific report type.
+ */
+int dm_report_get_field_ids(struct dm_report *rh, uint32_t type,
+			    struct dm_list *list);
+
 /*
  * dm_report_init output_flags
  */
@@ -947,6 +958,7 @@ int dm_report_object(struct dm_report *rh, void *object);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
 
+
 /*
  * Prefix added to each field name with DM_REPORT_OUTPUT_FIELD_NAME_PREFIX
  */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0c5ee6d..a9db211 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1076,3 +1076,30 @@ int dm_report_output(struct dm_report *rh)
 	else
 		return _output_as_columns(rh);
 }
+
+/*
+ * Return a list of field IDs (names) for a specified report type.
+ */
+int dm_report_get_field_ids(struct dm_report *rh, uint32_t type,
+			    struct dm_list *list)
+{
+	uint32_t f;
+	struct dm_report_field_ids_type *field_id;
+
+	for (f = 0; rh->fields[f].report_fn; f++) {
+		if (rh->fields[f].type != type)
+			continue;
+
+		if (!(field_id = dm_pool_zalloc(rh->mem, sizeof(*field_id)))) {
+			log_error("dm_report_get_field_ids: struct "
+				  "dm_report_field_ids_type allocation failed");
+			return 0;
+		}
+		if (!(field_id->id = dm_pool_strdup(rh->mem, rh->fields[f].id))) {
+			log_error("dm_report_get_field_ids: dm_pool_strdup failed");
+			return 0;
+		}
+		dm_list_add(list, &field_id->list);
+	}
+	return 1;
+}
-- 
1.5.5.1


