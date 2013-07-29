From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:19 +0200
Subject: [PATCH 15/20] report: Make dev_size and dev_name columns' type "label".
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-15-git-send-email-prockai@redhat.com>
	(sfid-20130729_212451_906850_BA4CD69F)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h | 4 ++--
 lib/report/report.c  | 8 ++------
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9bb99d3..0da3e70 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -68,9 +68,9 @@ FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapp
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
-FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
-FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
+FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
+FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 77332a2..6c4caf3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -672,12 +672,8 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
-	uint64_t size;
-
-	size = pv_dev_size(pv);
-
+	uint64_t size = 0;
+	dev_get_size(*(const struct device **) data, &size);
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
-- 
1.8.2


