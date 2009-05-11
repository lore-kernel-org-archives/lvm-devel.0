From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:18 -0400
Subject: [PATCH 05/30] Modify lv_major and lv_minor fields to call liblvm 'get' functions.
In-Reply-To: <1242046903-15133-5-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We'd like to call liblvm 'get' functions from the reporting commands in
all cases.  This allows for nice code re-use, as well as free testing.
In the case of simple fields that are dereferences, we must modify the
'disp' function from a generic one (e.g. _int32_disp()) to a specific one.
The reason for this is that the generic one relies on the dereference of
the base object pointer + field data value, which is done in libdm.
If we call the liblvm 'get' functions, the dereference is done in there.
So for each field, we remove the generic "int32" disp function and replace
it with a specific one.  Note that we change the data pointer argument to
the FIELD macro to 'lvid', which makes the base + offset calculation in
libdm yield the pointer to the object for the value of 'data' pointer
being passed into the 'disp' function.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h |    4 ++--
 lib/report/report.c  |   32 +++++++++++++++++++++++++-------
 2 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index d1dbc1c..60a9bfb 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -59,8 +59,8 @@
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier.")
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name", "Name.  LVs created for internal use are enclosed in brackets.")
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.")
-FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.")
-FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor", "Persistent minor number or -1 if not persistent.")
+FIELD(LVS, lv, NUM, "Maj", lvid, 3, lvmajor, "lv_major", "Persistent major number or -1 if not persistent.")
+FIELD(LVS, lv, NUM, "Min", lvid, 3, lvminor, "lv_minor", "Persistent minor number or -1 if not persistent.")
 FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, "lv_read_ahead", "Read ahead setting in current units.")
 FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assigned major number or -1 if LV is not active.")
 FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.")
diff --git a/lib/report/report.c b/lib/report/report.c
index 6865c20..e43f9b4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -247,6 +247,31 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &pv->fmt->name, private);
 }
 
+
+static int _lvmajor_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+			 struct dm_report_field *field,
+			 const void *data, void *private __attribute((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int32_t value;
+
+	value = lvm_lv_get_major(lv);
+	return dm_report_field_int32(rh, field, &value);
+}
+
+
+static int _lvminor_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
+			 struct dm_report_field *field,
+			 const void *data, void *private __attribute((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int32_t value;
+
+	value = lvm_lv_get_minor(lv);
+	return dm_report_field_int32(rh, field, &value);
+}
+
+
 static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute((unused)))
@@ -843,13 +868,6 @@ static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((u
 	return dm_report_field_uint32(rh, field, data);
 }
 
-static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
-		       struct dm_report_field *field,
-		       const void *data, void *private __attribute((unused)))
-{
-	return dm_report_field_int32(rh, field, data);
-}
-
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
-- 
1.6.0.6


