From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 09:46:39 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120301094639.29488.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 09:46:38

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix leak of FID structure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.494&r2=1.495

--- LVM2/lib/metadata/metadata.c	2012/02/29 02:35:36	1.494
+++ LVM2/lib/metadata/metadata.c	2012/03/01 09:46:38	1.495
@@ -2775,8 +2775,7 @@
 	return 1;
 }
 
-/* Make orphan PVs look like a VG. FIXME multiple runs will leak memory
- * allocated to PVs into the orphan VG pool which is now global. */
+/* Make orphan PVs look like a VG. */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 					     int warnings,
 					     const char *orphan_vgname)
@@ -2785,6 +2784,7 @@
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
 	struct _vg_read_orphan_baton baton;
+	struct pv_list *pvl;
 
 	lvmcache_label_scan(cmd, 0);
 	lvmcache_seed_infos_from_lvmetad(cmd);
@@ -2796,6 +2796,8 @@
 		return_NULL;
 
 	vg = fmt->orphan_vg;
+	dm_list_iterate_items(pvl, &vg->pvs)
+		pv_set_fid(pvl->pv, NULL);
 	dm_list_init(&vg->pvs);
 	vg->pv_count = 0;
 
@@ -2803,7 +2805,7 @@
 	baton.vg = vg;
 
 	if (!lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton))
-                return_NULL;
+		return_NULL;
 
 	return vg;
 }


