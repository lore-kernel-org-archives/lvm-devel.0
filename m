From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jul 2010 09:56:12 -0400
Subject: [PATCH 1/4] Add dm_report_get_field_value() function and supporting structure.
In-Reply-To: <1279720575-27485-1-git-send-email-dwysocha@redhat.com>
References: <1279720575-27485-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1279720575-27485-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need to extend the existing reporting infrastructure so that individual
field values may be queried.  This function will be used by lvm2app generic
attribute functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 libdm/libdevmapper.h |   12 ++++++++++++
 libdm/libdm-report.c |   30 ++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index bfd9850..6960c57 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1055,6 +1055,18 @@ struct dm_report_field_type {
 	const char *desc;	/* description of the field */
 };
 
+struct dm_report_field_value_type {
+	unsigned is_string;
+	union {
+		const char *s_val;
+		uint64_t n_val;
+	} u;
+};
+
+int dm_report_get_field_value(struct dm_report *rh,
+			      const char *field_id,
+			      struct dm_report_field_value_type *value);
+
 /*
  * dm_report_init output_flags
  */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2b044b5..4dddcec 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1092,3 +1092,33 @@ int dm_report_output(struct dm_report *rh)
 	else
 		return _output_as_columns(rh);
 }
+
+int dm_report_get_field_value(struct dm_report *rh,
+			      const char *field_id,
+			      struct dm_report_field_value_type *value)
+{
+	struct dm_report_field *field;
+	struct row *row;
+	unsigned found=0;
+
+	dm_list_iterate_items(row, &rh->rows) {
+		if ((field = dm_list_item(dm_list_first(&row->fields),
+					  struct dm_report_field))) {
+			if (!_field_match(rh, field_id, strlen(field_id), 0))
+				continue;
+			found = 1;
+			if ((field->props->flags & DM_REPORT_FIELD_TYPE_MASK) ==
+			    DM_REPORT_FIELD_TYPE_STRING) {
+				value->is_string = 1;
+				value->u.s_val = field->sort_value;
+			} else {
+				value->is_string = 0;
+				value->u.n_val = *(const uint64_t *)field->sort_value;
+			}
+			dm_list_del(&field->list);
+		}
+	}
+
+	return found;
+
+}
-- 
1.6.0.6


