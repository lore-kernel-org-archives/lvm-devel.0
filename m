From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Feb 2009 18:56:41 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20090217185641.8200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-17 18:56:41

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.  (dwyso)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1043&r2=1.1044
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2009/02/12 20:42:07	1.1043
+++ LVM2/WHATS_NEW	2009/02/17 18:56:41	1.1044
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.
   No longer require kernel and metadata major numbers to match.
   Add a fully-functional get_cluster_name() to clvmd corosync interface.
   Remove duplicate cpg_initialize from clvmd startup.
--- LVM2/lib/cache/lvmcache.c	2008/11/28 15:51:40	1.63
+++ LVM2/lib/cache/lvmcache.c	2009/02/17 18:56:41	1.64
@@ -71,11 +71,20 @@
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
-static void _store_metadata(struct lvmcache_vginfo *vginfo,
-			    struct volume_group *vg, unsigned precommitted)
+/*
+ * Cache VG metadata against the vginfo with matching vgid.
+ */
+static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 {
+	char uuid[64] __attribute((aligned(8)));
+	struct lvmcache_vginfo *vginfo;
 	int size;
 
+	if (!(vginfo = vginfo_from_vgid((const char *)&vg->id))) {
+		stack;
+		return;
+	}
+
 	if (vginfo->vgmetadata)
 		_free_cached_vgmetadata(vginfo);
 
@@ -86,8 +95,14 @@
 
 	vginfo->precommitted = precommitted;
 
-	log_debug("Metadata cache: VG %s stored (%d bytes%s).", vginfo->vgname,
-		  size, precommitted ? ", precommitted" : "");
+	if (!id_write_format((const struct id *)vginfo->vgid, uuid, sizeof(uuid))) {
+		stack;
+		return;
+	}
+
+	log_debug("Metadata cache: VG %s (%s) stored (%d bytes%s).",
+		  vginfo->vgname, uuid, size,
+		  precommitted ? ", precommitted" : "");
 }
 
 static void _update_cache_info_lock_state(struct lvmcache_info *info,
@@ -1051,7 +1066,6 @@
 {
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
-	struct lvmcache_vginfo *vginfo;
 	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
@@ -1067,9 +1081,8 @@
 	}
 
 	/* store text representation of vg to cache */
-	if (vg->cmd->current_settings.cache_vgmetadata &&
-	    (vginfo = vginfo_from_vgname(vg->name, NULL)))
-		_store_metadata(vginfo, vg, precommitted);
+	if (vg->cmd->current_settings.cache_vgmetadata)
+		_store_metadata(vg, precommitted);
 
 	return 1;
 }


