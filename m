From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:32 +0000 (UTC)
Subject: master - cleanup: drop unneeded test
Message-ID: <20160225223632.4DF8C60F80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a9f743eefbe8d86f6a23838789c21136f02cdcd
Commit:        1a9f743eefbe8d86f6a23838789c21136f02cdcd
Parent:        e9b523e3044b83fc1a919f8a07a85d169c7d4d55
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 16:51:14 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

cleanup: drop unneeded test

dmfree tests for NULL
---
 lib/cache/lvmcache.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c28460e..b1e53e2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1177,9 +1177,7 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 			vginfo2 = vginfo2->next;
 		}
 
-	if (vginfo->system_id)
-		dm_free(vginfo->system_id);
-
+	dm_free(vginfo->system_id);
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
 


