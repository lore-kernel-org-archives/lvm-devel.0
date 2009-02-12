From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:30 -0500
Subject: [PATCH 01/12] Add dm_report_output_attributes() API to dm_report framework.
In-Reply-To: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add dm_report_output_attributes() which provides an alternative
output for a report - a list of attributes.
Add two new structs to support this function:
1. dm_report_attribute_type.  This describes a single attribute,
which is a field name,value pair
2. dm_report_attribute_list_type. This describes one row of a report,
as a list of attributes.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |   36 +++++++++++++++++++++-
 libdm/libdm-report.c    |   79 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 113 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..651f2b4 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -124,6 +124,7 @@ dm_asprintf
 dm_report_init
 dm_report_object
 dm_report_output
+dm_report_output_attributes
 dm_report_free
 dm_report_get_private
 dm_report_field_string
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..b050212 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -30,7 +30,7 @@
 #include <stdio.h>
 
 /*****************************************************************
- * The first section of this file provides direct access to the 
+ * The first section of this file provides direct access to the
  * individual device-mapper ioctls.
  ****************************************************************/
 
@@ -925,6 +925,33 @@ struct dm_report_field_type {
 };
 
 /*
+ * An attribute is just a (field,value) pair from a dm_report.
+ * We use the list of fields in a report to build a list of
+ * attributes for an object.  The report defines the list of
+ * attributes desired.  Once the report is built with one
+ * or more calls to dm_report_object(), report output can
+ * be obtained by either dm_report_output(), which displays
+ * the report to the screen, or dm_report_output_attributes(),
+ * which returns a list of report attributes for each object
+ * that produced a row of data in the report.
+ */
+struct dm_report_attribute_type {
+	struct dm_list list;
+	const char *name;
+	unsigned is_string;
+	union {
+		char *s_val;
+		uint64_t n_val;
+	} u;
+};
+
+struct dm_report_attribute_list_type {
+	struct dm_list list;
+	void *object;
+	struct dm_list attrs; /* dm_report_attribute_type */
+};
+
+/*
  * dm_report_init output_flags
  */
 #define DM_REPORT_OUTPUT_MASK			0x000000FF
@@ -945,8 +972,15 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 				 void *private);
 int dm_report_object(struct dm_report *rh, void *object);
 int dm_report_output(struct dm_report *rh);
+/*
+ * Return a list of object attributes described by the report.
+ * Each list entry described by struct dm_report_attribute_list_type
+ */
+int dm_report_output_attributes(struct dm_report *rh,
+				struct dm_list *list);
 void dm_report_free(struct dm_report *rh);
 
+
 /*
  * Prefix added to each field name with DM_REPORT_OUTPUT_FIELD_NAME_PREFIX
  */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6784a11..723473f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -81,6 +81,7 @@ struct row {
 	struct dm_report *rh;
 	struct dm_list fields;			  /* Fields in display order */
 	struct dm_report_field *(*sort_fields)[]; /* Fields in sort order */
+	void *object; /* object that created this row of data */
 };
 
 static const struct dm_report_object_type *_find_type(struct dm_report *rh,
@@ -666,7 +667,7 @@ int dm_report_set_output_field_name_prefix(struct dm_report *rh, const char *out
 	}
 
 	rh->output_field_name_prefix = _toupperstr(prefix);
-	
+
 	return 1;
 }
 
@@ -741,6 +742,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 		}
 		dm_list_add(&row->fields, &field->list);
 	}
+	row->object = object;
 
 	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
 		return dm_report_output(rh);
@@ -1089,3 +1091,76 @@ int dm_report_output(struct dm_report *rh)
 	else
 		return _output_as_columns(rh);
 }
+
+/*
+ * Create a list of attributes from a row of report output.
+ */
+static struct dm_report_attribute_list_type *
+_output_row_to_attribute_list(struct dm_report *rh, struct row *row)
+
+{
+	struct dm_list *fh, *ftmp;
+	struct dm_report_field *field;
+	struct dm_report_attribute_type *attr;
+	struct dm_report_attribute_list_type *attr_list;
+	uint32_t i;
+
+	if (dm_list_empty(&row->fields))
+		return NULL;
+
+	if (!(attr_list = dm_pool_zalloc(rh->mem, sizeof(*attr_list)))) {
+			log_error("_output_row_to_attribute: "
+				  "memory allocation failed\n");
+			return NULL;
+	}
+	attr_list->object = row->object;
+	dm_list_init(&attr_list->attrs);
+	
+	dm_list_iterate_safe(fh, ftmp, &row->fields) {
+		field = dm_list_item(fh, struct dm_report_field);
+		if (field->props->flags & FLD_HIDDEN)
+			continue;
+		if (!(attr = dm_pool_zalloc(rh->mem, sizeof(*attr)))) {
+			log_error("_output_row_to_attribute: "
+				  "memory allocation failed\n");
+			return NULL;
+		}
+		i = field->props->field_num;
+		if (!(attr->name = dm_pool_strdup(rh->mem, rh->fields[i].id))) {
+			log_error("_output_row_to_attribute: "
+				  "memory allocation failed\n");
+			return NULL;
+		}
+		if ((field->props->flags & DM_REPORT_FIELD_TYPE_MASK) ==
+		    DM_REPORT_FIELD_TYPE_STRING) {
+			attr->is_string = 1;
+			attr->u.s_val = dm_pool_strdup(rh->mem,
+							      field->sort_value);
+		} else {
+			attr->is_string = 0;
+			attr->u.n_val = *(const uint64_t *)field->sort_value;
+		}
+		dm_list_add(&attr_list->attrs, &attr->list);
+	}
+	return attr_list;
+}
+
+int dm_report_output_attributes(struct dm_report *rh, struct dm_list *list)
+{
+	struct row *row = NULL;
+	struct dm_report_attribute_list_type *attr_list;
+
+	if (dm_list_empty(&rh->rows))
+		return 1;
+
+	if ((rh->flags & RH_SORT_REQUIRED))
+		_sort_rows(rh);
+
+	dm_list_iterate_items(row, &rh->rows) {
+		if (!(attr_list = _output_row_to_attribute_list(rh, row))) {
+			return 0;
+		}
+		dm_list_add(list, &attr_list->list);
+	}
+	return 1;
+}
-- 
1.6.0.6


