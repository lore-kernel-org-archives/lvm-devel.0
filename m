From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:02:04 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20091005200204.8403.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:02:04

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Refactor vg_extend - add vg_extend_single_pv.
	
	Simple refactor to setup future changes related to implicit pvcreates.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.284&r2=1.285

--- LVM2/lib/metadata/metadata.c	2009/09/15 18:35:14	1.284
+++ LVM2/lib/metadata/metadata.c	2009/10/05 20:02:04	1.285
@@ -553,22 +553,38 @@
 	return ret;
 }
 
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_name: device path of PV to add to VG
+ *
+ */
+static int vg_extend_single_pv(struct volume_group *vg, char *pv_name)
+{
+	struct physical_volume *pv;
+
+	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name))) {
+		log_error("%s not identified as an existing "
+			  "physical volume", pv_name);
+		return 0;
+	}
+	if (!add_pv_to_vg(vg, pv_name, pv))
+		return 0;
+	return 1;
+}
+
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
-	struct physical_volume *pv;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
-			log_error("%s not identified as an existing "
-				  "physical volume", pv_names[i]);
-			goto bad;
-		}
-		if (!add_pv_to_vg(vg, pv_names[i], pv))
+		if (!vg_extend_single_pv(vg, pv_names[i]))
 			goto bad;
 	}
 


