From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Apr 2020 19:51:04 +0000 (GMT)
Subject: master - lvmcache_get_mda: remove unused function
Message-ID: <20200421195104.7D019384B0C1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3854931aea09b1ccd56a79ea53521be1287ff3a9
Commit:        3854931aea09b1ccd56a79ea53521be1287ff3a9
Parent:        2aa36209eb0087228391b9b01b6f03a6875bad9f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 27 13:15:27 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 10:58:05 2020 -0500

lvmcache_get_mda: remove unused function

---
 lib/cache/lvmcache.c | 30 ------------------------------
 lib/cache/lvmcache.h |  5 -----
 2 files changed, 35 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2c8c614d7..2a52230b5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2567,36 +2567,6 @@ int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid)
 	return 0;
 }
 
-struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
-				       const char *vgname,
-				       struct device *dev,
-				       int use_mda_num)
-{
-	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
-	struct metadata_area *mda;
-
-	if (!use_mda_num)
-		use_mda_num = 1;
-
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
-		return NULL;
-
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (info->dev != dev)
-			continue;
-
-		dm_list_iterate_items(mda, &info->mdas) {
-			if ((use_mda_num == 1) && (mda->status & MDA_PRIMARY))
-				return mda;
-			if ((use_mda_num == 2) && !(mda->status & MDA_PRIMARY))
-				return mda;
-		}
-		return NULL;
-	}
-	return NULL;
-}
-
 /*
  * This is used by the metadata repair command to check if
  * the metadata on a dev needs repair because it's old.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 0c8c78909..2416fe741 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -161,11 +161,6 @@ struct device *lvmcache_device(struct lvmcache_info *info);
 unsigned lvmcache_mda_count(struct lvmcache_info *info);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
-struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
-                                      const char *vgname,
-                                      struct device *dev,
-                                      int use_mda_num);
-
 bool lvmcache_has_duplicate_devs(void);
 void lvmcache_del_dev_from_duplicates(struct device *dev);
 bool lvmcache_dev_is_unused_duplicate(struct device *dev);



