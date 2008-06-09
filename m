From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jun 2008 16:22:33 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20080609162233.8203.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-09 16:22:33

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Fix segfault after _free_vginfo by remembering to remove vginfo from list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.892&r2=1.893
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/06/08 14:18:44	1.892
+++ LVM2/WHATS_NEW	2008/06/09 16:22:32	1.893
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Fix segfault after _free_vginfo by remembering to remove vginfo from list.
   Tweak detection of invalid fid after changes to PVs in VG in _vg_read.
   Revert assuming precommitted metadata is live when activating (unnecessary).
   Drop cached metadata for disappearing VG in vgmerge.
--- LVM2/lib/cache/lvmcache.c	2008/06/06 12:43:40	1.56
+++ LVM2/lib/cache/lvmcache.c	2008/06/09 16:22:33	1.57
@@ -631,11 +631,14 @@
 
 static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 {
+	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
 	int r = 1;
 
 	_free_cached_vgmetadata(vginfo);
 
-	if (vginfo_from_vgname(vginfo->vgname, NULL) == vginfo) {
+	vginfo2 = primary_vginfo = vginfo_from_vgname(vginfo->vgname, NULL);
+
+	if (vginfo == primary_vginfo) {
 		dm_hash_remove(_vgname_hash, vginfo->vgname);
 		if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
 						    vginfo->next)) {
@@ -643,7 +646,12 @@
 				  vginfo->vgname);
 			r = 0;
 		}
-	}
+	} else do
+		if (vginfo2->next == vginfo) {
+			vginfo2->next = vginfo->next;
+			break;
+		}
+ 	while ((vginfo2 = primary_vginfo->next));
 
 	if (vginfo->vgname)
 		dm_free(vginfo->vgname);


