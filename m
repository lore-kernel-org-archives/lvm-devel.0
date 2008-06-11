From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Jun 2008 13:14:41 -0000
Subject: LVM2/lib/format_pool format_pool.c import_export.c
Message-ID: <20080611131441.2609.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-06-11 13:14:41

Modified files:
	lib/format_pool: format_pool.c import_export.c 

Log message:
	copy vgid only when volume group is present in import_pool_pv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/format_pool/format_pool.c	2008/06/10 14:55:14	1.16
+++ LVM2/lib/format_pool/format_pool.c	2008/06/11 13:14:41	1.17
@@ -225,7 +225,7 @@
 	if (!(pl = read_pool_disk(fmt, dev, mem, NULL)))
 		goto_out;
 
-	if (!import_pool_pv(fmt, fmt->cmd->mem, fmt->orphan_vg_name, pv, pl))
+	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl))
 		goto_out;
 
 	pv->fmt = fmt;
--- LVM2/lib/format_pool/import_export.c	2008/06/10 14:55:14	1.22
+++ LVM2/lib/format_pool/import_export.c	2008/06/11 13:14:41	1.23
@@ -165,7 +165,8 @@
 		log_error("Unable to duplicate vg_name string");
 		return 0;
 	}
-	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
+	if (vg != NULL)
+		memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 	pv->status = 0;
 	pv->size = pd->pl_blocks;
 	pv->pe_size = POOL_PE_SIZE;


