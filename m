From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:27 -0400
Subject: [PATCH 4/8] Rename fields in lvm_property_type.
In-Reply-To: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
References: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287460951-338-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Based on review comments, rename a few fields in lvm_property_type.
In particular, change 'is_writeable' to 'is_settable', which is
more intuitive to the intent of the bitfield (a 'set' function
exists for this field/property).  Also, remove the char array
for 'id' - unnecessary as we can just use the string passed in
to do the strcmp.  Finally rename the union members from n_val
to 'integer' and 's_val' to 'string'.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   10 +++++-----
 lib/report/properties.h |   14 ++++++--------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 587f11d..8f9272c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -25,7 +25,7 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
 	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
-	prop->v.n_val = VALUE; \
+	prop->value.integer = VALUE; \
 	return 1; \
 }
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
@@ -40,7 +40,7 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
 	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
-	prop->v.s_val = (char *)VALUE;	\
+	prop->value.string = (char *)VALUE;	\
 	return 1; \
 }
 #define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
@@ -226,12 +226,12 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, writeable) \
-	{ type, #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
+#define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, settable) \
+	{ type, #id, settable, sorttype == STR, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ 0, "", 0, 0, { .n_val = 0 }, _not_implemented_get, _not_implemented_set },
+	{ 0, "", 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
 };
 
 #undef STR
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 7398f2f..db4ae51 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -19,17 +19,15 @@
 #include "metadata.h"
 #include "report.h"
 
-#define LVM_PROPERTY_NAME_LEN DM_REPORT_FIELD_TYPE_ID_LEN
-
 struct lvm_property_type {
 	report_type_t type;
-	char id[LVM_PROPERTY_NAME_LEN];
-	unsigned is_writeable;
-	unsigned is_string;
+	const char *id;
+	unsigned is_settable:1;
+	unsigned is_string:1;
 	union {
-		char *s_val;
-		uint64_t n_val;
-	} v;
+		char *string;
+		uint64_t integer;
+	} value;
 	int (*get) (const void *obj, struct lvm_property_type *prop);
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
-- 
1.7.2.2


