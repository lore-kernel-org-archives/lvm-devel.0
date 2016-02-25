From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:25:37 +0000 (UTC)
Subject: master - lvmcache: fix missing free of vginfo->system_id causing mem leak
Message-ID: <20160225152537.E885A60EF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42ae586fa72a30e0f22c0916e0551228d5eed5c3
Commit:        42ae586fa72a30e0f22c0916e0551228d5eed5c3
Parent:        a77ded3001ad584e75bb3b315a8c99c56951e530
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 25 16:24:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 25 16:25:27 2016 +0100

lvmcache: fix missing free of vginfo->system_id causing mem leak

---
 lib/cache/lvmcache.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1945a74..c28460e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1177,6 +1177,9 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 			vginfo2 = vginfo2->next;
 		}
 
+	if (vginfo->system_id)
+		dm_free(vginfo->system_id);
+
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
 


