From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jul 2007 23:33:13 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070711233313.28767.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-11 23:33:12

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add pv_read_path, a proposed external LVM library function to take a device path and return a PV handle

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.652&r2=1.653
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/WHATS_NEW	2007/07/11 12:07:39	1.652
+++ LVM2/WHATS_NEW	2007/07/11 23:33:12	1.653
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Add pv_read_path external library function.
   Tidy clvmd-openais of redundant bits, and improve an error report.
   Cope with find_seg_by_le() failure in check_lv_segments().
   Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
--- LVM2/lib/metadata/metadata.c	2007/07/02 21:48:30	1.123
+++ LVM2/lib/metadata/metadata.c	2007/07/11 23:33:12	1.124
@@ -72,7 +72,6 @@
 	struct physical_volume *pv;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = fid->fmt->cmd->mem;
-	struct list mdas;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -82,8 +81,7 @@
 		return 0;
 	}
 
-	list_init(&mdas);
-	if (!(pv = _pv_read(fid->fmt->cmd, pv_name, &mdas, NULL, 1))) {
+	if (!(pv = pv_read_path(fid->fmt->cmd, pv_name))) {
 		log_error("%s not identified as an existing physical volume",
 			  pv_name);
 		return 0;
@@ -1842,3 +1840,22 @@
 {
 	return vg->status;
 }
+
+
+/**
+ * pv_read_path - Given a device path return a PV handle if it is a PV
+ * @cmd - handle to the LVM command instance
+ * @pv_name - device path to read for the PV
+ *
+ * Returns:
+ *  NULL - device path does not contain a valid PV
+ *  non-NULL - PV handle corresponding to device path
+ *
+ */
+pv_t *pv_read_path(const struct cmd_context *cmd, const char *pv_name)
+{
+	struct list mdas;
+	
+	list_init(&mdas);
+	return _pv_read(cmd, pv_name, &mdas, NULL, 1);
+}
--- LVM2/lib/metadata/metadata.h	2007/06/19 04:36:12	1.166
+++ LVM2/lib/metadata/metadata.h	2007/07/11 23:33:12	1.167
@@ -638,7 +638,7 @@
 		       char *buffer, size_t len);
 
 /*
- * Gets/Sets for external LVM library
+ * Begin skeleton for external LVM library
  */
 struct id pv_id(pv_t *pv);
 const struct format_type *pv_format_type(pv_t *pv);
@@ -654,4 +654,6 @@
 
 uint32_t vg_status(vg_t *vg);
 
+pv_t *pv_read_path(const struct cmd_context *cmd, const char *pv_name);
+
 #endif


