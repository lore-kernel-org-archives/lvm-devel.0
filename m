From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Jul 2007 21:48:31 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20070702214831.4164.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-02 21:48:31

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Convert _add_pv_to_vg to usable LVM library function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.645&r2=1.646
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2007/07/02 20:18:38	1.645
+++ LVM2/WHATS_NEW	2007/07/02 21:48:30	1.646
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Convert _add_pv_to_vg to usable LVM library function.
   Add kernel and device-mapper targets versions report to lvmdump.
   Don't use index and rindex functions marked by SUSv3 as legacy.
   Fix vgsplit if splitting all PVs from VG.
--- LVM2/lib/metadata/metadata.c	2007/06/28 17:33:44	1.122
+++ LVM2/lib/metadata/metadata.c	2007/07/02 21:48:30	1.123
@@ -66,11 +66,11 @@
 	return MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
 }
 
-static int _add_pv_to_vg(struct format_instance *fid, struct volume_group *vg,
-			 const char *pv_name)
+static int _add_pv_to_vg(struct volume_group *vg, const char *pv_name)
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
+	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = fid->fmt->cmd->mem;
 	struct list mdas;
 
@@ -251,7 +251,7 @@
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++)
-		if (!_add_pv_to_vg(vg->fid, vg, pv_names[i])) {
+		if (!_add_pv_to_vg(vg, pv_names[i])) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_names[i], vg->name);
 			return 0;


