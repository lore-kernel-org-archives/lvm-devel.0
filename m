From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:42 +0000 (UTC)
Subject: dev-dct-process-latest - cache: fix regression and invert test
Message-ID: <20140922153942.81C3060D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d274724c83e0bed34b4a1d794a6eb16cab777c05
Commit:        d274724c83e0bed34b4a1d794a6eb16cab777c05
Parent:        386fbf8e0d30823854ffefb1b4e3b47b09ec5905
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 16:16:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 16:18:39 2014 +0200

cache: fix regression and invert test

Last commit c710f02e0181cc2db5455f0c98033247a70ecc30
converting code to use lv_update_and_reload()
intoduced invalid test for error result.
Fix it and properly check for  if (!...)
---
 lib/metadata/cache_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 73df448..7f5ea65 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -224,7 +224,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		cache_seg->policy_argv = NULL;
 
 		/* update the kernel to put the cleaner policy in place */
-		if (lv_update_and_reload(cache_lv))
+		if (!lv_update_and_reload(cache_lv))
                         return_0;
 	}
 


