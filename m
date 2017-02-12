From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 12 Feb 2017 16:30:51 +0000 (UTC)
Subject: master - coverity: fix double free
Message-ID: <20170212163051.08B4B60304@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=416f9512830ff81e32852f2fce0ee7e36fcdb50f
Commit:        416f9512830ff81e32852f2fce0ee7e36fcdb50f
Parent:        a7d2ee4bc2dd032cd15db028b3c118ce7138c854
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 21:20:12 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 12 17:28:44 2017 +0100

coverity: fix double free

Do not try to free hist_arg twice.
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 032be03..34e117e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4725,7 +4725,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 
 	dm_pool_free(extent_mem, extents);
 	dm_pool_destroy(extent_mem);
-	dm_free(hist_arg);
+
 	return regions;
 
 out_remove:


