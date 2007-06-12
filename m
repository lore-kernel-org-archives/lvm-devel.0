From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jun 2007 21:20:21 -0000
Subject: LVM2 lib/metadata/metadata.c lib/metadata/meta ...
Message-ID: <20070612212021.12785.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-12 21:20:20

Modified files:
	lib/metadata   : metadata.c metadata.h 
	.              : WHATS_NEW 

Log message:
	Add get_pv_* functions to return PV fields in prep for external LVM library

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.626&r2=1.627

--- LVM2/lib/metadata/metadata.c	2007/06/11 18:29:30	1.110
+++ LVM2/lib/metadata/metadata.c	2007/06/12 21:20:20	1.111
@@ -28,6 +28,12 @@
 
 #include <sys/param.h>
 
+/*
+ * FIXME: Check for valid handle before dereferencing member or log error?
+ */
+#define PV_HANDLE_DEREF(H, M)				\
+	(((struct physical_volume *)H)->M)
+
 static struct physical_volume *_pv_read(struct cmd_context *cmd, 
 					const char *pv_name,
 					struct list *mdas, 
@@ -1452,7 +1458,21 @@
 	return lvl->lv;
 }
 
-/* FIXME: liblvm todo - make into function that returns handle */
+/**
+ * pv_read - read and return a handle to a physical volume
+ * @cmd: LVM command initiating the pv_read
+ * @pv_name: full device name of the PV, including the path
+ * @mdas: list of metadata areas of the PV
+ * @label_sector: sector number where the PV label is stored on @pv_name
+ * @warnings:
+ *
+ * Returns:
+ *   PV handle - valid pv_name and successful read of the PV, or
+ *   NULL - invalid parameter or error in reading the PV
+ *
+ * Note:
+ *   FIXME - liblvm todo - make into function that returns handle
+ */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct list *mdas, uint64_t *label_sector,
 				int warnings)
@@ -1684,7 +1704,6 @@
 
 /**
  * vg_check_status - check volume group status flags and log error
- *
  * @vg - volume group to check status flags
  * @status_flags - specific status flags to check (e.g. EXPORTED_VG)
  *
@@ -1720,3 +1739,62 @@
 
 	return 1;
 }
+
+
+/*
+ * Gets/Sets for external LVM library
+ */
+struct id get_pv_id (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, id);
+}
+
+const struct format_type *get_pv_format_type (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, fmt);
+}
+
+struct id get_pv_vgid (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, vgid);
+}
+
+struct device *get_pv_dev (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, dev);
+}
+
+const char *get_pv_vg_name (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, vg_name);
+}
+
+uint64_t get_pv_size(void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, size);
+}
+
+uint32_t get_pv_status (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, status);
+}
+
+uint32_t get_pv_pe_size (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, pe_size);
+}
+
+uint64_t get_pv_pe_start (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, pe_start);
+}
+
+uint32_t get_pv_pe_count (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, pe_count);
+}
+
+uint32_t get_pv_pe_alloc_count (void *pv_handle)
+{
+	return PV_HANDLE_DEREF(pv_handle, pe_alloc_count);
+}
--- LVM2/lib/metadata/metadata.h	2007/06/06 19:40:27	1.157
+++ LVM2/lib/metadata/metadata.h	2007/06/12 21:20:20	1.158
@@ -635,4 +635,19 @@
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
+/*
+ * Gets/Sets for external LVM library
+ */
+struct id get_pv_id (void *pv_handle);
+const struct format_type *get_pv_format_type (void *pv_handle);
+struct id get_pv_vgid (void *pv_handle);
+struct device *get_pv_dev (void *pv_handle);
+const char *get_pv_vg_name (void *pv_handle);
+uint64_t get_pv_size(void *pv_handle);
+uint32_t get_pv_status (void *pv_handle);
+uint32_t get_pv_pe_size (void *pv_handle);
+uint64_t get_pv_pe_start (void *pv_handle);
+uint32_t get_pv_pe_count (void *pv_handle);
+uint32_t get_pv_pe_alloc_count (void *pv_handle);
+
 #endif
--- LVM2/WHATS_NEW	2007/06/11 18:29:30	1.626
+++ LVM2/WHATS_NEW	2007/06/12 21:20:20	1.627
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Add get_pv_* functions to return PV members (external LVM library).
   Add wrappers to some functions in preparation for external LVM library.
   Allow vgcfgrestore to list metadata backup files using -f
   Add vg_check_status to consolidate vg status checks and error messages.


