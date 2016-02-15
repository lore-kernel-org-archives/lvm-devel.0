From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:42 +0000 (UTC)
Subject: master - report: add pv_ext_vsn field to display PV header extension version used
Message-ID: <20160215120842.8FB2260509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f75e42c06cd925d414c1069d6c51e0b50e1934a8
Commit:        f75e42c06cd925d414c1069d6c51e0b50e1934a8
Parent:        e0b141510523bb09e5a784d6e1b30f106e8dbbf3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 17 09:49:08 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

report: add pv_ext_vsn field  to display PV header extension version used

For example:

$ pvs -o pv_name,vg_name,pv_ext_vsn,pv_in_use
  PV         VG     ExtVsn InUse
  /dev/sda               2
  /dev/sdb   vg          2    used
  /dev/vda2  fedora      1    used
---
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   17 +++++++++++++++++
 3 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index e6f8485..7ea7f52 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -122,6 +122,7 @@ FIELD(LABEL, label, SIZ, "DevSize", dev, 7, devsize, dev_size, "Size of underlyi
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
 FIELD(LABEL, label, SIZ, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, label, SIZ, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
+FIELD(LABEL, label, NUM, "PExtVsn", type, 7, pvextvsn, pv_ext_vsn, "PV header extension version.", 0)
 
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
 FIELD(PVS, pv, SIZ, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 118e659..d23e4c9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -190,6 +190,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_exported_get prop_not_implemented_get
 #define _pv_missing_set prop_not_implemented_set
 #define _pv_missing_get prop_not_implemented_get
+#define _pv_ext_vsn_get prop_not_implemented_get
+#define _pv_ext_vsn_set prop_not_implemented_set
 #define _pv_in_use_get prop_not_implemented_get
 #define _pv_in_use_set prop_not_implemented_set
 
diff --git a/lib/report/report.c b/lib/report/report.c
index f7f3775..3f2bd0c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2554,6 +2554,23 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
 
+static int _pvextvsn_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	const struct label *label = (const struct label *) data;
+	struct lvmcache_info *info = label->info;
+	uint32_t ext_version;
+
+	if (info) {
+		ext_version = lvmcache_ext_version(info);
+		return _uint32_disp(rh, mem, field, &ext_version, private);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+
 static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)


