From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:00 +0000 (UTC)
Subject: master - report: Adapt _pvfmt_disp to label-based reporting.
Message-ID: <20131117222700.C9D8360E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b07fb3a6415215bf7e6128516a210b07376753dc
Commit:        b07fb3a6415215bf7e6128516a210b07376753dc
Parent:        7e33f50cea7a7240d81ffdec3f8b0c6a1976fce3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 16:00:40 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:04 2013 +0100

report: Adapt _pvfmt_disp to label-based reporting.

---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |   12 +++++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 54c46e4..27f4d7f 100644
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
index f304157..94e5230 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -181,13 +181,15 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
+	const struct label *l =
+	    (const struct label *) data;
 
-	if (pv->fmt)
-		return _string_disp(rh, mem, field, &pv->fmt->name, private);
+	if (!l->labeller->fmt) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
 
-	return _field_set_value(field, "", NULL);
+	return _string_disp(rh, mem, field, &l->labeller->fmt->name, private);
 }
 
 static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),


