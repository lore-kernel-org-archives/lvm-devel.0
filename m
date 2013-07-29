From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:22 +0200
Subject: [PATCH 18/20] report: Make PMdaFree into a "label" field.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-18-git-send-email-prockai@redhat.com>
	(sfid-20130729_212452_588047_E757468A)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h | 2 +-
 lib/report/report.c  | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index bbf4832..768920b 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -67,10 +67,10 @@ FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV,
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
-FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
+FIELD(LABEL, label, NUM, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index e024d02..909b245 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -787,11 +787,10 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
+	const struct label *label = (const struct label *) data;
 	uint64_t freespace;
 
-	freespace = pv_mda_free(pv);
+	freespace = lvmcache_info_mda_free(label->info);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
-- 
1.8.2


