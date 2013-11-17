From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:56 +0000 (UTC)
Subject: master - report: Make dev_size and dev_name columns' type "label".
Message-ID: <20131117222656.9F79860ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b41e916ff8a11e91fade523323db549417f703c
Commit:        6b41e916ff8a11e91fade523323db549417f703c
Parent:        cc633c84cfc82e91e83393271a068a662e7d4678
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 19:05:28 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

report: Make dev_size and dev_name columns' type "label".

---
 lib/report/columns.h |    4 ++--
 lib/report/report.c  |    6 ++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 88a0266..54c46e4 100644
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
index c780ca4..2684392 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -690,10 +690,8 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
-	uint64_t size = pv_dev_size(pv);
-
+	uint64_t size = 0;
+	dev_get_size(*(const struct device **) data, &size);
 	return _size64_disp(rh, mem, field, &size, private);
 }
 


