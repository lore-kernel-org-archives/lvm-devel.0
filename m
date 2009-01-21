From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jan 2009 16:52:48 -0500
Subject: [PATCH 2/2] Add vg_get_attr_value() libLVM API to query to value of a VG attribute.
In-Reply-To: <1232574768-15280-2-git-send-email-dwysocha@redhat.com>
References: <1232488651-12439-1-git-send-email-dwysocha@redhat.com>
	<1232574768-15280-1-git-send-email-dwysocha@redhat.com>
	<1232574768-15280-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1232574768-15280-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This API may be used independently to query the value of a VG attribute,
provided the name of the attribute is known.  If the name of the attribute(s)
are unknown, the previous API, vg_get_attr_list(), may be used.

Simple test code included.  Run as follows:
./test
lvm> vg_read vg1
Success reading vg vg1
lvm> vg_get_attr_list
VG attribute names:
vg_fmt
vg_uuid
vg_name
vg_attr
vg_size
vg_free
vg_sysid
vg_extent_size
vg_extent_count
vg_free_count
max_lv
max_pv
pv_count
lv_count
snap_count
vg_seqno
vg_tags
vg_mda_count
vg_mda_free
vg_mda_size
lvm> vg_get_attr_value vg_name pv_count
vg_name = vg1
pv_count = 3

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    2 +
 lib/report/report.c     |   28 +++++++++++++++++++++++++++
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |   12 +++++++++++
 libdm/libdm-report.c    |   29 ++++++++++++++++++++++++++++
 test/api/test.c         |   48 ++++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 115 insertions(+), 5 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 6689b37..4402eeb 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -66,4 +66,6 @@ vg_t *vg_open_for_read(struct cmd_context *cmd, const char *vg_name);
  */
 int vg_get_attr_list(vg_t *vg, struct dm_list *list);
 
+int vg_get_attr_value(vg_t *vg, const char *attr_name,
+		      struct dm_report_field_value_type *value);
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index edd3453..6d9e83b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1219,3 +1219,31 @@ int vg_get_attr_list(vg_t *vg, struct dm_list *list)
 	dm_report_free(rh);
 	return 1;
 }
+
+/*
+ * Get the value of the VG attribute 'attr_name'.
+ */
+int vg_get_attr_value(vg_t *vg, const char *attr_name,
+		      struct dm_report_field_value_type *value)
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
index a9db211..625e212 100644
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
diff --git a/test/api/test.c b/test/api/test.c
index 04177d7..c6d9797 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -52,14 +52,33 @@ static void _show_help(void)
 {
 	printf("'vg_read vgname': Issue a vg_read() API call on VG 'vgname'\n");
 	printf("'vg_get_attr_list': Issue vg_get_attr_list() API; must follow vg_read\n");
+	printf("'vg_get_attr_value [attr_name]': Issue vg_get_attr_value() API; must follow vg_read\n");
 	printf("'quit': exit the program\n");
 }
 
+static void get_and_print_vg_attr(vg_t *vg, const char *name)
+{
+	struct dm_report_field_value_type value;
+
+	if (!vg_get_attr_value(vg, name, &value)) {
+		printf("Error reading vg attribute %s value \n",
+		       name);
+		return;
+	}
+	if (value.is_string)
+		printf("%s = %s\n", name, value.u.s_val);
+	else
+		printf("%s = %llu\n", name, (unsigned long long)value.u.n_val);
+}
+
 int lvmapi_test_shell(void *h)
 {
 	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 	vg_t *vg = NULL;
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	int i;
 
 	while (1) {
 		free(input);
@@ -96,27 +115,46 @@ int lvmapi_test_shell(void *h)
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
 			_show_help();
 		} else if (!strcmp(argv[0], "vg_read")) {
+			if (argc < 2) {
+				printf ("Please enter vg_name\n");
+				continue;
+			}
 			if (!(vg = vg_open_for_read(h, argv[1])))
 				printf("Error reading vg %s\n", argv[1]);
 			else
 				printf("Success reading vg %s\n", argv[1]);
 		} else if (!strcmp(argv[0], "vg_get_attr_list")) {
-			struct dm_list list;
-			struct dm_report_field_ids_type *field_id;
 			if (!vg) {
 				printf("Run vg_read first\n");
 				continue;
 			}
-			if (!vg_get_attr_list(vg, &list)) {
+			if (!vg_get_attr_list(vg, &fields)) {
 				printf("Error reading vg attribute list\n");
 				continue;
 			}
 			printf("VG attribute names:\n");
-			dm_list_iterate_items(field_id, &list) {
-				printf("%s\n", field_id->id);
+			dm_list_iterate_items(field, &fields) {
+				printf("%s\n", field->id);
+			}
+		} else if (!strcmp(argv[0], "vg_get_attr_value")) {
+			if (!vg) {
+				printf("Run vg_read first\n");
+				continue;
+			}
+			if (argc > 1) {
+				for (i=1; i<argc; i++)
+					get_and_print_vg_attr(vg, argv[i]);
+				continue;
+			}
+			dm_list_iterate_items(field, &fields) {
+				get_and_print_vg_attr(vg, field->id);
 			}
 		}
 	}
+#if 0	
+	if (vg)
+		unlock_vg(vg);
+#endif	
 
 	free(input);
 	return 0;
-- 
1.5.5.1


