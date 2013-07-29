From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:21 +0200
Subject: [PATCH 17/20] report: Adapt _pvfmt_disp to label-based reporting.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-17-git-send-email-prockai@redhat.com>
	(sfid-20130729_212452_438751_D7A49E47)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h | 2 +-
 lib/report/report.c  | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0da3e70..bbf4832 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -66,9 +66,9 @@ FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV,
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
-FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
+FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 912bcde..e024d02 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -143,15 +143,15 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
+	const struct label *l =
+	    (const struct label *) data;
 
-	if (!pv->fmt) {
+	if (!l->labeller->fmt) {
 		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}
 
-	return _string_disp(rh, mem, field, &pv->fmt->name, private);
+	return _string_disp(rh, mem, field, &l->labeller->fmt->name, private);
 }
 
 static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-- 
1.8.2


