From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Jun 2007 18:23:18 -0000
Subject: LVM2/tools pvdisplay.c
Message-ID: <20070605182318.32172.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-05 18:23:18

Modified files:
	tools          : pvdisplay.c 

Log message:
	make code consistent with pvresize code - good candidate for common code cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/tools/pvdisplay.c	2007/05/31 20:10:25	1.27
+++ LVM2/tools/pvdisplay.c	2007/06/05 18:23:17	1.28
@@ -19,10 +19,10 @@
 			     struct volume_group *vg __attribute((unused)),
 			     struct physical_volume *pv, void *handle)
 {
+	struct pv_list *pvl;
 	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
-	struct physical_volume *pv_temp;
 
 	const char *pv_name = dev_name(pv->dev);
 
@@ -49,15 +49,14 @@
 		  * Replace possibly incomplete PV structure with new one
 		  * allocated in vg_read() path.
 		  */
-		 pv_temp = find_pv(vg, pv->dev);
-		 if (!pv_temp) {
-			 log_error("Unable to find physical volume %s "
-				   "in volume group %s",
-				   pv_name, pv->vg_name);
+		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+			 log_error("Unable to find \"%s\" in volume group \"%s\"",
+				   pv_name, vg->name);
 	                 ret = ECMD_FAILED;
-			 goto out;
+	                 goto out;
 		 }
-		 pv = pv_temp;
+
+		 pv = pvl->pv;
 	}
 
 	if (!*pv->vg_name)


