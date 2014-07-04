From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:18 +0000 (UTC)
Subject: master - refactor: use new LVSINFO report type for lv_kernel_{major, minor, read_ahead} field
Message-ID: <20140704140018.98FEB60ED6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b9b1f23199edb7e02230481a5e53ac1fa548384
Commit:        4b9b1f23199edb7e02230481a5e53ac1fa548384
Parent:        ecb2be5d1642aa0142d216f9e52f64fd3e8c3fc8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 2 14:31:39 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

refactor: use new LVSINFO report type for lv_kernel_{major,minor,read_ahead} field

---
 lib/report/columns.h |    7 ++++---
 lib/report/report.c  |   21 +++++++++------------
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 8d42387..96c30d4 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -39,9 +39,6 @@ FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
-FIELD(LVS, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
 FIELD(LVS, lv, SIZ, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
 FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
@@ -69,6 +66,10 @@ FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV,
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
+FIELD(LVSINFO, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
+FIELD(LVSINFO, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
+FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
+
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, SIZ, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index eb4c5ac..27d2de7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -195,11 +195,10 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	int major;
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
-	if ((major = lv_kernel_major(lv)) >= 0)
-		return dm_report_field_int(rh, field, &major);
+	if (lvi->info && lvi->info->exists && lvi->info->major >= 0)
+		return dm_report_field_int(rh, field, &lvi->info->major);
 
 	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 }
@@ -208,11 +207,10 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	int minor;
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
-	if ((minor = lv_kernel_minor(lv)) >= 0)
-		return dm_report_field_int(rh, field, &minor);
+	if (lvi->info && lvi->info->exists && lvi->info->minor >= 0)
+		return dm_report_field_int(rh, field, &lvi->info->minor);
 
 	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 }
@@ -549,13 +547,12 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data,
 			      void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	uint32_t read_ahead = lv_kernel_read_ahead(lv);
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
-	if (read_ahead == UINT32_MAX)
+	if (!lvi->info || !lvi->info->exists)
 		return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 
-	return _size32_disp(rh, mem, field, &read_ahead, private);
+	return _size32_disp(rh, mem, field, &lvi->info->read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,


