From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 22:54:52 -0500
Subject: [PATCH 2/3] Export lvm_pv_get_size(), lvm_pv_get_free(), lvm_pv_get_dev_size in lvm2app.
In-Reply-To: <1266033293-14492-1-git-send-email-dwysocha@redhat.com>
References: <1266033293-14492-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1266033293-14492-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We add these exports to show the pv_size and pv_free and dev_size
fields.
Fixes rhbz561423.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/metadata.c          |   32 ++++++++++++++++++++++++++++++++
 lib/report/columns.h             |    2 +-
 lib/report/report.c              |   16 +++++-----------
 liblvm/.exported_symbols         |    3 +++
 liblvm/lvm2app.h                 |   34 ++++++++++++++++++++++++++++++++++
 liblvm/lvm_pv.c                  |   15 +++++++++++++++
 7 files changed, 93 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index acb7b52..164ce36 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -726,6 +726,9 @@ struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
+uint64_t pv_size_field(const struct physical_volume *pv);
+uint64_t pv_dev_size(const struct physical_volume *pv);
+uint64_t pv_free(const struct physical_volume *pv);
 uint64_t pv_status(const struct physical_volume *pv);
 uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 28c7c47..b3b3778 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3603,6 +3603,38 @@ uint64_t pv_size(const struct physical_volume *pv)
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
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 49ebab4..1414971 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -78,7 +78,7 @@ FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mappe
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
-FIELD(LABEL, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
+FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, "dev_size", "Size of underlying device in current units.")
 FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
 FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
 FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
diff --git a/lib/report/report.c b/lib/report/report.c
index 2cceedd..6bcab55 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -767,10 +767,7 @@ static int _pvfree_disp(struct dm_report *rh, struct dm_pool *mem,
 	    (const struct physical_volume *) data;
 	uint64_t freespace;
 
-	if (!pv->pe_count)
-		freespace = pv->size;
-	else
-		freespace = (uint64_t) (pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+	freespace = pv_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -783,10 +780,7 @@ static int _pvsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	    (const struct physical_volume *) data;
 	uint64_t size;
 
-	if (!pv->pe_count)
-		size = pv->size;
-	else
-		size = (uint64_t) pv->pe_count * pv->pe_size;
+	size = pv_size_field(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -795,11 +789,11 @@ static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
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
diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 1e6d4c4..c184a88 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -3,6 +3,9 @@ lvm_init
 lvm_quit
 lvm_config_reload
 lvm_config_override
+lvm_pv_get_dev_size
+lvm_pv_get_size
+lvm_pv_get_free
 lvm_pv_get_name
 lvm_pv_get_uuid
 lvm_pv_get_mda_count
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index aeadd74..442a591 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -868,6 +868,40 @@ char *lvm_pv_get_name(const pv_t pv);
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
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 8548597..a97f26f 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -43,6 +43,21 @@ uint64_t lvm_pv_get_mda_count(const pv_t pv)
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
-- 
1.6.0.6


