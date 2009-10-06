From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Oct 2009 16:00:39 -0000
Subject: LVM2 lib/metadata/metadata.c tools/toollib.c
Message-ID: <20091006160039.28847.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-06 16:00:38

Modified files:
	lib/metadata   : metadata.c 
	tools          : toollib.c 

Log message:
	Cleanup comment and some whitespace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.289&r2=1.290
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/lib/metadata/metadata.c	2009/10/05 20:03:25	1.289
+++ LVM2/lib/metadata/metadata.c	2009/10/06 16:00:38	1.290
@@ -67,7 +67,7 @@
 
 	if (data_alignment)
 		pv->pe_align = data_alignment;
-	else 
+	else
 		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
 
 	if (!pv->dev)
@@ -1292,18 +1292,19 @@
 }
 
 /*
- * pvcreate_single() - initialize a device with PV label and metadata
+ * pvcreate_single() - initialize a device with PV label and metadata area
  *
  * Parameters:
  * - pv_name: device path to initialize
- * - handle: options to pass to pv_create; NULL indicates use defaults
+ * - pp: parameters to pass to pv_create; if NULL, use default values
  *
  * Returns:
  * NULL: error
  * struct physical_volume * (non-NULL): handle to physical volume created
  */
-struct physical_volume * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		       struct pvcreate_params *pp)
+struct physical_volume * pvcreate_single(struct cmd_context *cmd,
+					 const char *pv_name,
+					 struct pvcreate_params *pp)
 {
 	void *pv;
 	struct device *dev;
--- LVM2/tools/toollib.c	2009/10/05 20:55:57	1.174
+++ LVM2/tools/toollib.c	2009/10/06 16:00:38	1.175
@@ -1021,7 +1021,7 @@
 			new_pvl = pvl2;
 			break;
 		}
-	
+
 	if (!new_pvl) {
 		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
 			log_error("Unable to allocate physical volume list.");
@@ -1239,12 +1239,12 @@
 {
 	struct lv_list *lvl;
 	int r = 1;
-	
+
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv))
 			if (!lv_refresh(cmd, lvl->lv))
 				r = 0;
-	
+
 	return r;
 }
 


