From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:17 +0000 (UTC)
Subject: master - report: Convert pv_mda_size to a type "label" field.
Message-ID: <20131117222717.68C1961327@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71b6565529028fcc075c52595fde380c96065cc9
Commit:        71b6565529028fcc075c52595fde380c96065cc9
Parent:        14ffc9d4df952346ce4338939b3ed869b8b491b4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 17 21:04:07 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

report: Convert pv_mda_size to a type "label" field.

---
 lib/report/columns.h         |    2 +-
 lib/report/report.c          |    5 ++---
 test/shell/pvcreate-usage.sh |    1 +
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0617605..93b5575 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -71,7 +71,7 @@ FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifie
 FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, label, NUM, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
-FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
+FIELD(LABEL, label, NUM, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index e4ad2c3..9cb2298 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -820,9 +820,8 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	const struct physical_volume *pv =
-	    (const struct physical_volume *) data;
-	uint64_t min_mda_size = pv_mda_size(pv);
+	const struct label *label = (const struct label *) data;
+	uint64_t min_mda_size = lvmcache_smallest_mda_size(label->info);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index c78e4bd..251746d 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -34,6 +34,7 @@ pvremove "$dev1"
 pvcreate --metadatasize 512k "$dev1"
 pvcreate --metadatasize 96k "$dev2"
 vgcreate $vg "$dev1" "$dev2"
+pvs -o +pv_mda_size
 check compare_fields vgs $vg vg_mda_size pvs "$dev2" pv_mda_size
 vgremove $vg
 


