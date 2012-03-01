From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:16:44 -0000
Subject: LVM2/tools vgmerge.c vgrename.c
Message-ID: <20120301211644.9564.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:16:44

Modified files:
	tools          : vgmerge.c vgrename.c 

Log message:
	Backtrace for failing drop_cached_metadata

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/tools/vgmerge.c	2011/08/10 20:25:31	1.74
+++ LVM2/tools/vgmerge.c	2012/03/01 21:16:44	1.75
@@ -80,7 +80,8 @@
 	if (!archive(vg_from) || !archive(vg_to))
 		goto_bad;
 
-	drop_cached_metadata(vg_from);
+	if (!drop_cached_metadata(vg_from))
+		stack;
 
 	/* Merge volume groups */
 	dm_list_iterate_items_safe(pvl, tpvl, &vg_from->pvs) {
--- LVM2/tools/vgrename.c	2012/02/28 18:08:08	1.79
+++ LVM2/tools/vgrename.c	2012/03/01 21:16:44	1.80
@@ -139,7 +139,8 @@
 		goto error;
 
 	/* Remove references based on old name */
-	drop_cached_metadata(vg);
+	if (!drop_cached_metadata(vg))
+		stack;
 
 	/* Change the volume group name */
 	vg_rename(cmd, vg, vg_name_new);


