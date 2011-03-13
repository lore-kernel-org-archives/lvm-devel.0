From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Mar 2011 23:05:49 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c ...
Message-ID: <20110313230549.16622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-13 23:05:49

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 
	lib/format1    : import-export.c 
	lib/metadata   : metadata.c 

Log message:
	Fix allocation of system_id
	
	As code uses strncpy(system_id, NAME_LEN) and doesn't set '\0'
	Fix it by always allocating NAME_LEN + 1 buffer size and with zalloc
	we always get '\0' as the last byte.
	
	This bug may trigger some unexpected behavior of the string operation
	code - depends on the pool allocator.
	
	FIXME: refactor this code to alloc_vg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1953&r2=1.1954
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.448&r2=1.449

--- LVM2/WHATS_NEW	2011/03/13 22:57:51	1.1953
+++ LVM2/WHATS_NEW	2011/03/13 23:05:48	1.1954
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix allocation of system_id buffer in volume_group structure.
   Fix buffer allocation in build_dm_uuid().
   Fix readlink usage inside get_primary_dev().
   Use format instance mempool where possible and adequate.
--- LVM2/lib/format_text/import_vsn1.c	2011/03/11 14:50:15	1.84
+++ LVM2/lib/format_text/import_vsn1.c	2011/03/13 23:05:48	1.85
@@ -666,7 +666,7 @@
 	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
 		return_NULL;
 
-	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
 		goto_bad;
 
 	vgn = vgn->child;
--- LVM2/lib/format1/import-export.c	2010/11/30 22:57:35	1.116
+++ LVM2/lib/format1/import-export.c	2011/03/13 23:05:48	1.117
@@ -225,7 +225,7 @@
 	if (!(vg->name = dm_pool_strdup(mem, (char *)dl->pvd.vg_name)))
 		return_0;
 
-	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN + 1)))
 		return_0;
 
 	*vg->system_id = '\0';
--- LVM2/lib/metadata/metadata.c	2011/03/11 15:10:17	1.448
+++ LVM2/lib/metadata/metadata.c	2011/03/13 23:05:49	1.449
@@ -934,7 +934,7 @@
 	}
 
 	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
-	if (!(vg->system_id = dm_pool_alloc(vg->vgmem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
 		goto_bad;
 
 	*vg->system_id = '\0';


