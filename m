From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Oct 2010 07:51:06 -0400
Subject: [PATCH 1/5] Add 'is_integer' flag into internal lvm_property_type.
In-Reply-To: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
References: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287748270-26875-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'is_integer' flag similar to 'is_string'.
Suggested in review by Petr Rockai.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    4 ++--
 lib/report/properties.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index c08ddfd..339fd84 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -227,11 +227,11 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, sorttype == STR, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, sorttype == STR, sorttype == NUM, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ 0, "", 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
+	{ 0, "", 0, 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
 };
 
 #undef STR
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 18e5ab9..054f400 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -24,6 +24,7 @@ struct lvm_property_type {
 	const char *id;
 	unsigned is_settable:1;
 	unsigned is_string:1;
+	unsigned is_integer:1;
 	union {
 		char *string;
 		uint64_t integer;
-- 
1.7.2.2


