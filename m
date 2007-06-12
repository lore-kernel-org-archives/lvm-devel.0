From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jun 2007 21:39:49 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20070612213949.19231.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-12 21:39:49

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Change PV_HANDLE_DEREF to pv_field and add paren's

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/lib/metadata/metadata.c	2007/06/12 21:20:20	1.111
+++ LVM2/lib/metadata/metadata.c	2007/06/12 21:39:49	1.112
@@ -29,10 +29,10 @@
 #include <sys/param.h>
 
 /*
- * FIXME: Check for valid handle before dereferencing member or log error?
+ * FIXME: Check for valid handle before dereferencing field or log error?
  */
-#define PV_HANDLE_DEREF(H, M)				\
-	(((struct physical_volume *)H)->M)
+#define pv_field(handle, field)				\
+	(((struct physical_volume *)(handle))->field)
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd, 
 					const char *pv_name,
@@ -1746,55 +1746,55 @@
  */
 struct id get_pv_id (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, id);
+	return pv_field(pv_handle, id);
 }
 
 const struct format_type *get_pv_format_type (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, fmt);
+	return pv_field(pv_handle, fmt);
 }
 
 struct id get_pv_vgid (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, vgid);
+	return pv_field(pv_handle, vgid);
 }
 
 struct device *get_pv_dev (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, dev);
+	return pv_field(pv_handle, dev);
 }
 
 const char *get_pv_vg_name (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, vg_name);
+	return pv_field(pv_handle, vg_name);
 }
 
 uint64_t get_pv_size(void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, size);
+	return pv_field(pv_handle, size);
 }
 
 uint32_t get_pv_status (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, status);
+	return pv_field(pv_handle, status);
 }
 
 uint32_t get_pv_pe_size (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, pe_size);
+	return pv_field(pv_handle, pe_size);
 }
 
 uint64_t get_pv_pe_start (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, pe_start);
+	return pv_field(pv_handle, pe_start);
 }
 
 uint32_t get_pv_pe_count (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, pe_count);
+	return pv_field(pv_handle, pe_count);
 }
 
 uint32_t get_pv_pe_alloc_count (void *pv_handle)
 {
-	return PV_HANDLE_DEREF(pv_handle, pe_alloc_count);
+	return pv_field(pv_handle, pe_alloc_count);
 }


