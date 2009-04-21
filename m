From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Apr 2009 12:59:20 -0000
Subject: LVM2 ./WHATS_NEW test/t-listings.sh tools/repo ...
Message-ID: <20090421125920.23763.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-21 12:59:19

Modified files:
	.              : WHATS_NEW 
	test           : t-listings.sh 
	tools          : reporter.c toollib.c 

Log message:
	Fix pvseg report for orphan PVs and other devices.
	
	If user requests report attribute from PVSEG type
	and PV is orphan (or all devices is set), the report
	is empty.
	
	Try for example (when only orphan PV are present)
	#pvs
	#pvs -o +devices
	# pvs /dev/sdb1
	PV         VG   Fmt  Attr PSize  PFree
	/dev/sdb1       lvm2 --   46.58G 46.58G
	# pvs -o +devices /dev/sdb1
	(no output)
	
	The problem is caused by empty pv->segments list.
	
	Fix it by providing fake segment here (similar to fake structures
	in _pvsegs_sub_single() calls.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1088&r2=1.1089
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-listings.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/WHATS_NEW	2009/04/21 12:57:31	1.1088
+++ LVM2/WHATS_NEW	2009/04/21 12:59:18	1.1089
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix pvs report for orphan PVs when segment attributes are requested.
   Fix pvs -a output to not read volume groups from non-PV devices.
   Add MMC (mmcblk) device type to filters.
   Introduce memory pools per volume group (to reduce memory for large VGs).
--- LVM2/test/t-listings.sh	2008/11/11 15:29:24	1.1
+++ LVM2/test/t-listings.sh	2009/04/21 12:59:18	1.2
@@ -34,6 +34,10 @@
 pvs --noheadings|tee out
 test $(wc -l <out) -eq 5
 
+#COMM pvs with segment attributes works even for orphans
+pvs --noheadings -o  seg_all,pv_all,lv_all,vg_all | tee out
+test $(wc -l <out) -eq 5
+
 vgcreate -c n $vg $devs
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
--- LVM2/tools/reporter.c	2009/04/10 10:01:38	1.46
+++ LVM2/tools/reporter.c	2009/04/21 12:59:19	1.47
@@ -54,15 +54,20 @@
 	return ECMD_PROCESSED;
 }
 
-static int _pvsegs_sub_single(struct cmd_context *cmd __attribute((unused)),
+static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct pv_segment *pvseg, void *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 
+	struct volume_group _free_vg = {
+		.cmd = cmd,
+		.name = (char *)"",
+	};
+
 	struct logical_volume _free_logical_volume = {
-		.vg = vg,
+		.vg = vg ?: &_free_vg,
 		.name = (char *) "",
 	        .snapshot = NULL,
 		.status = VISIBLE_LV,
@@ -88,6 +93,9 @@
 
         _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
+	dm_list_init(&_free_vg.pvs);
+	dm_list_init(&_free_vg.lvs);
+	dm_list_init(&_free_vg.tags);
 	dm_list_init(&_free_lv_segment.tags);
 	dm_list_init(&_free_lv_segment.origin_list);
 	dm_list_init(&_free_logical_volume.tags);
--- LVM2/tools/toollib.c	2009/04/21 12:57:32	1.149
+++ LVM2/tools/toollib.c	2009/04/21 12:59:19	1.150
@@ -375,6 +375,7 @@
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct volume_group *old_vg = vg;
+	struct pv_segment _free_pv_segment = { .pv = pv };
 
 	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
@@ -399,13 +400,18 @@
 		pv = pvl->pv;
 	}
 
-	dm_list_iterate_items(pvseg, &pv->segments) {
-		ret = process_single(cmd, vg, pvseg, handle);
+	if (dm_list_empty(&pv->segments)) {
+		ret = process_single(cmd, NULL, &_free_pv_segment, handle);
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
-			break;
-	}
+	} else
+		dm_list_iterate_items(pvseg, &pv->segments) {
+			ret = process_single(cmd, vg, pvseg, handle);
+			if (ret > ret_max)
+				ret_max = ret;
+			if (sigint_caught())
+				break;
+		}
 
 	if (vg_name)
 		unlock_vg(cmd, vg_name);


