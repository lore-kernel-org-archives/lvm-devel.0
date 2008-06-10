From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jun 2008 14:55:15 -0000
Subject: LVM2 lib/format_pool/format_pool.c lib/format_ ...
Message-ID: <20080610145515.27895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-06-10 14:55:15

Modified files:
	lib/format_pool: format_pool.c import_export.c 
	.              : WHATS_NEW 

Log message:
	Fix wrong free_count on imported volume group from pool device
	Fix segfault when calling pvcreate on the pool device

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.893&r2=1.894

--- LVM2/lib/format_pool/format_pool.c	2008/04/08 12:49:20	1.15
+++ LVM2/lib/format_pool/format_pool.c	2008/06/10 14:55:14	1.16
@@ -225,7 +225,7 @@
 	if (!(pl = read_pool_disk(fmt, dev, mem, NULL)))
 		goto_out;
 
-	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl))
+	if (!import_pool_pv(fmt, fmt->cmd->mem, fmt->orphan_vg_name, pv, pl))
 		goto_out;
 
 	pv->fmt = fmt;
--- LVM2/lib/format_pool/import_export.c	2008/01/30 13:59:59	1.21
+++ LVM2/lib/format_pool/import_export.c	2008/06/10 14:55:14	1.22
@@ -36,6 +36,7 @@
 		vg->extent_count +=
 		    ((pl->pd.pl_blocks) / POOL_PE_SIZE);
 
+		vg->free_count = vg->extent_count;
 		vg->pv_count++;
 
 		if (vg->name)
@@ -45,7 +46,6 @@
 		get_pool_vg_uuid(&vg->id, &pl->pd);
 		vg->extent_size = POOL_PE_SIZE;
 		vg->status |= LVM_READ | LVM_WRITE | CLUSTERED | SHARED;
-		vg->free_count = vg->extent_count;
 		vg->max_lv = 1;
 		vg->max_pv = POOL_MAX_DEVICES;
 		vg->alloc = ALLOC_NORMAL;
--- LVM2/WHATS_NEW	2008/06/09 16:22:32	1.893
+++ LVM2/WHATS_NEW	2008/06/10 14:55:14	1.894
@@ -1,5 +1,7 @@
 Version 2.02.38 - 
 =================================
+  Fix wrong free_count on imported vg from pool device
+  Fix segfault when calling pvcreate on the pool device
   Fix segfault after _free_vginfo by remembering to remove vginfo from list.
   Tweak detection of invalid fid after changes to PVs in VG in _vg_read.
   Revert assuming precommitted metadata is live when activating (unnecessary).


