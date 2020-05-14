From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 May 2020 15:20:55 +0000 (GMT)
Subject: master - lvmcache: free vginfo lock_type
Message-ID: <20200514152055.AAABA396E853@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a304d7a75b572282c288c60497c7c489e7c3cbd
Commit:        2a304d7a75b572282c288c60497c7c489e7c3cbd
Parent:        5c095400de2f84511726cc8178800d19657b814d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 14 10:20:08 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 14 10:20:08 2020 -0500

lvmcache: free vginfo lock_type

---
 lib/cache/lvmcache.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b8575ff62..6cb5ff0d8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1189,6 +1189,8 @@ static void _free_vginfo(struct lvmcache_vginfo *vginfo)
 	free(vginfo->vgname);
 	free(vginfo->system_id);
 	free(vginfo->creation_host);
+	if (vginfo->lock_type)
+		free(vginfo->lock_type);
 	free(vginfo);
 }
 


