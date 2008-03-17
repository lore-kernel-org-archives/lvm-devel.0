From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Mar 2008 16:51:33 -0000
Subject: LVM2/lib cache/lvmcache.c cache/lvmcache.h for ...
Message-ID: <20080317165133.15790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-17 16:51:31

Modified files:
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format1    : format1.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	preparation for vg cache

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/lib/cache/lvmcache.c	2008/02/06 15:47:27	1.38
+++ LVM2/lib/cache/lvmcache.c	2008/03/17 16:51:31	1.39
@@ -490,6 +490,20 @@
 	return;
 } */
 
+int lvmcache_store_vg(struct lvmcache_vginfo *vginfo, struct volume_group *vg,
+		      unsigned precommitted)
+{
+	return 1;
+}
+
+void lvmcache_drop_vg(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+		return;
+}
+
 static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
 	if (!strcmp(info->dev->pvid, pvid))
@@ -768,10 +782,11 @@
 	return 1;
 }
 
-int lvmcache_update_vg(struct volume_group *vg)
+int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 {
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
+	struct lvmcache_vginfo *vginfo;
 	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
@@ -786,6 +801,10 @@
 			return_0;
 	}
 
+	/* store text representation of vg to cache */
+	if ((vginfo = vginfo_from_vgname(vg->name, NULL)))
+		lvmcache_store_vg(vginfo, vg, precommitted);
+
 	return 1;
 }
 
--- LVM2/lib/cache/lvmcache.h	2008/02/06 15:47:27	1.17
+++ LVM2/lib/cache/lvmcache.h	2008/03/17 16:51:31	1.18
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -44,6 +44,9 @@
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	char *vgmetadata;	/* Copy of VG metadata as format_text string */
+	struct format_instance *fid;	/* fid associated with vgmetadata */
+	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
 /* One per device */
@@ -77,7 +80,8 @@
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *hostname);
-int lvmcache_update_vg(struct volume_group *vg);
+int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
+void lvmcache_drop_vg(const char *vgname);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
--- LVM2/lib/format1/format1.c	2008/02/06 15:47:27	1.106
+++ LVM2/lib/format1/format1.c	2008/03/17 16:51:31	1.107
@@ -263,7 +263,7 @@
 			 fid->fmt->cmd->filter) &&
 	     write_disks(fid->fmt, &pvds));
 
-	lvmcache_update_vg(vg);
+	lvmcache_update_vg(vg, 0);
 	dm_pool_destroy(mem);
 	return r;
 }
--- LVM2/lib/format_text/format-text.c	2008/02/06 15:47:27	1.89
+++ LVM2/lib/format_text/format-text.c	2008/03/17 16:51:31	1.90
@@ -1005,7 +1005,7 @@
 				if ((vg = _vg_read_file_name(fid, vgname,
 							     path)))
 					/* FIXME Store creation host in vg */
-					lvmcache_update_vg(vg);
+					lvmcache_update_vg(vg, 0);
 			}
 
 		if (closedir(d))
@@ -1133,7 +1133,7 @@
 					      NULL, NULL))) {
 			if ((vg = _vg_read_raw_area(&fid, vgname,
 						    &rl->dev_area, 0)))
-				lvmcache_update_vg(vg);
+				lvmcache_update_vg(vg, 0);
 		}
 	}
 
--- LVM2/lib/metadata/metadata.c	2008/03/13 22:51:24	1.159
+++ LVM2/lib/metadata/metadata.c	2008/03/17 16:51:31	1.160
@@ -1296,6 +1296,9 @@
 	int cache_updated = 0;
 	int failed = 0;
 
+	/* Forget all cached instances of vg and force reread */
+	lvmcache_drop_vg(vg->name);             
+
 	/* Commit to each copy of the metadata area */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;
@@ -1306,7 +1309,7 @@
 		}
 		/* Update cache first time we succeed */
 		if (!failed && !cache_updated) {
-			lvmcache_update_vg(vg);
+			lvmcache_update_vg(vg, 0);
 			cache_updated = 1;
 		}
 	}
@@ -1408,7 +1411,7 @@
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
-				     int *consistent, int precommitted)
+				     int *consistent, unsigned precommitted)
 {
 	struct format_instance *fid;
 	const struct format_type *fmt;
@@ -1416,7 +1419,7 @@
 	struct metadata_area *mda;
 	int inconsistent = 0;
 	int inconsistent_vgid = 0;
-	int use_precommitted = precommitted;
+	unsigned use_precommitted = precommitted;
 	struct list *pvids;
 	struct pv_list *pvl, *pvl2;
 	struct list all_pvs;
@@ -1559,7 +1562,7 @@
 			return_NULL;
 	}
 
-	lvmcache_update_vg(correct_vg);
+	lvmcache_update_vg(correct_vg, use_precommitted);
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
@@ -1663,7 +1666,7 @@
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
-					    int precommitted)
+					    unsigned precommitted)
 {
 	const char *vgname;
 	struct list *vgnames;
@@ -1724,7 +1727,7 @@
 
 /* Only called by activate.c */
 struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
-				    int precommitted)
+				    unsigned precommitted)
 {
 	struct lv_list *lvl;
 	struct volume_group *vg;
--- LVM2/lib/metadata/metadata.h	2008/01/16 19:00:59	1.177
+++ LVM2/lib/metadata/metadata.h	2008/03/17 16:51:31	1.178
@@ -264,7 +264,7 @@
 /* Find LV with given lvid (used during activation) */
 struct logical_volume *lv_from_lvid(struct cmd_context *cmd,
 				    const char *lvid_s,
-				    int precommitted);
+				    unsigned precommitted);
 
 /* FIXME Merge these functions with ones above */
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);


