From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Feb 2010 03:21:39 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100214032139.8655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-14 03:21:38

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : columns.h report.c 
	liblvm         : .exported_symbols lvm2app.h lvm_pv.c 

Log message:
	Export lvm_pv_get_size(), lvm_pv_get_free(), lvm_pv_get_dev_size in lvm2app.
	
	We add these exports to show the pv_size and pv_free and dev_size
	fields.
	Fixes rhbz561423.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.313&r2=1.314
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/metadata/metadata-exported.h	2010/02/14 03:21:06	1.130
+++ LVM2/lib/metadata/metadata-exported.h	2010/02/14 03:21:37	1.131
@@ -726,6 +726,9 @@
 const char *pv_vg_name(const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
+uint64_t pv_size_field(const struct physical_volume *pv);
+uint64_t pv_dev_size(const struct physical_volume *pv);
+uint64_t pv_free(const struct physical_volume *pv);
 uint64_t pv_status(const struct physical_volume *pv);
 uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
--- LVM2/lib/metadata/metadata.c	2010/02/03 14:08:40	1.313
+++ LVM2/lib/metadata/metadata.c	2010/02/14 03:21:37	1.314
@@ -3603,6 +3603,38 @@
 	return pv_field(pv, size);
 }
 
+uint64_t pv_dev_size(const struct physical_volume *pv)
+{
+	uint64_t size;
+
+	if (!dev_get_size(pv->dev, &size))
+		size = 0;
+	return size;
+}
+
+uint64_t pv_size_field(const struct physical_volume *pv)
+{
+	uint64_t size;
+
+	if (!pv->pe_count)
+		size = pv->size;
+	else
+		size = (uint64_t) pv->pe_count * pv->pe_size;
+	return size;
+}
+
+uint64_t pv_free(const struct physical_volume *pv)
+{
+	uint64_t freespace;
+
+	if (!pv->pe_count)
+		freespace = pv->size;
+	else
+		freespace = (uint64_t)
+			(pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+	return freespace;
+}
+
 uint64_t pv_status(const struct physical_volume *pv)
 {
 	return pv_field(pv, status);
--- LVM2/lib/report/columns.h	2009/05/21 03:04:53	1.37
+++ LVM2/lib/report/columns.h	2010/02/14 03:21:38	1.38
@@ -78,7 +78,7 @@
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
-FIELD(LABEL, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
+FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, "dev_size", "Size of underlying device in current units.")
 FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
--- LVM2/lib/report/report.c	2010/01/13 01:55:44	1.111
+++ LVM2/lib/report/report.c	2010/02/14 03:21:38	1.112
@@ -767,10 +767,7 @@
 	    (const struct physical_volume *) data;
 	uint64_t freespace;
 
-	if (!pv->pe_count)
-		freespace = pv->size;
-	else
-		freespace = (uint64_t) (pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+	freespace = pv_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -783,10 +780,7 @@
 	    (const struct physical_volume *) data;
 	uint64_t size;
 
-	if (!pv->pe_count)
-		size = pv->size;
-	else
-		size = (uint64_t) pv->pe_count * pv->pe_size;
+	size = pv_size_field(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -795,11 +789,11 @@
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	const struct device *dev = *(const struct device **) data;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
 	uint64_t size;
 
-	if (!dev_get_size(dev, &size))
-		size = 0;
+	size = pv_dev_size(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
--- LVM2/liblvm/.exported_symbols	2009/07/28 13:17:04	1.22
+++ LVM2/liblvm/.exported_symbols	2010/02/14 03:21:38	1.23
@@ -3,6 +3,9 @@
 lvm_quit
 lvm_config_reload
 lvm_config_override
+lvm_pv_get_dev_size
+lvm_pv_get_size
+lvm_pv_get_free
 lvm_pv_get_name
 lvm_pv_get_uuid
 lvm_pv_get_mda_count
--- LVM2/liblvm/lvm2app.h	2009/09/14 19:43:12	1.9
+++ LVM2/liblvm/lvm2app.h	2010/02/14 03:21:38	1.10
@@ -868,6 +868,40 @@
 uint64_t lvm_pv_get_mda_count(const pv_t pv);
 
 /**
+ * Get the current size in bytes of a device underlying a
+ * physical volume.
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Size in bytes.
+ */
+uint64_t lvm_pv_get_dev_size(const pv_t pv);
+
+/**
+ * Get the current size in bytes of a physical volume.
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Size in bytes.
+ */
+uint64_t lvm_pv_get_size(const pv_t pv);
+
+/**
+ * Get the current unallocated space in bytes of a physical volume.
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Free size in bytes.
+ */
+uint64_t lvm_pv_get_free(const pv_t pv);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * NOTE: This function is currently not implemented.
--- LVM2/liblvm/lvm_pv.c	2009/08/13 12:18:15	1.7
+++ LVM2/liblvm/lvm_pv.c	2010/02/14 03:21:38	1.8
@@ -43,6 +43,21 @@
 	return (uint64_t) pv_mda_count(pv);
 }
 
+uint64_t lvm_pv_get_dev_size(const pv_t pv)
+{
+	return (uint64_t) SECTOR_SIZE*pv_dev_size(pv);
+}
+
+uint64_t lvm_pv_get_size(const pv_t pv)
+{
+	return (uint64_t) SECTOR_SIZE*pv_size_field(pv);
+}
+
+uint64_t lvm_pv_get_free(const pv_t pv)
+{
+	return (uint64_t) SECTOR_SIZE*pv_free(pv);
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */


