From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 19 Dec 2014 08:23:30 +0000 (UTC)
Subject: master - libdm: report: add more comments about helper macros to get reserved values
Message-ID: <20141219082330.54F47612BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e0ed83bc8103d36efe0e2dcdfd4b5ad5fd822a8
Commit:        3e0ed83bc8103d36efe0e2dcdfd4b5ad5fd822a8
Parent:        57af48d734f1f7aa985424a1e11287a0975077b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 19 09:17:16 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 19 09:23:05 2014 +0100

libdm: report: add more comments about helper macros to get reserved values

Since GET_FIELD_RESERVED_VALUE always returns a pointer, don't reference
it with "&" when used - we already have that pointer value (this is an
addendum to recent commit 028ff309472834e82fe4b849ea4c243feb5098b9).

Only GET_TYPE_RESERVED_VALUE needs to be referenced with "&" as it
returns directly the value of that type.
---
 lib/report/report.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 818e3fd..d0351f7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -63,6 +63,23 @@ static const char _str_unknown[] = "unknown";
 static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 
 /*
+ * Get type reserved value - the value returned is the direct value of that type.
+ */
+#define GET_TYPE_RESERVED_VALUE(id) _reserved_ ## id
+
+/*
+ * Get field reserved value - the value returned is always a pointer (const void *).
+ */
+#define GET_FIELD_RESERVED_VALUE(id) _reserved_ ## id.value
+
+/*
+ * Get first name assigned to the reserved value - this is the one that
+ * should be reported/displayed. All the other names assigned for the reserved
+ * value are synonyms recognized in selection criteria.
+ */
+#define GET_FIRST_RESERVED_NAME(id) _reserved_ ## id ## _names[0]
+
+/*
  * Reserved values and their assigned names.
  * The first name is the one that is also used for reporting.
  * All names listed are synonyms recognized in selection criteria.
@@ -76,10 +93,6 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_y' (for 1)
  * 		- 'reserved_value_id_n' (for 0)
  */
-#define GET_TYPE_RESERVED_VALUE(id) _reserved_ ## id
-#define GET_FIELD_RESERVED_VALUE(id) _reserved_ ## id.value
-#define GET_FIRST_RESERVED_NAME(id) _reserved_ ## id ## _names[0]
-
 #define NUM uint64_t
 
 #define TYPE_RESERVED_VALUE(type, id, desc, value, ...) \
@@ -721,7 +734,7 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_read_ahead_auto),
-					&GET_FIELD_RESERVED_VALUE(lv_read_ahead_auto));
+					GET_FIELD_RESERVED_VALUE(lv_read_ahead_auto));
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -1021,7 +1034,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(vg_mda_copies_unmanaged),
-					&GET_FIELD_RESERVED_VALUE(vg_mda_copies_unmanaged));
+					GET_FIELD_RESERVED_VALUE(vg_mda_copies_unmanaged));
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }


