From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 15:54:58 +0000 (UTC)
Subject: master - cleanup: preserve signesss and type size on return values
Message-ID: <20130205155458.8AD8D230F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d97605beafab98572e7e797139548dffde91274c
Commit:        d97605beafab98572e7e797139548dffde91274c
Parent:        7910b6c0badbf222e7c434f4cb3c0ad2ed3bd3a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 16:43:16 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 16:54:11 2013 +0100

cleanup: preserve signesss and type size on return values

---
 lib/cache/lvmcache.c |    4 ++--
 lib/cache/lvmcache.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6ef1556..acdd1c8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1814,7 +1814,7 @@ int lvmcache_foreach_mda(struct lvmcache_info *info,
 	return 1;
 }
 
-int lvmcache_mda_count(struct lvmcache_info *info)
+unsigned lvmcache_mda_count(struct lvmcache_info *info)
 {
 	return dm_list_size(&info->mdas);
 }
@@ -1887,7 +1887,7 @@ int lvmcache_uncertain_ownership(struct lvmcache_info *info) {
 	return mdas_empty_or_ignored(&info->mdas);
 }
 
-int lvmcache_smallest_mda_size(struct lvmcache_info *info)
+uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 {
 	return find_min_mda_size(&info->mdas);
 }
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 615f466..768cd4c 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -145,8 +145,8 @@ struct device *lvmcache_device(struct lvmcache_info *info);
 void lvmcache_make_valid(struct lvmcache_info *info);
 int lvmcache_is_orphan(struct lvmcache_info *info);
 int lvmcache_uncertain_ownership(struct lvmcache_info *info);
-int lvmcache_mda_count(struct lvmcache_info *info);
+unsigned lvmcache_mda_count(struct lvmcache_info *info);
 int lvmcache_vgid_is_cached(const char *vgid);
-int lvmcache_smallest_mda_size(struct lvmcache_info *info);
+uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
 #endif


