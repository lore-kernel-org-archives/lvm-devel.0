From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:24 +0200
Subject: [PATCH 20/20] report: Make PV UUID into a "label" type field.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-20-git-send-email-prockai@redhat.com>
	(sfid-20130729_212452_270911_AC26B861)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h   |  2 +-
 lib/report/report.c    | 14 ++++++++++++++
 test/shell/listings.sh |  4 +++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 768920b..8cd0e22 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -66,8 +66,8 @@ FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV,
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
-FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
+FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, label, NUM, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 909b245..07d4731 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -703,6 +703,20 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 	return 1;
 }
 
+static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+		        struct dm_report_field *field,
+		        const void *data, void *private __attribute__((unused)))
+{
+	const struct label *label = (const struct label *) data;
+	char *repstr = NULL;
+
+	if (!(repstr = id_format_and_copy(mem, label->dev->pvid)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, NULL);
+	return 1;
+}
+
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 8b9d082..af4d8a0 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -17,7 +17,7 @@
 
 aux prepare_devs 5
 
-pvcreate "$dev1"
+pvcreate --uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE --norestorefile "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 pvcreate "$dev4"
@@ -31,6 +31,8 @@ test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l)
 
 vgcreate $vg $(cat DEVICES)
 
+check pv_field $dev1 pv_uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
+
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
 pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
 for I in "$dev2" "$dev3" "$dev5"; do
-- 
1.8.2


