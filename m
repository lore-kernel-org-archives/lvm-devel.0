From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:09 +0000 (UTC)
Subject: master - cleanup: simplier string reset
Message-ID: <20130722104209.DBF5E61478@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05a70f2da306164f3c604c50d69e74090b0028bc
Commit:        05a70f2da306164f3c604c50d69e74090b0028bc
Parent:        ea68f085019c3d1a21e8b375bd3eee293d108af4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 15:32:49 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

cleanup: simplier string reset

---
 lib/cache/lvmcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2da09d1..f33565c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1567,7 +1567,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 static void _lvmcache_destroy_entry(struct lvmcache_info *info)
 {
 	_vginfo_detach_info(info);
-	strcpy(info->dev->pvid, "");
+	info->dev->pvid[0] = 0;
 	label_destroy(info->label);
 	dm_free(info);
 }


