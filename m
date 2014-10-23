From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 23 Oct 2014 13:13:31 +0000 (UTC)
Subject: master - report: fix selection on {vg, lv}_permissions fields to properly match selection criteria
Message-ID: <20141023131331.466B660F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9351dca86393f862a6b2c270d5869407a4614d8a
Commit:        9351dca86393f862a6b2c270d5869407a4614d8a
Parent:        4b611bb816eef3e363e005b48b881e933c3de9e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 23 15:03:04 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 23 15:03:04 2014 +0200

report: fix selection on {vg,lv}_permissions fields to properly match selection criteria

There was a bug in value and their synonym definition for these two fields
causing selections on these fields to not work correctly - nothing matched
against vg/lv_permissions fields even if selection criteria should have
matched.

Scenario:
$ lvs -o name,lv_permissions vg
  LV    LPerms
  lvol0 read-only
  lvol1 writeable

Before this patch:

$ lvs -o name,lv_permissions vg -S 'permissions=read-only'
(blank)
$ lvs -o name,lv_permissions vg -S 'permissions=writeable
(blank)

With this patch applied:

$ lvs -o name,lv_permissions vg -S 'permissions=read-only'
  LV    LPerms
  lvol0 read-only
$ lvs -o name,lv_permissions vg -S 'permissions=writeable'
  LV    LPerms
  lvol1 writeable

Also synonyms match correctly now:
$ lvs -o name,lv_permissions vg -S 'permissions=rw'
  LV    LPerms
  lvol1 writeable
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   10 +++++-----
 lib/report/values.h |   14 +++++++-------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2d644c5..38a4d1b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix selection on {vg,lv}_permissions fields to properly match selection criteria.
   Fix lv_permissions reporting to display read-only{-override} instead of blank.
   Fix liblvm2cmd and lvm shell to respect quotes around args in cmd line string.
   Permit extent sizes > 128KB that are not power of 2 with lvm2 format.
diff --git a/lib/report/report.c b/lib/report/report.c
index 3f63e1c..e85c349 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -92,11 +92,11 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 
 #define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
-	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
+	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, value};
 
 #define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, _one64, __VA_ARGS__, _str_yes) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, _zero64, __VA_ARGS__, _str_no)
+	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, &_one64, __VA_ARGS__, _str_yes) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, &_zero64, __VA_ARGS__, _str_no)
 
 #include "values.h"
 
@@ -119,8 +119,8 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 #define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
 #define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, _one64, __VA_ARGS__) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, _zero64, __VA_ARGS__)
+	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, &_one64, __VA_ARGS__) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, &_zero64, __VA_ARGS__)
 
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	#include "values.h"
diff --git a/lib/report/values.h b/lib/report/values.h
index fb368d4..f909ce9 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -54,9 +54,9 @@ FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")
 FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "", "exported")
 FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", RESERVED(number_undef_64), "unmanaged")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", &RESERVED(number_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
 FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "", "initial image sync", "sync")
@@ -76,9 +76,9 @@ FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "", "inactive
 FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
 FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", RESERVED(number_undef_64), "auto")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &RESERVED(number_undef_64), "auto")
 
 /* *INDENT-ON* */


