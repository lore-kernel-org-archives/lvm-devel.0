From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:21 -0400
Subject: [PATCH 08/30] Update lv_size field - create lvsize_disp() and call liblvm 'get' function.
In-Reply-To: <1242046903-15133-8-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |   12 ++++++++++++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 60a9bfb..7e9c95d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -65,7 +65,7 @@ FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, "lv_read_ahead", "Read ahead
 FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assigned major number or -1 if LV is not active.")
 FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.")
 FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, "lv_kernel_read_ahead", "Currently-in-use read ahead setting in current units.")
-FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.")
+FIELD(LVS, lv, NUM, "LSize", lvid, 5, lvsize, "lv_size", "Size of LV in current units.")
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.")
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV.")
 FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, "origin_size", "For snapshots, the size of the origin device of this LV.")
diff --git a/lib/report/report.c b/lib/report/report.c
index 3bd4c45..cc522c4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -706,6 +706,18 @@ static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
+static int _lvsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t size;
+
+	size = lvm_lv_get_size(lv);
+
+	return _size64_disp(rh, mem, field, &size, private);
+}
+
 static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private)
-- 
1.6.0.6


