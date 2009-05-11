From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:24 -0400
Subject: [PATCH 11/30] Update devsize_disp() to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-11-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.
Note again we change the field data pointer from 'dev' to 'id' so that
the 'data' pointer value is simply the pointer to the 'pv'.  We can then
call the liblvm 'get' function to retrieve the value.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h         |    2 +-
 lib/report/lvm_object_prop.c |    8 ++++++--
 lib/report/report.c          |    5 ++---
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 7e9c95d..fc79d62 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -79,7 +79,7 @@ FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mappe
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
-FIELD(LABEL, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
+FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, "dev_size", "Size of underlying device in current units.")
 FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index ab8cc9c..27690a6 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -15,6 +15,7 @@
 #include "lib.h"
 #include "metadata-exported.h"
 #include "activate.h"
+#include "device.h"
 
 /**
  * lvm_lv_{get|set}_uuid
@@ -334,8 +335,11 @@ int lvm_pv_set_uuid(pv_t *pv, const char *value)
  */
 uint64_t lvm_pv_get_dev_size(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t size;
+
+	if (!dev_get_size(pv->dev, &size))
+		size = 0;
+	return size;
 }
 int lvm_pv_set_dev_size(pv_t *pv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 85addc9..02e61de 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -832,11 +832,10 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct device *dev = *(const struct device **) data;
+	const struct physical_volume *pv = (const struct physical_volume *) data;
 	uint64_t size;
 
-	if (!dev_get_size(dev, &size))
-		size = 0;
+	size = lvm_pv_get_dev_size(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


