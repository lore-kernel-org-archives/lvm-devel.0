From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  5 May 2015 16:34:15 -0500
Subject: [PATCH 1/5] lvm2app: Add signed numerical property values
In-Reply-To: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
References: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
Message-ID: <1430861659-2755-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently lvm2app properties have the following structure:

typedef struct lvm_property_value {
        uint32_t is_settable:1;
        uint32_t is_string:1;
        uint32_t is_integer:1;
        uint32_t is_valid:1;
        uint32_t padding:28;
        union {
                const char *string;
                uint64_t integer;
        } value;
} lvm_property_value_t;

which assumes that numerical values were in the range of 0 to 2**64-1.  However,
some of the properties were 'signed', like LV major/minor numbers and some
reserved values for properties that represent percentages.  Thus when the
values were retrieved they were in two's complement notation.  So for a -1
major number the API user would get a value of 18446744073709551615.  The
API user could cast the returned value to an int64_t to handle this, but that
requires the API developer to look at the source code and determine when it
should be done.

This change modifies the return property structure to:

typedef struct lvm_property_value {
        uint32_t is_settable:1;
        uint32_t is_string:1;
        uint32_t is_integer:1;
        uint32_t is_valid:1;
        uint32_t is_signed:1;
        uint32_t padding:27;
        union {
                const char *string;
                uint64_t integer;
                int64_t signed_integer;
        } value;
} lvm_property_value_t;

With this addition the API user can interrogate that the value is numerical,
(is_integer = 1) and subsequently check if it's signed (is_signed = 1) too.
If signed, then the API developer should use the union's signed_integer to
avoid casting.

This change maintains backwards compatibility as the structure size remains
unchanged and integer value remains unchanged.  Only the additional bit
taken from the pad is utilized.

Bugzilla reference:
https://bugzilla.redhat.com/show_bug.cgi?id=838257

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/properties/prop_common.h | 5 ++++-
 lib/report/columns.h         | 8 ++++----
 lib/report/properties.c      | 3 ++-
 lib/report/report.c          | 2 ++
 liblvm/lvm2app.h             | 4 +++-
 liblvm/lvm_misc.c            | 1 +
 liblvm/lvm_prop.c            | 2 +-
 7 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index d7d01af..0b1678d 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -26,9 +26,11 @@ struct lvm_property_type {
 	unsigned is_settable:1;
 	unsigned is_string:1;
 	unsigned is_integer:1;
+	unsigned is_signed:1;
 	union {
 		const char *string;
 		uint64_t integer;
+		int64_t signed_integer;
 	} value;
 	int (*get) (const void *obj, struct lvm_property_type *prop);
 	int (*set) (void *obj, struct lvm_property_type *prop);
@@ -126,9 +128,10 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define SIZ 4
 #define PCT 5
 #define STR_LIST 6
+#define SNUM 7              /* Signed Number */
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT) || (field_type == SNUM)), ((field_type == SNUM) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 #endif
diff --git a/lib/report/columns.h b/lib/report/columns.h
index cf84295..06282c5 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -56,8 +56,8 @@ FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the
 FIELD(LVS, lv, BIN, "ActLocal", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
 FIELD(LVS, lv, BIN, "ActRemote", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
 FIELD(LVS, lv, BIN, "ActExcl", lvid, 10, lvactiveexclusively, lv_active_exclusively, "Set if the LV is active exclusively.", 0)
-FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
-FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
+FIELD(LVS, lv, SNUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
+FIELD(LVS, lv, SNUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
 FIELD(LVS, lv, SIZ, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
 FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin and cache pools, the size of the LV that holds the metadata.", 0)
@@ -88,8 +88,8 @@ FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV,
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
-FIELD(LVSINFO, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
-FIELD(LVSINFO, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
+FIELD(LVSINFO, lv, SNUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
+FIELD(LVSINFO, lv, SNUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
 FIELD(LVSINFO, lv, STR, "LPerms", lvid, 8, lvpermissions, lv_permissions, "LV permissions.", 0)
 FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Set if LV is suspended.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ea70690..b0a91a7 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -462,7 +462,7 @@ GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get, prop_not_implemented_set },
+	{ 0, "", 0, 0, 0, 0, { .integer = 0 }, prop_not_implemented_get, prop_not_implemented_set },
 };
 
 #undef STR
@@ -471,6 +471,7 @@ struct lvm_property_type _properties[] = {
 #undef SIZ
 #undef PCT
 #undef STR_LIST
+#undef SNUM
 #undef FIELD
 
 int lvseg_get_property(const struct lv_segment *lvseg,
diff --git a/lib/report/report.c b/lib/report/report.c
index 500bf2b..a107669 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2057,6 +2057,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 #define SIZ DM_REPORT_FIELD_TYPE_SIZE
 #define PCT DM_REPORT_FIELD_TYPE_PERCENT
 #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
+#define SNUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
 	{type, sorttype, offsetof(type_ ## strct, field), width, \
 	 #id, head, &_ ## func ## _disp, desc},
@@ -2085,6 +2086,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 #undef BIN
 #undef SIZ
 #undef STR_LIST
+#undef SNUM
 #undef FIELD
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 3692f9a..1a5bc08 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -231,10 +231,12 @@ typedef struct lvm_property_value {
 	uint32_t is_string:1;
 	uint32_t is_integer:1;
 	uint32_t is_valid:1;
-	uint32_t padding:28;
+	uint32_t is_signed:1;
+	uint32_t padding:27;
 	union {
 		const char *string;
 		uint64_t integer;
+		int64_t signed_integer;
 	} value;
 } lvm_property_value_t;
 
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index ff26cdf..431d354 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -88,6 +88,7 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
 	v.is_integer = prop.is_integer;
+	v.is_signed = prop.is_signed;
 	if (v.is_string)
 		v.value.string = prop.value.string;
 	if (v.is_integer)
diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
index 79ed113..4ea868d 100644
--- a/liblvm/lvm_prop.c
+++ b/liblvm/lvm_prop.c
@@ -41,7 +41,7 @@ SET_PVCREATEPARAMS_NUM_PROPERTY_FN(zero, pvcp->zero)
 
 struct lvm_property_type _lib_properties[] = {
 #include "lvm_prop_fields.h"
-	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get,
+	{ 0, "", 0, 0, 0, 0, { .integer = 0 }, prop_not_implemented_get,
 			prop_not_implemented_set },
 };
 
-- 
1.8.2.1


