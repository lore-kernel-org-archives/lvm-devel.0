From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:02:49 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091005200249.17056.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:02:49

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : vgcreate.c vgextend.c 

Log message:
	Add pvcreate_params to vg_extend.
	
	Another refactoring for implicit pvcreate support.  We need to get
	the pvcreate parameters somehow to the vg_extend routine.  Options
	seemed to be:
	1. Attach the parameters to struct volume_group.  I personally
	did not like this idea in most cases, though one could make an
	agrument why it might be ok at least for some of the parameters
	(e.g. metadatacopies).
	2. Pass them in to the extend routine.  This second route seemed
	to be the best approach given the constraints.
	
	Future patches will parse the command line and fill in the actual
	values for the pvcreate_single call.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.286&r2=1.287
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/metadata/metadata-exported.h	2009/10/01 01:04:27	1.114
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/05 20:02:48	1.115
@@ -453,7 +453,8 @@
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, char *pv_name);
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
--- LVM2/lib/metadata/metadata.c	2009/10/05 20:02:30	1.286
+++ LVM2/lib/metadata/metadata.c	2009/10/05 20:02:48	1.287
@@ -582,7 +582,18 @@
 	return 1;
 }
 
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_count: count of device paths of PVs
+ * - pv_names: device paths of PVs to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
+ *
+ */
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+	      struct pvcreate_params *pp)
 {
 	int i;
 
@@ -591,7 +602,7 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!vg_extend_single_pv(vg, pv_names[i], NULL))
+		if (!vg_extend_single_pv(vg, pv_names[i], pp))
 			goto bad;
 	}
 
--- LVM2/liblvm/lvm_vg.c	2009/09/14 19:43:12	1.30
+++ LVM2/liblvm/lvm_vg.c	2009/10/05 20:02:48	1.31
@@ -60,7 +60,7 @@
 		return -1;
 	}
 
-	if (!vg_extend(vg, 1, (char **) &device)) {
+	if (!vg_extend(vg, 1, (char **) &device, NULL)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
--- LVM2/tools/vgcreate.c	2009/09/14 22:47:50	1.66
+++ LVM2/tools/vgcreate.c	2009/10/05 20:02:48	1.67
@@ -63,7 +63,7 @@
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc - 1, argv + 1))
+	if (!vg_extend(vg, argc - 1, argv + 1, NULL))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
--- LVM2/tools/vgextend.c	2009/09/14 22:47:50	1.50
+++ LVM2/tools/vgextend.c	2009/10/05 20:02:49	1.51
@@ -54,7 +54,7 @@
 		goto_bad;
 
 	/* extend vg */
-	if (!vg_extend(vg, argc, argv))
+	if (!vg_extend(vg, argc, argv, NULL))
 		goto_bad;
 
 	/* ret > 0 */


