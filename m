From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Dec 2009 17:13:05 +0100
Subject: [PATCH 3/3] Use standard C macro offsetof()
In-Reply-To: <cover.1260547761.git.zkabelac@redhat.com>
References: <cover.1260547761.git.zkabelac@redhat.com>
Message-ID: <0ba24490c569e54cf78d8599769e01d538f3e14e.1260547761.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch uses <stddef.h> defined offsetof() macro and avoids usage
of _dummy union (safe few bytes in bss)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/report.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 54192d5..31e3174 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -24,6 +24,8 @@
 #include "str_list.h"
 #include "lvmcache.h"
 
+#include <stddef.h> /* offsetof() */
+
 struct lvm_report_object {
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -32,17 +34,6 @@ struct lvm_report_object {
 	struct pv_segment *pvseg;
 };
 
-/*
- * For macro use
- */
-static union {
-	struct physical_volume _pv;
-	struct logical_volume _lv;
-	struct volume_group _vg;
-	struct lv_segment _seg;
-	struct pv_segment _pvseg;
-} _dummy;
-
 static char _alloc_policy_char(alloc_policy_t alloc)
 {
 	switch (alloc) {
@@ -1156,9 +1147,17 @@ static const struct dm_report_object_type _report_types[] = {
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, sorttype, (off_t)((uintptr_t)&_dummy._ ## strct.field - (uintptr_t)&_dummy._ ## strct), width, id, head, &_ ## func ## _disp, desc},
+#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) \
+	{type, sorttype, offsetof(type_ ## strct, field), width, \
+	 id, head, &_ ## func ## _disp, desc},
+
+typedef struct physical_volume type_pv;
+typedef struct logical_volume type_lv;
+typedef struct volume_group type_vg;
+typedef struct lv_segment type_seg;
+typedef struct pv_segment type_pvseg;
 
-static struct dm_report_field_type _fields[] = {
+static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
 {0, 0, 0, 0, "", "", NULL, NULL},
 };
-- 
1.6.5.3


