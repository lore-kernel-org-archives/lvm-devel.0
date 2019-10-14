From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:25 -0400
Subject: master - cachevol: use writethrough for partial removal
Message-ID: <201910141322.x9EDMPpU018801@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d8047883ea56e633007f3bcca6e87e6cb14cef4
Commit:        8d8047883ea56e633007f3bcca6e87e6cb14cef4
Parent:        77deadd3af81d5641e2e53e604efbfab2cb6d330
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 23:38:56 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:15:14 2019 +0200

cachevol: use writethrough for partial removal

Instead of using 'noflush' option, switch cache_mode into WRITETHROUGH
which does not require flushing, when user confirmed he does not
want flushing for WRITEBACK (because of (partially) missing caching PV)
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 14663e8..f875ac7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1875,7 +1875,8 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 			return 0;
 		}
 
-		noflush = 1;
+		/* Switch internally to WRITETHROUGH which does not require flushing */
+		cache_seg->cache_mode = CACHE_MODE_WRITETHROUGH;
 	}
 				
 	if (!lv_detach_cache_vol(lv, noflush))


