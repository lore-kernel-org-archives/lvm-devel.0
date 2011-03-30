From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 13:14:36 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20110330131436.20085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 13:14:34

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Keep the cache content when the exported vg buffer is matching
	
	Instead of regenerating config tree and parsing same data again,
	check whether export_vg_to_buffer does not produce same string as
	the one already cached - in this case keep it, otherwise throw cached
	content away.
	
	For the code simplicity calling _free_cached_vgmetadata() with
	vgmetadata == NULL as the function handles this itself.
	
	Note: sometimes export_vg_to_buffer() generates almost the same data
	with just different time stamp, but for the patch simplicity,
	data are reparsed in this case.
	
	This patch currently helps for vgrefresh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1966&r2=1.1967
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2011/03/30 13:06:13	1.1966
+++ LVM2/WHATS_NEW	2011/03/30 13:14:34	1.1967
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Keep the cache content when the exported vg buffer is matching.
   Extend the set of memory regions, that are not locked to memory.
   Enhance usability with the valgrind memcheck tool.
   Support regular quit of the lvm_thread_fn function in clvmd.
--- LVM2/lib/cache/lvmcache.c	2011/03/29 21:34:18	1.108
+++ LVM2/lib/cache/lvmcache.c	2011/03/30 13:14:34	1.109
@@ -99,6 +99,7 @@
 {
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
+	char *data;
 	int size;
 
 	if (!(vginfo = vginfo_from_vgid((const char *)&vg->id))) {
@@ -106,14 +107,22 @@
 		return;
 	}
 
-	if (vginfo->vgmetadata)
-		_free_cached_vgmetadata(vginfo);
-
-	if (!(size = export_vg_to_buffer(vg, &vginfo->vgmetadata))) {
+	if (!(size = export_vg_to_buffer(vg, &data))) {
 		stack;
+		_free_cached_vgmetadata(vginfo);
 		return;
 	}
 
+	/* Avoid reparsing of the same data string */
+	if (vginfo->vgmetadata && vginfo->vgmetadata_size == size &&
+	    strcmp(vginfo->vgmetadata, data) == 0)
+		dm_free(data);
+	else {
+		_free_cached_vgmetadata(vginfo);
+		vginfo->vgmetadata_size = size;
+		vginfo->vgmetadata = data;
+	}
+
 	vginfo->precommitted = precommitted;
 
 	if (!id_write_format((const struct id *)vginfo->vgid, uuid, sizeof(uuid))) {
--- LVM2/lib/cache/lvmcache.h	2011/01/10 13:15:57	1.37
+++ LVM2/lib/cache/lvmcache.h	2011/03/30 13:14:34	1.38
@@ -46,6 +46,7 @@
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	size_t vgmetadata_size;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */


