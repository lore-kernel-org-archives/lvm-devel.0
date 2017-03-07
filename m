From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 12:59:41 -0500
Subject: master - report: display proper LV size for reshapable RaidLVs
Message-ID: <201703071759.v27Hxfj1029187@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4b30b0daef3bac7f775dff29c21ac47fe5d82a7
Commit:        f4b30b0daef3bac7f775dff29c21ac47fe5d82a7
Parent:        43fb4aa69b720301e12a9c0a85e7e778f68f72bf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 18:47:20 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 18:47:20 2017 +0100

report: display proper LV size for reshapable RaidLVs

Subtract reshape space when reporting visible lv_size on RaidLV.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index f723ded..74078f5 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -69,7 +69,7 @@ FIELD(LVS, lv, BIN, "ActExcl", lvid, 10, lvactiveexclusively, lv_active_exclusiv
 FIELD(LVS, lv, SNUM, "Maj", major, 0, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SNUM, "Min", minor, 0, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 0, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
-FIELD(LVS, lv, SIZ, "LSize", size, 0, size64, lv_size, "Size of LV in current units.", 0)
+FIELD(LVS, lv, SIZ, "LSize", lvid, 0, lv_size, lv_size, "Size of LV in current units.", 0)
 FIELD(LVS, lv, SIZ, "MSize", lvid, 0, lvmetadatasize, lv_metadata_size, "For thin and cache pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 0, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 0, origin, origin, "For snapshots and thins, the origin device of this LV.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 1808a2b..e426371 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2296,6 +2296,22 @@ static int _size64_disp(struct dm_report *rh __attribute__((unused)),
 	return _field_set_value(field, repstr, sortval);
 }
 
+static int _lv_size_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_segment *seg = first_seg(lv);
+	uint64_t size = lv->le_count;
+
+	if (!lv_is_raid_image(lv))
+		size -= seg->reshape_len * seg->area_count;
+
+	size *= lv->vg->extent_size;
+
+	return _size64_disp(rh, mem, field, &size, private);
+}
+
 static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))


