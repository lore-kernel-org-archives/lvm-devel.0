From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:26:21 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgreduce.c
Message-ID: <20100413172621.12234.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:26:20

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgreduce.c 

Log message:
	Use del_pvl_from_vgs() in vgreduce paths.
	
	Somehow these got missed in earlier patches.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.334&r2=1.335
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/lib/metadata/metadata.c	2010/04/13 17:26:03	1.334
+++ LVM2/lib/metadata/metadata.c	2010/04/13 17:26:20	1.335
@@ -667,12 +667,11 @@
 		goto bad;
 	}
 
-	vg->pv_count--;
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
+	del_pvl_from_vgs(vg, pvl);
 
 	/* add pv to the remove_pvs list */
-	dm_list_del(&pvl->list);
 	dm_list_add(&vg->removed_pvs, &pvl->list);
 
 	return 1;
--- LVM2/tools/vgreduce.c	2010/04/13 17:26:03	1.101
+++ LVM2/tools/vgreduce.c	2010/04/13 17:26:20	1.102
@@ -407,7 +407,7 @@
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
 	if (pvl)
-		dm_list_del(&pvl->list);
+		del_pvl_from_vgs(vg, pvl);
 
 	pv->vg_name = vg->fid->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
@@ -417,7 +417,6 @@
 		goto bad;
 	}
 
-	vg->pv_count--;
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 


