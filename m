From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:15:58 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20110110131558.21883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:15:57

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Cache config_tree
	
	Start to use config_tree for cache just like vgmetadata.
	When vgmetadata are erased destroy its cached config tree.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1867&r2=1.1868
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2011/01/10 13:13:42	1.1867
+++ LVM2/WHATS_NEW	2011/01/10 13:15:57	1.1868
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Speedup command processing by caching resolved config tree.
   Pass config_tree to renamed function import_vg_from_config_tree().
   Detect NULL handle in get_property().
   Fix superfluous /usr in ocf_scriptdir instalation path.
--- LVM2/lib/cache/lvmcache.c	2011/01/10 13:13:42	1.101
+++ LVM2/lib/cache/lvmcache.c	2011/01/10 13:15:57	1.102
@@ -83,6 +83,12 @@
 
 	vginfo->vgmetadata = NULL;
 
+	/* Release also cached config tree */
+	if (vginfo->cft) {
+		destroy_config_tree(vginfo->cft);
+		vginfo->cft = NULL;
+	}
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -651,7 +657,9 @@
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vginfo->cft =
+	/* Build config tree from vgmetadata, if not yet cached */
+	if (!vginfo->cft &&
+	    !(vginfo->cft =
 	      create_config_tree_from_string(fid->fmt->cmd,
 					     vginfo->vgmetadata))) {
 		_free_cached_vgmetadata(vginfo);
@@ -660,10 +668,8 @@
 
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
 		_free_cached_vgmetadata(vginfo);
-		destroy_config_tree(vginfo->cft);
 		return_NULL;
 	}
-	destroy_config_tree(vginfo->cft);
 
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
--- LVM2/lib/cache/lvmcache.h	2011/01/10 13:13:42	1.36
+++ LVM2/lib/cache/lvmcache.h	2011/01/10 13:15:57	1.37
@@ -48,6 +48,7 @@
 	char *creation_host;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
+				/* Lifetime is directly tied to vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 


