From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jul 2007 05:04:43 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070712050443.13625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-12 05:04:42

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Turn _add_pv_to_vg() into external library function add_pv_to_vg()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.653&r2=1.654
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.167&r2=1.168

--- LVM2/WHATS_NEW	2007/07/11 23:33:12	1.653
+++ LVM2/WHATS_NEW	2007/07/12 05:04:39	1.654
@@ -1,6 +1,7 @@
 Version 2.02.27 - 
 ================================
-  Add pv_read_path external library function.
+  Turn _add_pv_to_vg() into external library function add_pv_to_vg().
+  Add pv_read_path() external library function.
   Tidy clvmd-openais of redundant bits, and improve an error report.
   Cope with find_seg_by_le() failure in check_lv_segments().
   Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
--- LVM2/lib/metadata/metadata.c	2007/07/12 04:12:04	1.125
+++ LVM2/lib/metadata/metadata.c	2007/07/12 05:04:41	1.126
@@ -66,10 +66,21 @@
 	return MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
 }
 
-static int _add_pv_to_vg(struct volume_group *vg, const char *pv_name)
+/**
+ * add_pv_to_vg - Add a physical volume to a volume group
+ * @vg - volume group to add to
+ * @pv_name - name of the pv (to be removed)
+ * @pv - physical volume to add to volume group
+ *
+ * Returns:
+ *  0 - failure
+ *  1 - success
+ * FIXME: remove pv_name - obtain safely from pv
+ */
+int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		 struct physical_volume *pv)
 {
 	struct pv_list *pvl;
-	struct physical_volume *pv;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = fid->fmt->cmd->mem;
 
@@ -81,12 +92,6 @@
 		return 0;
 	}
 
-	if (!(pv = pv_read_path(fid->fmt->cmd, pv_name))) {
-		log_error("%s not identified as an existing physical volume",
-			  pv_name);
-		return 0;
-	}
-
 	if (*pv->vg_name) {
 		log_error("Physical volume '%s' is already in volume group "
 			  "'%s'", pv_name, pv->vg_name);
@@ -246,11 +251,19 @@
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
+	struct physical_volume *pv;
 
 	/* attach each pv */
-	for (i = 0; i < pv_count; i++)
-		if (!_add_pv_to_vg(vg, pv_names[i]))
+	for (i = 0; i < pv_count; i++) {
+		if (!(pv = pv_read_path(vg->fid->fmt->cmd, pv_names[i]))) {
+			log_error("%s not identified as an existing "
+				  "physical volume", pv_names[i]);
 			goto bad;
+		}
+		
+		if (!add_pv_to_vg(vg, pv_names[i], pv))
+			goto bad;
+	}
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
@@ -1854,7 +1867,7 @@
  *  non-NULL - PV handle corresponding to device path
  *
  */
-pv_t *pv_read_path(const struct cmd_context *cmd, const char *pv_name)
+pv_t *pv_read_path(struct cmd_context *cmd, const char *pv_name)
 {
 	struct list mdas;
 	
--- LVM2/lib/metadata/metadata.h	2007/07/11 23:33:12	1.167
+++ LVM2/lib/metadata/metadata.h	2007/07/12 05:04:42	1.168
@@ -654,6 +654,8 @@
 
 uint32_t vg_status(vg_t *vg);
 
-pv_t *pv_read_path(const struct cmd_context *cmd, const char *pv_name);
+pv_t *pv_read_path(struct cmd_context *cmd, const char *pv_name);
+int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		 struct physical_volume *pv);
 
 #endif


