From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Oct 2010 14:49:43 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20101021144943.10854.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-21 14:49:43

Modified files:
	lib/report     : properties.c properties.h 

Log message:
	Rename fields in lvm_property_type.
	
	Based on review comments, rename a few fields in lvm_property_type.
	In particular, change 'is_writeable' to 'is_settable', which is
	more intuitive to the intent of the bitfield (a 'set' function
	exists for this field/property).  Also, remove the char array
	for 'id' - unnecessary as we can just use the string passed in
	to do the strcmp.  Finally rename the union members from n_val
	to 'integer' and 's_val' to 'string'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/report/properties.c	2010/10/21 14:49:31	1.19
+++ LVM2/lib/report/properties.c	2010/10/21 14:49:43	1.20
@@ -25,7 +25,7 @@
 { \
 	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
-	prop->v.n_val = VALUE; \
+	prop->value.integer = VALUE; \
 	return 1; \
 }
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
@@ -40,7 +40,7 @@
 { \
 	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
-	prop->v.s_val = (char *)VALUE;	\
+	prop->value.string = (char *)VALUE;	\
 	return 1; \
 }
 #define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
@@ -226,12 +226,12 @@
 
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
--- LVM2/lib/report/properties.h	2010/09/30 14:09:45	1.2
+++ LVM2/lib/report/properties.h	2010/10/21 14:49:43	1.3
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


