From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Jul 2014 10:32:10 +0000 (UTC)
Subject: master - cleanup: just safely copy string
Message-ID: <20140704103210.532A160DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d2c445d0ac10bf54d39d9aa6e8695c469456489
Commit:        9d2c445d0ac10bf54d39d9aa6e8695c469456489
Parent:        86e116450ec32243f10abbe9b093bdeaab6e0f76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 3 21:31:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 4 12:31:17 2014 +0200

cleanup: just safely copy string

Keep analyzers happier and use constrained strcpy.
---
 lib/cache/lvmcache.c        |    2 +-
 lib/format1/import-export.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3244205..41bac8b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1707,7 +1707,7 @@ static int _get_pv_if_in_vg(struct lvmcache_info *info,
 		 * lvmcache_label_scan() and drop cached
 		 * vginfo so make a local copy of string.
 		 */
-		strcpy(vgname, info->vginfo->vgname);
+		(void) dm_strncpy(vgname, info->vginfo->vgname, sizeof(vgname));
 		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
 
 		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 5ef19ef..8aa4d33 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -347,7 +347,7 @@ static void _export_lv(struct lv_disk *lvd, struct volume_group *vg,
 	snprintf((char *)lvd->lv_name, sizeof(lvd->lv_name), "%s%s/%s",
 		 dev_dir, vg->name, lv->name);
 
-	strcpy((char *)lvd->vg_name, vg->name);
+	(void) dm_strncpy((char *)lvd->vg_name, vg->name, sizeof(lvd->vg_name));
 
 	if (lv->status & LVM_READ)
 		lvd->lv_access |= LV_READ;


