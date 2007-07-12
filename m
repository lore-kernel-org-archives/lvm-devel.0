From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jul 2007 15:38:53 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070712153853.29439.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-12 15:38:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Change pv_read_path to pv_by_path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.654&r2=1.655
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/WHATS_NEW	2007/07/12 05:04:39	1.654
+++ LVM2/WHATS_NEW	2007/07/12 15:38:52	1.655
@@ -1,7 +1,7 @@
 Version 2.02.27 - 
 ================================
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
-  Add pv_read_path() external library function.
+  Add pv_by_path() external library function.
   Tidy clvmd-openais of redundant bits, and improve an error report.
   Cope with find_seg_by_le() failure in check_lv_segments().
   Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
--- LVM2/lib/metadata/metadata.c	2007/07/12 05:04:41	1.126
+++ LVM2/lib/metadata/metadata.c	2007/07/12 15:38:53	1.127
@@ -255,7 +255,7 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!(pv = pv_read_path(vg->fid->fmt->cmd, pv_names[i]))) {
+		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
 			log_error("%s not identified as an existing "
 				  "physical volume", pv_names[i]);
 			goto bad;
@@ -1858,7 +1858,7 @@
 
 
 /**
- * pv_read_path - Given a device path return a PV handle if it is a PV
+ * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
  * @pv_name - device path to read for the PV
  *
@@ -1866,8 +1866,9 @@
  *  NULL - device path does not contain a valid PV
  *  non-NULL - PV handle corresponding to device path
  *
+ * FIXME: merge with find_pv_by_name ?
  */
-pv_t *pv_read_path(struct cmd_context *cmd, const char *pv_name)
+pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
 	struct list mdas;
 	
--- LVM2/lib/metadata/metadata.h	2007/07/12 05:04:42	1.168
+++ LVM2/lib/metadata/metadata.h	2007/07/12 15:38:53	1.169
@@ -654,7 +654,7 @@
 
 uint32_t vg_status(vg_t *vg);
 
-pv_t *pv_read_path(struct cmd_context *cmd, const char *pv_name);
+pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
 


