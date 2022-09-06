From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue,  6 Sep 2022 13:51:12 +0000 (GMT)
Subject: main - report: fix lv_active column type from STR to BIN
Message-ID: <20220906135112.E6E1A38515C3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=973d0bd5b7110ad16fe26362c2586c961591ba4a
Commit:        973d0bd5b7110ad16fe26362c2586c961591ba4a
Parent:        0eebd9d7802c724ee71b6ebb80940ea6007f9c7a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 6 14:40:06 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 6 15:49:27 2022 +0200

report: fix lv_active column type from STR to BIN

Fix lv_active to be of BIN type instead of STR. This allows lv_active to
follow the report/binary_values_as_numeric setting as well as --binary
cmd line switch. Also, it makes it possible to use -S|--select with
either textual or numeric representation of the value, like 'lvs -S
active=active' but also 'lvs -S active=1'.
---
 WHATS_NEW            |  1 +
 lib/report/columns.h |  2 +-
 lib/report/report.c  | 13 +++++++------
 lib/report/values.h  |  1 +
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 293c034af..e29ec7066 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Fix lv_active field type to binary so --select and --binary applies properly.
   Switch to use mallinfo2 and use it only with glibc.
   Error out in lvm shell if using a cmd argument not supported in the shell.
   Fix lvm shell's lastlog command to report previous pre-command failures.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index d702635d2..8719a7e7d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -63,7 +63,7 @@ FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, BIN, "AutoAct", lvid, 0, lvautoactivation, lv_autoactivation, "Set if LV autoactivation is enabled.", 0)
 FIELD(LVS, lv, STR, "WhenFull", lvid, 15, lvwhenfull, lv_when_full, "For thin pools, behavior when full.", 0)
-FIELD(LVS, lv, STR, "Active", lvid, 0, lvactive, lv_active, "Active state of the LV.", 0)
+FIELD(LVS, lv, BIN, "Active", lvid, 0, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, BIN, "ActLocal", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
 FIELD(LVS, lv, BIN, "ActRemote", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
 FIELD(LVS, lv, BIN, "ActExcl", lvid, 10, lvactiveexclusively, lv_active_exclusively, "Set if the LV is active exclusively.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index f666ca842..9172c1f0e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3808,14 +3808,15 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
-	char *repstr;
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int active;
 
-	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data))) {
-		log_error("Failed to allocate buffer for active.");
-		return 0;
-	}
+	if (!activation())
+		return _binary_undef_disp(rh, mem, field, private);
 
-	return _field_set_value(field, repstr, NULL);
+	active = lv_is_active(lv);
+
+	return _binary_disp(rh, mem, field, active, GET_FIRST_RESERVED_NAME(lv_active_y), private);
 }
 
 static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/lib/report/values.h b/lib/report/values.h
index 71175fa6e..3efe2b83f 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -99,6 +99,7 @@ FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "", "merging")
 FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "", "converting")
 FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "", "allocation locked", "locked")
 FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "", "fixed minor", "fixed")
+FIELD_RESERVED_BINARY_VALUE(lv_active, lv_active, "", "active")
 FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "", "active locally", "active", "locally")
 FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "", "active remotely", "active", "remotely")
 FIELD_RESERVED_BINARY_VALUE(lv_active_exclusively, lv_active_exclusively, "", "active exclusively", "active", "exclusively")

