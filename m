From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Mar 2016 00:15:36 +0000 (UTC)
Subject: master - report: Add pv_major, pv_minor to reports.
Message-ID: <20160322001536.D601A60AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e69e81388dd84598a37b8b77c17c393bf570cf75
Commit:        e69e81388dd84598a37b8b77c17c393bf570cf75
Parent:        16b127259761da212bc7ba6ab3c95b42fe0fe276
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 22 00:12:08 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 22 00:12:08 2016 +0000

report: Add pv_major, pv_minor to reports.

---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    2 ++
 lib/report/properties.c |    4 ++++
 lib/report/report.c     |   18 ++++++++++++++++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f81021..029405d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.148 - 
 ==================================
+  Add pv_major and pv_minor report fields.
   Detect and warn about mismatch between devices used and assumed for an LV.
 
 Version 2.02.147 - 19th March 2016
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 4439047..7f5e11d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -126,6 +126,8 @@ FIELD(LABEL, label, STR, "Fmt", type, 0, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, SIZ, "DevSize", dev, 0, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
+FIELD(LABEL, label, STR, "Maj", dev, 0, devmajor, pv_major, "Device major number.", 0)
+FIELD(LABEL, label, STR, "Min", dev, 0, devminor, pv_minor, "Device minor number.", 0)
 FIELD(LABEL, label, SIZ, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, label, SIZ, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 FIELD(LABEL, label, NUM, "PExtVsn", type, 0, pvextvsn, pv_ext_vsn, "PV header extension version.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 62c81b9..7c9bb0c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -194,6 +194,10 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_ext_vsn_set prop_not_implemented_set
 #define _pv_in_use_get prop_not_implemented_get
 #define _pv_in_use_set prop_not_implemented_set
+#define _pv_major_get prop_not_implemented_set
+#define _pv_major_set prop_not_implemented_set
+#define _pv_minor_get prop_not_implemented_set
+#define _pv_minor_set prop_not_implemented_set
 
 #define _vg_permissions_set prop_not_implemented_set
 #define _vg_permissions_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 7070092..5009ecc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1289,6 +1289,24 @@ static int _uuid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
+static int _devminor_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	int devminor = (int) MINOR((*(const struct device * const *) data)->dev);
+
+	return dm_report_field_int(rh, field, &devminor);
+}
+
+static int _devmajor_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	int devmajor = (int) MAJOR((*(const struct device * const *) data)->dev);
+
+	return dm_report_field_int(rh, field, &devmajor);
+}
+
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private)


