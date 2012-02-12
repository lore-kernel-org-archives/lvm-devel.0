From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 20:19:40 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120212201940.16693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 20:19:40

Modified files:
	lib/metadata   : metadata.c 

Log message:
	remove unused bits after fid changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.478&r2=1.479

--- LVM2/lib/metadata/metadata.c	2012/02/10 02:53:05	1.478
+++ LVM2/lib/metadata/metadata.c	2012/02/12 20:19:39	1.479
@@ -1616,8 +1616,6 @@
 				  unsigned metadataignore)
 {
 	const struct format_type *fmt = cmd->fmt;
-	struct format_instance_ctx fic;
-	struct format_instance *fid;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 	unsigned mda_index;
@@ -2746,8 +2744,6 @@
 					     int warnings,
 					     const char *orphan_vgname)
 {
-	struct format_instance_ctx fic;
-	struct format_instance *fid;
 	const struct format_type *fmt;
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
@@ -2768,8 +2764,6 @@
 	lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton);
 
 	return vg;
-bad:
-	return NULL;
 }
 
 static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
@@ -3557,7 +3551,6 @@
 					int warnings, int scan_label_only)
 {
 	struct physical_volume *pv;
-	struct format_instance_ctx fic;
 	struct label *label;
 	struct lvmcache_info *info;
 	struct device *dev;


