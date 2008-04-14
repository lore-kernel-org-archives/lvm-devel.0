From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2008 19:24:17 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20080414192417.1011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-14 19:24:16

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Don't store fid in VG metadata cache to avoid clvmd segfault. (2.02.34)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.847&r2=1.848
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2008/04/10 21:38:52	1.847
+++ LVM2/WHATS_NEW	2008/04/14 19:24:15	1.848
@@ -1,5 +1,6 @@
 Version 2.02.35 - 
 =================================
+  Don't store fid in VG metadata cache to avoid clvmd segfault. (2.02.34)
   Update vgsplit tests to verify loosening of active LV restriction.
   Update vgsplit to only restrict split with active LVs involved in split.
   Add lv_is_active() to determine whether an lv is active.
--- LVM2/lib/cache/lvmcache.c	2008/04/08 12:49:20	1.43
+++ LVM2/lib/cache/lvmcache.c	2008/04/14 19:24:15	1.44
@@ -63,7 +63,6 @@
 	dm_free(vginfo->vgmetadata);
 
 	vginfo->vgmetadata = NULL;
-	vginfo->fid = NULL;
 
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
@@ -81,7 +80,6 @@
 		return;
 	}
 
-	vginfo->fid = vg->fid;
 	vginfo->precommitted = precommitted;
 
 	log_debug("Metadata cache: VG %s stored (%d bytes%s).", vginfo->vgname,
@@ -400,6 +398,7 @@
 {
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg;
+	struct format_instance *fid;
 
 	if (!vgid || !(vginfo = vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
 		return NULL;
@@ -411,7 +410,12 @@
 	    (!precommitted && vginfo->precommitted))
 		return NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, vginfo->fid)) ||
+	fid =  vginfo->fmt->ops->create_instance(vginfo->fmt, vginfo->vgname,
+						 vgid, NULL);
+	if (!fid)
+		return NULL;
+
+	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
 	    !vg_validate(vg)) {
 		_free_cached_vgmetadata(vginfo);
 		return_NULL;
--- LVM2/lib/cache/lvmcache.h	2008/04/08 12:49:20	1.20
+++ LVM2/lib/cache/lvmcache.h	2008/04/14 19:24:16	1.21
@@ -45,7 +45,6 @@
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
-	struct format_instance *fid;	/* fid associated with vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 


