From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:02 +0000 (UTC)
Subject: master - report: Make PMdaFree into a "label" field.
Message-ID: <20131117222702.DA9EF60E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99214c51eb815806c4a4a4711fa3562546479751
Commit:        99214c51eb815806c4a4a4711fa3562546479751
Parent:        b07fb3a6415215bf7e6128516a210b07376753dc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 19:14:10 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

report: Make PMdaFree into a "label" field.

---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 27f4d7f..8a87d11 100644
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
index 94e5230..3f716b5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -791,9 +791,8 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
-	uint64_t freespace = pv_mda_free(pv);
+	const struct label *label = (const struct label *) data;
+	uint64_t freespace = lvmcache_info_mda_free(label->info);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }


