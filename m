From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:02:31 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20091005200231.15759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:02:30

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add pvcreate_params to vg_extend_single_pv.
	
	Should be no functional change.  If this parameter is set to NULL, just fail
	the extend if the device is not already a PV.  If non-NULL, try pvcreate_single
	before failing.  Note that pvcreate_single() handles the log_error in case
	of failure so we just return 0 if pvcreate_single() fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.285&r2=1.286

--- LVM2/lib/metadata/metadata.c	2009/10/05 20:02:04	1.285
+++ LVM2/lib/metadata/metadata.c	2009/10/05 20:02:30	1.286
@@ -559,16 +559,23 @@
  * Parameters:
  * - vg: handle of volume group to extend by 'pv_name'
  * - pv_name: device path of PV to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
  *
  */
-static int vg_extend_single_pv(struct volume_group *vg, char *pv_name)
+static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
+			       struct pvcreate_params *pp)
 {
 	struct physical_volume *pv;
 
-	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name))) {
+	pv = pv_by_path(vg->fid->fmt->cmd, pv_name);
+	if (!pv && !pp) {
 		log_error("%s not identified as an existing "
 			  "physical volume", pv_name);
 		return 0;
+	} else if (!pv && pp) {
+		pv = pvcreate_single(vg->cmd, pv_name, pp);
+		if (!pv)
+			return 0;
 	}
 	if (!add_pv_to_vg(vg, pv_name, pv))
 		return 0;
@@ -584,7 +591,7 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!vg_extend_single_pv(vg, pv_names[i]))
+		if (!vg_extend_single_pv(vg, pv_names[i], NULL))
 			goto bad;
 	}
 


