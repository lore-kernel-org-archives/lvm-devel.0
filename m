From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jan 2009 16:52:47 -0500
Subject: [PATCH 1/2] Add vg_get_attr_list() libLVM API to return a list of VG attribute names.
In-Reply-To: <1232574768-15280-1-git-send-email-dwysocha@redhat.com>
References: <1232488651-12439-1-git-send-email-dwysocha@redhat.com>
	<1232574768-15280-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1232574768-15280-2-git-send-email-dwysocha@redhat.com>
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

Main code is in libdm/libdevmapper.h, libdm/libdm-report.c, and
lib/report/report.c.  Other supporting code was added just to get it to
compile and is not the primary focus of this patch.  The test/api/test.c
file allows for a simple test as follows:
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
...

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h                       |   16 ++++++++++++++
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    6 +++++
 lib/misc/lib.h                   |    1 +
 lib/report/report.c              |   28 ++++++++++++++++++++++++
 libdm/.exported_symbols          |    1 +
 libdm/libdevmapper.h             |   12 ++++++++++
 libdm/libdm-report.c             |   27 +++++++++++++++++++++++
 test/api/test.c                  |   43 ++++++++++++++++++++++++++++++++-----
 9 files changed, 129 insertions(+), 7 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index b18cead..6689b37 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -16,6 +16,7 @@
 #define _LIB_LVM2_H
 
 #include <stdint.h>
+#include "libdevmapper.h"
 
 /*
  * Library Initialisation
@@ -50,4 +51,19 @@ void lvm2_destroy(lvm_handle_t h);
  */
 #define lvm2_destroy(X) destroy_toolcontext(X)
 
+/* FIXME: this should be in the create/init routine(s) */
+int init_locking(int type, struct cmd_context *cmd);
+
+struct volume_group;
+typedef struct volume_group vg_t;
+
+/* FIXME: temporary simplistic vg_read interface */
+vg_t *vg_open_for_read(struct cmd_context *cmd, const char *vg_name);
+
+/*
+ * Get a list of VG attributes we can query.
+ * Returns a list of struct dm_report_field_ids_type 
+ */
+int vg_get_attr_list(vg_t *vg, struct dm_list *list);
+
 #endif
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 40ece6f..bf8555f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,11 +22,11 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
+#include "lvm2.h"
 
 struct physical_volume;
 typedef struct physical_volume pv_t;
 struct volume_group;
-typedef struct volume_group vg_t;
 
 struct logical_volume;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a49c4d8..19ba8f3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2461,6 +2461,12 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	return vg;
 }
 
+vg_t *vg_open_for_read(struct cmd_context *cmd, const char *vg_name)
+{
+	return vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,
+				CLUSTERED, 0);
+}
+
 /*
  * Gets/Sets for external LVM library
  */
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 100827d..188f79e 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -31,6 +31,7 @@
 #include "lvm-wrappers.h"
 #include "lvm-types.h"
 #include "util.h"
+#include "lvm2.h"
 
 #ifdef DM
 #  include "dm-logging.h"
diff --git a/lib/report/report.c b/lib/report/report.c
index 8439b2b..edd3453 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1191,3 +1191,31 @@ int report_object(void *handle, struct volume_group *vg,
 
 	return dm_report_object(handle, &obj);
 }
+
+/*
+ * Get a list of attributes for a vg
+ */
+int vg_get_attr_list(vg_t *vg, struct dm_list *list)
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
diff --git a/test/api/test.c b/test/api/test.c
index de53c46..04177d7 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -48,10 +48,18 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(void *h)
+static void _show_help(void)
 {
-	int argc, i;
+	printf("'vg_read vgname': Issue a vg_read() API call on VG 'vgname'\n");
+	printf("'vg_get_attr_list': Issue vg_get_attr_list() API; must follow vg_read\n");
+	printf("'quit': exit the program\n");
+}
+
+int lvmapi_test_shell(void *h)
+{
+	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
+	vg_t *vg = NULL;
 
 	while (1) {
 		free(input);
@@ -86,10 +94,27 @@ static int lvmapi_test_shell(void *h)
 			printf("Exiting.\n");
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
-			printf("No commands defined\n");
-		} else if (!strcmp(argv[0], "scan")) {
-			for (i=1; i < argc; i++)
-				printf("Scan a path!\n");
+			_show_help();
+		} else if (!strcmp(argv[0], "vg_read")) {
+			if (!(vg = vg_open_for_read(h, argv[1])))
+				printf("Error reading vg %s\n", argv[1]);
+			else
+				printf("Success reading vg %s\n", argv[1]);
+		} else if (!strcmp(argv[0], "vg_get_attr_list")) {
+			struct dm_list list;
+			struct dm_report_field_ids_type *field_id;
+			if (!vg) {
+				printf("Run vg_read first\n");
+				continue;
+			}
+			if (!vg_get_attr_list(vg, &list)) {
+				printf("Error reading vg attribute list\n");
+				continue;
+			}
+			printf("VG attribute names:\n");
+			dm_list_iterate_items(field_id, &list) {
+				printf("%s\n", field_id->id);
+			}
 		}
 	}
 
@@ -107,6 +132,12 @@ int main (int argc, char *argv[])
 		return 1;
 	}
 
+	/* FIXME: this needs to go into the create / init routine */
+	if (!init_locking(1, h)) {
+		printf("Locking error\n");
+		return 1;
+	}
+
 	lvmapi_test_shell(h);
 
 	if (h)
-- 
1.5.5.1


