From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 11:40:06 -0400
Subject: master - lvmcache: remove unused function
Message-ID: <201906101540.x5AFe6Z5019921@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49b884656725a39a33a5e27dd6377443e7e177e4
Commit:        49b884656725a39a33a5e27dd6377443e7e177e4
Parent:        550536474f2b2ad3ac58f1f91aa2325022df53b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 7 14:39:32 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 10:38:32 2019 -0500

lvmcache: remove unused function

Drop lvmcache_fmt_from_vgname(), the way it was called made
it identical to the existing lvmcache_vginfo_from_vgname().
---
 lib/cache/lvmcache.c |   54 --------------------------------------------------
 lib/cache/lvmcache.h |    1 -
 tools/vgcreate.c     |    4 +-
 3 files changed, 2 insertions(+), 57 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 857a953..e45764a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -278,60 +278,6 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 	return vginfo;
 }
 
-const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
-						   const char *vgname, const char *vgid,
-						   unsigned revalidate_labels)
-{
-	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
-	struct dm_list *devh, *tmp;
-	struct dm_list devs;
-	struct device_list *devl;
-	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
-
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
-		stack;
-		return NULL;
-	}
-
-	/*
-	 * If this function is called repeatedly, only the first one needs to revalidate.
-	 */
-	if (!revalidate_labels)
-		goto out;
-
-	/*
-	 * This function is normally called before reading metadata so
- 	 * we check cached labels here. Unfortunately vginfo is volatile.
- 	 */
-	dm_list_init(&devs);
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(devl = malloc(sizeof(*devl)))) {
-			log_error("device_list element allocation failed");
-			return NULL;
-		}
-		devl->dev = info->dev;
-		dm_list_add(&devs, &devl->list);
-	}
-
-	memcpy(vgid_found, vginfo->vgid, sizeof(vgid_found));
-
-	dm_list_iterate_safe(devh, tmp, &devs) {
-		devl = dm_list_item(devh, struct device_list);
-		label_read(devl->dev);
-		dm_list_del(&devl->list);
-		free(devl);
-	}
-
-	/* If vginfo changed, caller needs to rescan */
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid_found)) ||
-	    strncmp(vginfo->vgid, vgid_found, ID_LEN))
-		return NULL;
-
-out:
-	return vginfo->fmt;
-}
-
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 379cc9d..22c2c1f 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -91,7 +91,6 @@ void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
 
 /* Queries */
-const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
 int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary);
 
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 6640b8e..d594ec1 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -71,7 +71,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * then do the initial label scan which reads all devices and
 	 * populates lvmcache with any VG name it finds.  If the VG name
 	 * we want to use exists, then the label scan will find it,
-	 * and the fmt_from_vgname call (used to check if the name exists)
+	 * and the vginfo_from_vgname call (used to check if the name exists)
 	 * will return non-NULL.
 	 */
 
@@ -82,7 +82,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	lvmcache_label_scan(cmd);
 
-	if (lvmcache_fmt_from_vgname(cmd, vp_new.vg_name, NULL, 0)) {
+	if (lvmcache_vginfo_from_vgname(vp_new.vg_name, NULL)) {
 		unlock_vg(cmd, NULL, vp_new.vg_name);
 		log_error("A volume group called %s already exists.", vp_new.vg_name);
 		return ECMD_FAILED;


